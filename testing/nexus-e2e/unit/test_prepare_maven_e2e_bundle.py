import json
import os
import stat
import subprocess
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

import pytest


SCRIPT = Path(__file__).parents[2] / "hack" / "prepare-maven-e2e-bundle.sh"
CONTAINERFILE = SCRIPT.parents[1] / "Containerfile"
DOCKERIGNORE = SCRIPT.parents[2] / ".dockerignore"


def dockerfile_instructions():
    instructions = []
    current = ""
    for raw_line in CONTAINERFILE.read_text().splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        current = f"{current} {line}".strip()
        if current.endswith("\\"):
            current = current[:-1].rstrip()
        else:
            instructions.append(current)
            current = ""
    assert not current
    return instructions


def dockerfile_stage(name):
    instructions = dockerfile_instructions()
    start = instructions.index(f"FROM test-base AS {name}")
    end = next(
        (index for index in range(start + 1, len(instructions)) if instructions[index].startswith("FROM ")),
        len(instructions),
    )
    return instructions[start:end]


def run_script(*args, env=None):
    return subprocess.run(
        [str(SCRIPT), *(str(arg) for arg in args)],
        text=True,
        capture_output=True,
        env=env,
    )


def make_project(tmp_path):
    project = tmp_path / "project"
    project.mkdir()
    (project / "publish.xml").write_text("<project/>")
    (project / "download.xml").write_text("<project/>")
    return project


def fake_maven_environment(tmp_path):
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    log = tmp_path / "mvn.jsonl"
    settings_capture = tmp_path / "settings.xml"
    fake = bin_dir / "mvn"
    fake.write_text(
        """#!/usr/bin/env python3
import json
import os
import pathlib
import shutil
import sys

with open(os.environ["FAKE_MVN_LOG"], "a") as stream:
    stream.write(json.dumps(sys.argv[1:]) + "\\n")
if "-o" in sys.argv and "deploy" in sys.argv:
    sys.exit(99)
settings = pathlib.Path(sys.argv[sys.argv.index("-s") + 1])
shutil.copyfile(settings, os.environ["FAKE_SETTINGS_CAPTURE"])

repo_arg = next(arg for arg in sys.argv if arg.startswith("-Dmaven.repo.local="))
repo = pathlib.Path(repo_arg.split("=", 1)[1])
if not (repo / "junit/junit/4.11/junit-4.11.jar").exists():
    files = {
        "junit/junit/4.11/junit-4.11.jar": "junit",
        "org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar": "hamcrest",
        "org/apache/maven/plugins/maven-deploy-plugin/2.8.2/maven-deploy-plugin-2.8.2.jar": "deploy",
        "org/apache/maven/plugins/maven-deploy-plugin/2.8.2/maven-deploy-plugin-2.8.2.pom": "deploy",
        "junit/junit/4.11/_remote.repositories": "metadata",
        "bad/example/1/example-1.jar.lastUpdated": "metadata",
        "resolver-status.properties": "metadata",
        "com/nexus/test/test-publish/1.0-SNAPSHOT/test-publish.jar": "own",
    }
    for relative, value in files.items():
        path = repo / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(value)
"""
    )
    fake.chmod(fake.stat().st_mode | stat.S_IXUSR)
    env = os.environ.copy()
    env.update(
        PATH=f"{bin_dir}{os.pathsep}{env['PATH']}",
        FAKE_MVN_LOG=str(log),
        FAKE_SETTINGS_CAPTURE=str(settings_capture),
    )
    return env, log, settings_capture


def test_requires_exactly_two_arguments_and_prints_usage():
    result = run_script()
    assert result.returncode != 0
    assert "Usage:" in result.stderr


@pytest.mark.parametrize("target", ["/", "same-as-project", "source-root"])
def test_rejects_dangerous_bundle_targets(tmp_path, target):
    project = make_project(tmp_path)
    if target == "same-as-project":
        bundle = project
    elif target == "source-root":
        bundle = SCRIPT.parents[2]
    else:
        bundle = target
    result = run_script(project, bundle)
    assert result.returncode != 0
    assert "unsafe" in result.stderr.lower()


def add_cleanup_sentinels(bundle):
    sentinels = [
        bundle / "repository" / "sentinel",
        bundle / "deployment" / "sentinel",
        bundle / "settings.xml",
    ]
    for sentinel in sentinels:
        sentinel.parent.mkdir(parents=True, exist_ok=True)
        sentinel.write_text("do-not-delete")
    return sentinels


def cleanup_sentinels(bundle, sentinels):
    for sentinel in sentinels:
        sentinel.unlink(missing_ok=True)
    for directory in [bundle / "repository", bundle / "deployment"]:
        if directory.exists():
            directory.rmdir()


@pytest.mark.parametrize("spelling", ["dot", "child-parent"])
def test_rejects_project_alias_before_deleting_sentinels(tmp_path, spelling):
    project = make_project(tmp_path)
    (project / "child").mkdir()
    bundle = f"{project}/." if spelling == "dot" else f"{project}/child/.."
    sentinels = add_cleanup_sentinels(project)

    result = run_script(project, bundle)

    assert result.returncode != 0
    assert "unsafe" in result.stderr.lower()
    assert all(sentinel.read_text() == "do-not-delete" for sentinel in sentinels)


def test_rejects_source_root_dot_before_deleting_sentinels(tmp_path):
    project = make_project(tmp_path)
    source_root = SCRIPT.parents[2]
    assert all(not path.exists() for path in [
        source_root / "repository", source_root / "deployment", source_root / "settings.xml"
    ])
    sentinels = add_cleanup_sentinels(source_root)
    try:
        result = run_script(project, f"{source_root}/.")
        assert result.returncode != 0
        assert "unsafe" in result.stderr.lower()
        assert all(sentinel.read_text() == "do-not-delete" for sentinel in sentinels)
    finally:
        cleanup_sentinels(source_root, sentinels)


@pytest.mark.parametrize("destination", ["project", "source-root"])
def test_rejects_alias_through_symlinked_ancestor(tmp_path, destination):
    project = make_project(tmp_path)
    target = project if destination == "project" else SCRIPT.parents[2]
    alias_parent = tmp_path / "alias-parent"
    alias_parent.symlink_to(target.parent, target_is_directory=True)
    bundle = alias_parent / target.name
    if target == SCRIPT.parents[2]:
        assert all(not path.exists() for path in [
            target / "repository", target / "deployment", target / "settings.xml"
        ])
    sentinels = add_cleanup_sentinels(target)
    try:
        result = run_script(project, bundle)
        assert result.returncode != 0
        assert "unsafe" in result.stderr.lower()
        assert all(sentinel.read_text() == "do-not-delete" for sentinel in sentinels)
    finally:
        if target == SCRIPT.parents[2]:
            cleanup_sentinels(target, sentinels)


@pytest.mark.parametrize("suffix", ["", "/"])
def test_rejects_direct_bundle_symlink(tmp_path, suffix):
    project = make_project(tmp_path)
    target = tmp_path / "bundle-target"
    target.mkdir()
    sentinels = add_cleanup_sentinels(target)
    alias = tmp_path / "bundle-alias"
    alias.symlink_to(target, target_is_directory=True)

    result = run_script(project, f"{alias}{suffix}")

    assert result.returncode != 0
    assert "unsafe" in result.stderr.lower()
    assert all(sentinel.read_text() == "do-not-delete" for sentinel in sentinels)


def test_requires_project_files(tmp_path):
    project = tmp_path / "project"
    project.mkdir()
    result = run_script(project, tmp_path / "bundle")
    assert result.returncode != 0
    assert "publish.xml" in result.stderr


def test_builds_and_verifies_container_independent_bundle(tmp_path):
    project = make_project(tmp_path)
    bundle = tmp_path / "bundle"
    env, log, settings_capture = fake_maven_environment(tmp_path)
    env["MAVEN_BUNDLE_MIRROR_URL"] = "https://mirror.test/repository/public?a=1&b=2"

    result = run_script(project, bundle, env=env)

    assert result.returncode == 0, result.stderr
    calls = [json.loads(line) for line in log.read_text().splitlines()]
    assert len(calls) == 4
    assert ["clean", "deploy"] == calls[0][-2:]
    assert calls[1][-1] == "package"
    assert ["clean", "install"] == calls[2][-2:]
    assert calls[3][-1] == "package"
    assert all(any(arg.startswith("-Dmaven.repo.local=") for arg in call) for call in calls)
    assert all("-o" not in call for call in calls[:2])
    assert all("-o" in call for call in calls[2:])
    deploy = next(arg for arg in calls[0] if arg.startswith("-DaltDeploymentRepository="))
    assert deploy.startswith("-DaltDeploymentRepository=bundle::default::file://")

    root = ET.parse(settings_capture).getroot()
    ns = {"m": "http://maven.apache.org/SETTINGS/1.0.0"}
    assert root.findtext("m:localRepository", namespaces=ns) == str(bundle / "repository")
    assert root.findtext("m:mirrors/m:mirror/m:mirrorOf", namespaces=ns) == "central"
    assert root.findtext("m:mirrors/m:mirror/m:url", namespaces=ns) == env["MAVEN_BUNDLE_MIRROR_URL"]
    assert root.find("m:servers", ns) is None

    repo = bundle / "repository"
    assert (repo / "junit/junit/4.11/junit-4.11.jar").is_file()
    assert not (repo / "junit/junit/4.11/junit-4.11.jar").is_symlink()
    assert (repo / "org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar").is_file()
    deploy_plugin = repo / "org/apache/maven/plugins/maven-deploy-plugin/2.8.2"
    assert (deploy_plugin / "maven-deploy-plugin-2.8.2.jar").is_file()
    assert (deploy_plugin / "maven-deploy-plugin-2.8.2.pom").is_file()
    assert not list(repo.rglob("_remote.repositories"))
    assert not list(repo.rglob("*.lastUpdated"))
    assert not list(repo.rglob("resolver-status.properties"))
    assert not (repo / "com/nexus/test/test-publish").exists()
    assert not (bundle / "deployment").exists()
    assert not (bundle / "settings.xml").exists()


def test_uses_legacy_mirror_environment_fallback(tmp_path):
    project = make_project(tmp_path)
    bundle = tmp_path / "bundle"
    env, _, settings_capture = fake_maven_environment(tmp_path)
    env.pop("MAVEN_BUNDLE_MIRROR_URL", None)
    env["MACVEN_MIRROR_REGISTRY"] = "https://legacy-mirror.test/maven"
    result = run_script(project, bundle, env=env)
    assert result.returncode == 0, result.stderr
    assert "https://legacy-mirror.test/maven" in settings_capture.read_text()


def test_rejects_repository_symlink_without_deleting_external_files(tmp_path):
    project = make_project(tmp_path)
    bundle = tmp_path / "bundle"
    bundle.mkdir()
    outside = tmp_path / "outside"
    outside.mkdir()
    sentinel = outside / "sentinel"
    sentinel.write_text("do-not-delete")
    (bundle / "repository").symlink_to(outside, target_is_directory=True)
    env, _, _ = fake_maven_environment(tmp_path)

    result = run_script(project, bundle, env=env)

    assert result.returncode != 0
    assert "symlink" in result.stderr.lower() or "unsafe" in result.stderr.lower()
    assert sentinel.read_text() == "do-not-delete"


def test_bundle_swap_before_cleanup_does_not_delete_external_files(tmp_path):
    project = make_project(tmp_path)
    bundle = tmp_path / "bundle"
    outside = tmp_path / "outside"
    (outside / "repository").mkdir(parents=True)
    sentinel = outside / "repository" / "sentinel"
    sentinel.write_text("do-not-delete")
    env, _, _ = fake_maven_environment(tmp_path)
    swapper = tmp_path / "bin" / "python3"
    swapper.write_text(
        f"""#!{sys.executable}
import os
import pathlib
import sys

marker = pathlib.Path(os.environ["PYTHON_SWAP_MARKER"])
if not marker.exists():
    marker.write_text("swapped")
    bundle = pathlib.Path(os.environ["SWAP_BUNDLE"])
    bundle.rename(bundle.with_name("bundle-original"))
    bundle.symlink_to(os.environ["SWAP_OUTSIDE"], target_is_directory=True)
os.execv({sys.executable!r}, [{sys.executable!r}, *sys.argv[1:]])
"""
    )
    swapper.chmod(swapper.stat().st_mode | stat.S_IXUSR)
    env.update(
        PYTHON_SWAP_MARKER=str(tmp_path / "python-swap-marker"),
        SWAP_BUNDLE=str(bundle),
        SWAP_OUTSIDE=str(outside),
    )

    result = run_script(project, bundle, env=env)

    assert result.returncode != 0
    assert sentinel.read_text() == "do-not-delete"


def test_containerfile_builds_maven_bundle_in_an_isolated_stage():
    instructions = dockerfile_instructions()
    bundle_stage = "\n".join(dockerfile_stage("maven-bundle"))
    final_stage = "\n".join(dockerfile_stage("test-image"))

    assert "FROM registry.alauda.cn:60070/devops/nexus-ce-test-base:latest AS test-base" in instructions
    assert "ARG MAVEN_BUNDLE_MIRROR_URL=https://artifacts.alauda.io/repository/maven-central" in bundle_stage
    assert "MAVEN_BUNDLE_MIRROR_URL=$MAVEN_BUNDLE_MIRROR_URL" in bundle_stage
    assert "PATH=/tools/bin/maven/bin:$PATH" in bundle_stage
    assert "testing/nexus-e2e/test_projects/maven" in bundle_stage
    assert "testing/hack/prepare-maven-e2e-bundle.sh" in bundle_stage
    assert "/opt/nexus-e2e/maven-bundle/repository /opt/nexus-e2e/maven-repository" in bundle_stage
    assert "/opt/nexus-e2e/maven-repository" in bundle_stage
    assert "MAVEN_BUNDLE_MIRROR_URL" not in final_stage


def test_containerfile_final_image_packages_only_runtime_bundle_assets():
    final_stage = "\n".join(dockerfile_stage("test-image"))

    assert "COPY --from=maven-bundle /opt/nexus-e2e/maven-repository /opt/nexus-e2e/maven-repository" in final_stage
    assert "COPY testing/hack/import-maven-e2e-dependencies.py /usr/local/bin/import-maven-e2e-dependencies" in final_stage
    assert "chmod 755 /usr/local/bin/import-maven-e2e-dependencies" in final_stage
    assert "junit/junit/4.11/junit-4.11.jar" in final_stage
    assert "org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar" in final_stage
    assert "maven-deploy-plugin/2.8.2/maven-deploy-plugin-2.8.2.jar" in final_stage
    assert "maven-deploy-plugin/2.8.2/maven-deploy-plugin-2.8.2.pom" in final_stage
    assert "ENTRYPOINT [\"/app/lynx-entrypoint.sh\"]" in final_stage
    assert not any(line.startswith("CMD ") for line in final_stage.splitlines())
    assert final_stage.count("ENTRYPOINT") == 1
    assert final_stage.count("CMD") == 0
    assert "settings.xml" not in final_stage
    assert "deployment" not in final_stage
    assert "com/nexus/test/test-publish" not in final_stage


def test_dockerignore_excludes_workspace_artifacts_without_excluding_build_inputs():
    patterns = {
        line.strip()
        for line in DOCKERIGNORE.read_text().splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    }

    assert {".git", ".git/**", ".worktrees", "**/__pycache__", "**/*.py[cod]"} <= patterns
    assert {"**/target", "**/target/**", ".env", ".env.*"} <= patterns
    assert {".pytest_cache", "**/.pytest_cache", ".DS_Store", "**/.DS_Store"} <= patterns
    assert not {
        "go.mod",
        "testing",
        "testing/Containerfile",
        "testing/hack/prepare-maven-e2e-bundle.sh",
        "testing/nexus-e2e/test_projects/maven",
    } & patterns
