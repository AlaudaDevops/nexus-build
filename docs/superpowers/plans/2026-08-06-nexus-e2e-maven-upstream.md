# Nexus E2E Maven Upstream Bundle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Package the Maven dependencies required by Nexus E2E in the testing image, import them into an authenticated second Nexus, and configure the tested Nexus proxy to download from it.

**Architecture:** Build a verified Maven2-layout bundle by replaying the actual E2E Maven lifecycles in an isolated local repository. A standalone Python importer creates or validates an upstream hosted repository and uploads that bundle idempotently. The Python E2E suite gains a typed upstream configuration and passes optional Basic Authentication to the tested Nexus proxy while preserving the legacy anonymous mirror path.

**Tech Stack:** Python 3.12, pytest, requests, Maven 3.9.14, Nexus Repository REST API, Docker/Containerfile

---

## File Map

- Create `testing/nexus-e2e/libs/maven_upstream.py`: parse and validate upstream environment variables and compose the hosted repository URL.
- Create `testing/nexus-e2e/unit/test_maven_upstream.py`: unit tests for new and legacy upstream selection.
- Modify `testing/nexus-e2e/conftest.py`: expose the upstream configuration as a pytest fixture.
- Modify `testing/nexus-e2e/libs/nexus_client.py`: add optional Basic Authentication to Maven proxy configuration.
- Create `testing/nexus-e2e/unit/test_nexus_client.py`: assert exact authenticated and unauthenticated Nexus REST payloads.
- Modify `testing/nexus-e2e/test_maven_repo.py`: select the authenticated upstream for the proxy scenario.
- Create `testing/hack/import-maven-e2e-dependencies.py`: standalone, idempotent bundle importer.
- Create `testing/nexus-e2e/unit/test_import_maven_e2e_dependencies.py`: importer tests using a local fake Nexus HTTP server.
- Create `testing/hack/prepare-maven-e2e-bundle.sh`: build, sanitize, and offline-verify the Maven repository bundle.
- Create `testing/nexus-e2e/unit/test_prepare_maven_e2e_bundle.py`: static and behavioral tests for bundle filtering and command contract.
- Modify `testing/Containerfile`: build the bundle and install the importer in the final image.
- Modify `testing/README.md`: document import and authenticated proxy execution.

The production units stay independent: E2E configuration does not import the standalone importer, and the importer does not depend on pytest or repository source layout.

### Task 1: Add typed upstream Maven configuration

**Files:**
- Create: `testing/nexus-e2e/libs/maven_upstream.py`
- Create: `testing/nexus-e2e/unit/test_maven_upstream.py`
- Modify: `testing/nexus-e2e/conftest.py:1-30`

- [ ] **Step 1: Write failing configuration tests**

Create `testing/nexus-e2e/unit/test_maven_upstream.py`:

```python
import pytest

from libs.maven_upstream import MavenUpstreamConfig, load_maven_upstream


def test_loads_authenticated_upstream_with_default_repository():
    config = load_maven_upstream({
        "MAVEN_UPSTREAM_URL": "https://upstream.example/nexus/",
        "MAVEN_UPSTREAM_USERNAME": "reader",
        "MAVEN_UPSTREAM_PASSWORD": "secret",
    })

    assert config == MavenUpstreamConfig(
        url="https://upstream.example/nexus",
        repository="maven-e2e-external",
        username="reader",
        password="secret",
    )
    assert config.repository_url == (
        "https://upstream.example/nexus/repository/maven-e2e-external/"
    )


def test_repository_name_can_be_overridden():
    config = load_maven_upstream({
        "MAVEN_UPSTREAM_URL": "https://upstream.example",
        "MAVEN_UPSTREAM_REPOSITORY": "team-maven-seed",
        "MAVEN_UPSTREAM_USERNAME": "reader",
        "MAVEN_UPSTREAM_PASSWORD": "secret",
    })

    assert config.repository == "team-maven-seed"


@pytest.mark.parametrize(
    "missing",
    ["MAVEN_UPSTREAM_USERNAME", "MAVEN_UPSTREAM_PASSWORD"],
)
def test_partial_authenticated_configuration_is_rejected(missing):
    environment = {
        "MAVEN_UPSTREAM_URL": "https://upstream.example",
        "MAVEN_UPSTREAM_USERNAME": "reader",
        "MAVEN_UPSTREAM_PASSWORD": "secret",
    }
    del environment[missing]

    with pytest.raises(ValueError, match=missing):
        load_maven_upstream(environment)


def test_absent_upstream_uses_legacy_mode():
    assert load_maven_upstream({}) is None
```

- [ ] **Step 2: Run the tests and verify RED**

Run:

```bash
cd testing/nexus-e2e
python -m pytest unit/test_maven_upstream.py -q
```

Expected: collection fails with `ModuleNotFoundError: No module named 'libs.maven_upstream'`.

- [ ] **Step 3: Implement the configuration model**

Create `testing/nexus-e2e/libs/maven_upstream.py`:

```python
from dataclasses import dataclass
from typing import Mapping, Optional


DEFAULT_REPOSITORY = "maven-e2e-external"


@dataclass(frozen=True)
class MavenUpstreamConfig:
    url: str
    repository: str
    username: str
    password: str

    @property
    def repository_url(self) -> str:
        return f"{self.url}/repository/{self.repository}/"


def load_maven_upstream(
    environment: Mapping[str, str],
) -> Optional[MavenUpstreamConfig]:
    url = environment.get("MAVEN_UPSTREAM_URL", "").strip()
    if not url:
        return None

    required = ("MAVEN_UPSTREAM_USERNAME", "MAVEN_UPSTREAM_PASSWORD")
    missing = [name for name in required if not environment.get(name)]
    if missing:
        raise ValueError(
            "authenticated Maven upstream requires " + ", ".join(missing)
        )

    repository = environment.get(
        "MAVEN_UPSTREAM_REPOSITORY", DEFAULT_REPOSITORY
    ).strip()
    if not repository or "/" in repository:
        raise ValueError("MAVEN_UPSTREAM_REPOSITORY must be a repository name")

    return MavenUpstreamConfig(
        url=url.rstrip("/"),
        repository=repository,
        username=environment["MAVEN_UPSTREAM_USERNAME"],
        password=environment["MAVEN_UPSTREAM_PASSWORD"],
    )
```

Modify `testing/nexus-e2e/conftest.py` to import `load_maven_upstream` and add:

```python
@pytest.fixture(scope="session")
def maven_upstream_config():
    return load_maven_upstream(os.environ)
```

- [ ] **Step 4: Run the tests and verify GREEN**

Run:

```bash
cd testing/nexus-e2e
python -m pytest unit/test_maven_upstream.py -q
```

Expected: `5 passed`.

- [ ] **Step 5: Commit the configuration unit**

```bash
git add testing/nexus-e2e/libs/maven_upstream.py \
  testing/nexus-e2e/unit/test_maven_upstream.py testing/nexus-e2e/conftest.py
git commit -m "feat(testing): add authenticated Maven upstream config"
```

### Task 2: Configure authenticated Nexus proxy requests

**Files:**
- Modify: `testing/nexus-e2e/libs/nexus_client.py:6-83`
- Create: `testing/nexus-e2e/unit/test_nexus_client.py`

- [ ] **Step 1: Write failing proxy payload tests**

Create `testing/nexus-e2e/unit/test_nexus_client.py`:

```python
from libs.nexus_client import _get_repository_config


def test_proxy_config_includes_basic_authentication():
    config = _get_repository_config(
        "maven",
        "maven-central",
        "proxy",
        "https://upstream.example/repository/maven-e2e-external/",
        remote_username="reader",
        remote_password="secret",
    )

    assert config["httpClient"]["authentication"] == {
        "type": "username",
        "username": "reader",
        "password": "secret",
    }


def test_proxy_config_omits_authentication_for_legacy_remote():
    config = _get_repository_config(
        "maven",
        "maven-central",
        "proxy",
        "https://artifacts.example/repository/maven-central/",
    )

    assert "authentication" not in config["httpClient"]
```

- [ ] **Step 2: Run the tests and verify RED**

Run:

```bash
cd testing/nexus-e2e
python -m pytest unit/test_nexus_client.py -q
```

Expected: the authenticated test fails with `unexpected keyword argument 'remote_username'`.

- [ ] **Step 3: Add optional authentication to repository configuration**

Change the signature of `_get_repository_config` to:

```python
def _get_repository_config(
    repo_format,
    repo_name,
    repo_type="hosted",
    remote_url=None,
    remote_username=None,
    remote_password=None,
):
```

After building the proxy `httpClient` dictionary, add:

```python
        if remote_username is not None and remote_password is not None:
            base_config["httpClient"]["authentication"] = {
                "type": "username",
                "username": remote_username,
                "password": remote_password,
            }
```

Extend `NexusClient.update_proxy_config`:

```python
    def update_proxy_config(
        self,
        repo_format,
        repo_name,
        repo_type="proxy",
        remote_url=None,
        remote_username=None,
        remote_password=None,
    ):
        endpoint = f"service/rest/v1/repositories/{repo_format}/{repo_type}/{repo_name}"
        config = _get_repository_config(
            repo_format,
            repo_name,
            repo_type,
            remote_url,
            remote_username,
            remote_password,
        )
        response = self.session.put(urljoin(self.base_url, endpoint), json=config)
        response.raise_for_status()
        return response
```

- [ ] **Step 4: Run the tests and verify GREEN**

Run:

```bash
cd testing/nexus-e2e
python -m pytest unit/test_nexus_client.py -q
```

Expected: `2 passed`.

- [ ] **Step 5: Commit authenticated proxy support**

```bash
git add testing/nexus-e2e/libs/nexus_client.py \
  testing/nexus-e2e/unit/test_nexus_client.py
git commit -m "feat(testing): support authentication for Maven proxy remotes"
```

### Task 3: Route the Maven proxy E2E through the second Nexus

**Files:**
- Modify: `testing/nexus-e2e/test_maven_repo.py:29-52,123-144`
- Modify: `testing/nexus-e2e/unit/test_maven_upstream.py`

- [ ] **Step 1: Write failing remote-selection tests**

Append to `testing/nexus-e2e/unit/test_maven_upstream.py`:

```python
from libs.maven_upstream import select_proxy_remote


def test_authenticated_config_wins_over_legacy_mirror():
    environment = {
        "MAVEN_UPSTREAM_URL": "https://upstream.example/",
        "MAVEN_UPSTREAM_REPOSITORY": "seed",
        "MAVEN_UPSTREAM_USERNAME": "reader",
        "MAVEN_UPSTREAM_PASSWORD": "secret",
        "MACVEN_MIRROR_REGISTRY": "https://legacy.example/maven",
    }

    remote = select_proxy_remote(environment)

    assert remote.url == "https://upstream.example/repository/seed/"
    assert remote.username == "reader"
    assert remote.password == "secret"


def test_legacy_mirror_remains_unauthenticated():
    remote = select_proxy_remote({
        "MACVEN_MIRROR_REGISTRY": "https://legacy.example/maven/",
    })

    assert remote.url == "https://legacy.example/maven/"
    assert remote.username is None
    assert remote.password is None
```

- [ ] **Step 2: Run the tests and verify RED**

Run:

```bash
cd testing/nexus-e2e
python -m pytest unit/test_maven_upstream.py -q
```

Expected: collection fails because `select_proxy_remote` does not exist.

- [ ] **Step 3: Implement proxy remote selection**

Append to `testing/nexus-e2e/libs/maven_upstream.py`:

```python
@dataclass(frozen=True)
class MavenProxyRemote:
    url: str
    username: Optional[str] = None
    password: Optional[str] = None


def select_proxy_remote(environment: Mapping[str, str]) -> MavenProxyRemote:
    upstream = load_maven_upstream(environment)
    if upstream:
        return MavenProxyRemote(
            url=upstream.repository_url,
            username=upstream.username,
            password=upstream.password,
        )

    legacy = environment.get(
        "MACVEN_MIRROR_REGISTRY",
        "https://artifacts.alauda.io/repository/maven-central",
    )
    return MavenProxyRemote(url=f"{legacy.rstrip('/')}/")
```

- [ ] **Step 4: Use the selected remote in `test_maven_proxy`**

Import `select_proxy_remote` and replace the proxy update with:

```python
        remote = select_proxy_remote(os.environ)
        nexus_client.update_proxy_config(
            "maven",
            "maven-central",
            "proxy",
            remote.url,
            remote.username,
            remote.password,
        )
```

Keep `_maven_central_mirror_url()` for publish scenarios so existing behavior
is unchanged. Do not log the `remote` object because it contains a password.

- [ ] **Step 5: Run focused and existing Python tests**

Run:

```bash
cd testing/nexus-e2e
python -m pytest unit/test_maven_upstream.py unit/test_nexus_client.py -q
python -m pytest --collect-only test_maven_repo.py -q
```

Expected: unit tests pass; the E2E module collects `test_maven_publish` and
`test_maven_proxy` without import errors.

- [ ] **Step 6: Commit E2E routing**

```bash
git add testing/nexus-e2e/libs/maven_upstream.py \
  testing/nexus-e2e/test_maven_repo.py \
  testing/nexus-e2e/unit/test_maven_upstream.py
git commit -m "feat(testing): route Maven proxy E2E to authenticated upstream"
```

### Task 4: Build the standalone idempotent importer

**Files:**
- Create: `testing/hack/import-maven-e2e-dependencies.py`
- Create: `testing/nexus-e2e/unit/test_import_maven_e2e_dependencies.py`

- [ ] **Step 1: Write failing importer tests with a fake Nexus session**

Create `testing/nexus-e2e/unit/test_import_maven_e2e_dependencies.py`. Load the
hyphenated script through `importlib.util.spec_from_file_location`, then test
its public `ImportConfig`, `ensure_repository`, and `upload_bundle` units:

```python
import importlib.util
from pathlib import Path
import sys

import pytest
import requests


SCRIPT = Path(__file__).parents[2] / "hack/import-maven-e2e-dependencies.py"
SPEC = importlib.util.spec_from_file_location("maven_importer", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)


class Response:
    def __init__(self, status_code, content=b""):
        self.status_code = status_code
        self.content = content

    def raise_for_status(self):
        if self.status_code >= 400:
            raise requests.HTTPError(response=self)

    def json(self):
        return self._json


class Session:
    def __init__(self, responses):
        self.responses = iter(responses)
        self.calls = []

    def request(self, method, url, **kwargs):
        self.calls.append((method, url, kwargs))
        return next(self.responses)


def test_creates_missing_maven_hosted_repository():
    session = Session([Response(404), Response(201)])
    config = MODULE.ImportConfig("https://nexus.example", "seed", "u", "p")

    MODULE.ensure_repository(session, config)

    method, url, kwargs = session.calls[1]
    assert method == "POST"
    assert url.endswith("/service/rest/v1/repositories/maven/hosted")
    assert kwargs["json"]["name"] == "seed"
    assert kwargs["json"]["maven"] == {
        "versionPolicy": "MIXED",
        "layoutPolicy": "STRICT",
        "contentDisposition": "INLINE",
    }


def test_rejects_existing_repository_with_wrong_type():
    response = Response(200)
    response._json = {"format": "maven2", "type": "proxy"}
    session = Session([response])
    config = MODULE.ImportConfig("https://nexus.example", "seed", "u", "p")

    with pytest.raises(RuntimeError, match="Maven hosted"):
        MODULE.ensure_repository(session, config)


def test_upload_skips_equal_content_and_rejects_conflict(tmp_path):
    artifact = tmp_path / "junit/junit/4.11/junit-4.11.pom"
    artifact.parent.mkdir(parents=True)
    artifact.write_bytes(b"pom")
    config = MODULE.ImportConfig("https://nexus.example", "seed", "u", "p")

    equal = Session([Response(200, b"pom")])
    assert MODULE.upload_bundle(equal, config, tmp_path) == (0, 1, 0)

    conflict = Session([Response(200, b"different")])
    with pytest.raises(RuntimeError, match="conflicting content"):
        MODULE.upload_bundle(conflict, config, tmp_path)


def test_password_is_not_rendered_in_error(tmp_path):
    config = MODULE.ImportConfig(
        "https://nexus.example", "seed", "reader", "do-not-print"
    )
    session = Session([Response(401)])

    with pytest.raises(RuntimeError) as error:
        MODULE.ensure_repository(session, config)

    assert "do-not-print" not in str(error.value)
```

- [ ] **Step 2: Run importer tests and verify RED**

Run:

```bash
cd testing/nexus-e2e
python -m pytest unit/test_import_maven_e2e_dependencies.py -q
```

Expected: collection fails because the importer file does not exist.

- [ ] **Step 3: Implement importer configuration and repository validation**

Create `testing/hack/import-maven-e2e-dependencies.py` with:

```python
#!/usr/bin/env python3
import argparse
import getpass
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Mapping

import requests


DEFAULT_REPOSITORY = "maven-e2e-external"
DEFAULT_BUNDLE = Path("/opt/nexus-e2e/maven-repository")


@dataclass(frozen=True)
class ImportConfig:
    url: str
    repository: str
    username: str
    password: str

    @property
    def repository_url(self):
        return f"{self.url}/repository/{self.repository}/"


def request(session, method, url, **kwargs):
    response = session.request(method, url, timeout=60, **kwargs)
    if response.status_code in (401, 403):
        raise RuntimeError(f"authentication or authorization failed for {url}")
    return response


def ensure_repository(session, config):
    item_url = (
        f"{config.url}/service/rest/v1/repositories/"
        f"maven/hosted/{config.repository}"
    )
    response = request(session, "GET", item_url)
    if response.status_code == 200:
        data = response.json()
        if data.get("format") not in ("maven", "maven2") or data.get("type") != "hosted":
            raise RuntimeError(
                f"repository {config.repository!r} is not a Maven hosted repository"
            )
        return
    if response.status_code != 404:
        response.raise_for_status()

    payload = {
        "name": config.repository,
        "online": True,
        "storage": {
            "blobStoreName": "default",
            "strictContentTypeValidation": True,
            "writePolicy": "ALLOW_ONCE",
        },
        "maven": {
            "versionPolicy": "MIXED",
            "layoutPolicy": "STRICT",
            "contentDisposition": "INLINE",
        },
    }
    created = request(
        session,
        "POST",
        f"{config.url}/service/rest/v1/repositories/maven/hosted",
        json=payload,
    )
    created.raise_for_status()
```

- [ ] **Step 4: Implement digest comparison, upload, verification, and CLI**

Continue the same file with:

```python
def upload_bundle(session, config, bundle):
    uploaded = skipped = failed = 0
    for artifact in sorted(path for path in bundle.rglob("*") if path.is_file()):
        relative = artifact.relative_to(bundle).as_posix()
        target = f"{config.repository_url}{relative}"
        existing = request(session, "GET", target)
        if existing.status_code == 200:
            if existing.content == artifact.read_bytes():
                skipped += 1
                continue
            raise RuntimeError(f"conflicting content already exists at {target}")
        if existing.status_code != 404:
            existing.raise_for_status()

        uploaded_response = request(
            session, "PUT", target, data=artifact.read_bytes()
        )
        if uploaded_response.status_code not in (200, 201, 204):
            failed += 1
            uploaded_response.raise_for_status()
        uploaded += 1
    return uploaded, skipped, failed


def load_config(environment: Mapping[str, str], password_prompt=getpass.getpass):
    url = environment.get("MAVEN_UPSTREAM_URL", "").strip().rstrip("/")
    username = environment.get("MAVEN_UPSTREAM_USERNAME", "").strip()
    password = environment.get("MAVEN_UPSTREAM_PASSWORD", "")
    repository = environment.get(
        "MAVEN_UPSTREAM_REPOSITORY", DEFAULT_REPOSITORY
    ).strip()
    if not url or not username:
        raise RuntimeError(
            "MAVEN_UPSTREAM_URL and MAVEN_UPSTREAM_USERNAME are required"
        )
    if not password:
        password = password_prompt("Maven upstream password: ")
    if not password:
        raise RuntimeError("MAVEN_UPSTREAM_PASSWORD is required")
    if not repository or "/" in repository:
        raise RuntimeError("invalid MAVEN_UPSTREAM_REPOSITORY")
    return ImportConfig(url, repository, username, password)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--bundle", type=Path, default=DEFAULT_BUNDLE)
    args = parser.parse_args()
    if not args.bundle.is_dir():
        raise RuntimeError(f"bundle directory does not exist: {args.bundle}")

    config = load_config(os.environ)
    session = requests.Session()
    session.auth = (config.username, config.password)
    ensure_repository(session, config)
    uploaded, skipped, failed = upload_bundle(session, config, args.bundle)
    print(
        f"Imported Maven E2E bundle into {config.repository_url}: "
        f"uploaded={uploaded} skipped={skipped} failed={failed}"
    )


if __name__ == "__main__":
    main()
```

Add focused tests for `load_config`, password prompting, path preservation, a
successful PUT, and a 403 response. Assertions must check that neither the
password nor an Authorization value appears in stdout, stderr, or exceptions.

- [ ] **Step 5: Run importer tests and verify GREEN**

Run:

```bash
cd testing/nexus-e2e
python -m pytest unit/test_import_maven_e2e_dependencies.py -q
```

Expected: all importer tests pass.

- [ ] **Step 6: Verify executable syntax and permissions**

Run:

```bash
chmod 755 testing/hack/import-maven-e2e-dependencies.py
python -m py_compile testing/hack/import-maven-e2e-dependencies.py
```

Expected: exit 0 and no output.

- [ ] **Step 7: Commit the importer**

```bash
git add testing/hack/import-maven-e2e-dependencies.py \
  testing/nexus-e2e/unit/test_import_maven_e2e_dependencies.py
git commit -m "feat(testing): add Maven E2E bundle importer"
```

### Task 5: Build and offline-verify the Maven bundle

**Files:**
- Create: `testing/hack/prepare-maven-e2e-bundle.sh`
- Create: `testing/nexus-e2e/unit/test_prepare_maven_e2e_bundle.py`

- [ ] **Step 1: Write failing bundle-script contract tests**

Create `testing/nexus-e2e/unit/test_prepare_maven_e2e_bundle.py`:

```python
import subprocess
from pathlib import Path


SCRIPT = Path(__file__).parents[2] / "hack/prepare-maven-e2e-bundle.sh"


def test_bundle_script_requires_source_and_destination():
    result = subprocess.run(
        ["bash", str(SCRIPT)], text=True, capture_output=True
    )
    assert result.returncode != 0
    assert "usage:" in result.stderr.lower()


def test_bundle_script_filters_resolver_state_and_generated_snapshot():
    content = SCRIPT.read_text()
    assert "_remote.repositories" in content
    assert "*.lastUpdated" in content
    assert "resolver-status.properties" in content
    assert "com/nexus/test/test-publish" in content
    assert "mvn -o" in content or "--offline" in content
```

- [ ] **Step 2: Run the tests and verify RED**

Run:

```bash
cd testing/nexus-e2e
python -m pytest unit/test_prepare_maven_e2e_bundle.py -q
```

Expected: tests fail because the script does not exist.

- [ ] **Step 3: Implement the bundle preparation script**

Create `testing/hack/prepare-maven-e2e-bundle.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <maven-project-directory> <bundle-directory>" >&2
  exit 2
fi

project_dir=$1
bundle_dir=$2
repository_dir="${bundle_dir}/repository"
deployment_dir="${bundle_dir}/deployment"
settings_file="${bundle_dir}/settings.xml"

rm -rf "${bundle_dir}"
mkdir -p "${repository_dir}" "${deployment_dir}"

cat > "${settings_file}" <<EOF
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0">
  <localRepository>${repository_dir}</localRepository>
</settings>
EOF

mvn -B -s "${settings_file}" -f "${project_dir}/publish.xml" \
  -DaltDeploymentRepository="bundle::default::file://${deployment_dir}" \
  clean deploy
mvn -B -s "${settings_file}" -f "${project_dir}/download.xml" package

mvn -B -o -s "${settings_file}" -f "${project_dir}/publish.xml" \
  -DaltDeploymentRepository="bundle::default::file://${deployment_dir}" \
  clean deploy
mvn -B -o -s "${settings_file}" -f "${project_dir}/download.xml" package

find "${repository_dir}" -type f \( \
  -name '_remote.repositories' -o \
  -name '*.lastUpdated' -o \
  -name 'resolver-status.properties' \
\) -delete
rm -rf "${repository_dir}/com/nexus/test/test-publish"
rm -rf "${deployment_dir}" "${settings_file}"

if ! find "${repository_dir}" -type f -name 'junit-4.11.jar' -print -quit | grep -q .; then
  echo "bundle verification failed: junit-4.11.jar is absent" >&2
  exit 1
fi
```

- [ ] **Step 4: Run contract tests and verify GREEN**

Run:

```bash
chmod 755 testing/hack/prepare-maven-e2e-bundle.sh
cd testing/nexus-e2e
python -m pytest unit/test_prepare_maven_e2e_bundle.py -q
```

Expected: `2 passed`.

- [ ] **Step 5: Run a real isolated online/offline bundle build**

Run from the repository root:

```bash
bundle_tmp=$(mktemp -d)
testing/hack/prepare-maven-e2e-bundle.sh \
  testing/nexus-e2e/test_projects/maven "${bundle_tmp}/bundle"
find "${bundle_tmp}/bundle/repository" -type f | sort
```

Expected: the script exits 0 after both offline Maven commands; the listing
contains `junit/junit/4.11/junit-4.11.jar` and
`org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar`, contains required Maven
plugin artifacts, and contains none of the filtered resolver-state files or
`com/nexus/test/test-publish`.

Keep the temporary directory until Task 6 image inspection is complete, then
remove only that exact `mktemp` directory.

- [ ] **Step 6: Commit the bundle builder**

```bash
git add testing/hack/prepare-maven-e2e-bundle.sh \
  testing/nexus-e2e/unit/test_prepare_maven_e2e_bundle.py
git commit -m "feat(testing): prepare verified Maven E2E dependency bundle"
```

### Task 6: Package the bundle and importer in the testing image

**Files:**
- Modify: `testing/Containerfile:1-108`

- [ ] **Step 1: Write a failing Containerfile contract test**

Append to `testing/nexus-e2e/unit/test_prepare_maven_e2e_bundle.py`:

```python
def test_containerfile_packages_bundle_and_importer():
    containerfile = SCRIPT.parents[1] / "Containerfile"
    content = containerfile.read_text()
    assert "prepare-maven-e2e-bundle.sh" in content
    assert "/opt/nexus-e2e/maven-repository" in content
    assert "/usr/local/bin/import-maven-e2e-dependencies" in content
```

- [ ] **Step 2: Run the contract test and verify RED**

Run:

```bash
cd testing/nexus-e2e
python -m pytest unit/test_prepare_maven_e2e_bundle.py \
  -k containerfile -q
```

Expected: FAIL because the Containerfile has none of the three integration
paths.

- [ ] **Step 3: Add a Maven bundle build stage**

Refactor the Maven download so Maven is available to a new `maven-bundle`
stage, or add a dedicated stage based on the final Python/JDK base. The stage
must:

```dockerfile
COPY testing/nexus-e2e/test_projects/maven /work/maven-project
COPY testing/hack/prepare-maven-e2e-bundle.sh /usr/local/bin/
RUN /usr/local/bin/prepare-maven-e2e-bundle.sh \
    /work/maven-project /opt/nexus-e2e
```

Use the same `MAVEN_VERSION=3.9.14` and trusted build-time mirror convention as
the final image. Do not copy `.m2` from a developer or prior build context.

- [ ] **Step 4: Copy assets into the final image**

Add to the final stage:

```dockerfile
COPY --from=maven-bundle /opt/nexus-e2e/maven-repository \
    /opt/nexus-e2e/maven-repository
COPY testing/hack/import-maven-e2e-dependencies.py \
    /usr/local/bin/import-maven-e2e-dependencies
RUN chmod 755 /usr/local/bin/import-maven-e2e-dependencies && \
    test -f /opt/nexus-e2e/maven-repository/junit/junit/4.11/junit-4.11.jar
```

Do not change the existing `ENTRYPOINT ["nexus.test"]` or `CMD`.

- [ ] **Step 5: Run Containerfile contract tests and build the image**

Run:

```bash
cd testing/nexus-e2e
python -m pytest unit/test_prepare_maven_e2e_bundle.py -q
cd ../../
docker build -f testing/Containerfile -t nexus-e2e-maven-bundle:test .
```

Expected: tests pass and the image build exits 0, including the offline Maven
verification layer. If Docker is unavailable, run the repository's supported
Containerfile builder and record the exact limitation rather than claiming the
image was built.

- [ ] **Step 6: Inspect the built image as non-root**

Run:

```bash
docker run --rm --user 65532 --entrypoint /bin/sh \
  nexus-e2e-maven-bundle:test -c \
  'test -r /opt/nexus-e2e/maven-repository/junit/junit/4.11/junit-4.11.jar && \
   test -x /usr/local/bin/import-maven-e2e-dependencies && \
   /usr/local/bin/import-maven-e2e-dependencies --help >/dev/null'
```

Expected: exit 0 with no credential prompts.

- [ ] **Step 7: Commit image integration**

```bash
git add testing/Containerfile \
  testing/nexus-e2e/unit/test_prepare_maven_e2e_bundle.py
git commit -m "feat(testing): package Maven E2E dependencies in test image"
```

### Task 7: Document usage and run complete verification

**Files:**
- Modify: `testing/README.md:10-45`

- [ ] **Step 1: Add import and proxy usage documentation**

Add a section containing these commands, using placeholders rather than real
credentials:

```bash
docker run --rm \
  --entrypoint /usr/local/bin/import-maven-e2e-dependencies \
  -e MAVEN_UPSTREAM_URL=https://upstream-nexus.example \
  -e MAVEN_UPSTREAM_REPOSITORY=maven-e2e-external \
  -e MAVEN_UPSTREAM_USERNAME=admin \
  -e MAVEN_UPSTREAM_PASSWORD \
  "${TESTING_IMAGE}"
```

Document that `MAVEN_UPSTREAM_REPOSITORY` defaults to
`maven-e2e-external`, that the password should be injected by the runtime or
secret store, and that the same four variables must be present for the Maven
proxy E2E test. Explain the two Nexus roles and retain the legacy
`MACVEN_MIRROR_REGISTRY` note.

- [ ] **Step 2: Run the complete Python unit suite**

Run:

```bash
cd testing/nexus-e2e
python -m pytest unit -q
```

Expected: all unit tests pass with zero failures.

- [ ] **Step 3: Run repository-level static verification**

Run:

```bash
git diff --check
bash -n testing/hack/prepare-maven-e2e-bundle.sh
python -m py_compile \
  testing/hack/import-maven-e2e-dependencies.py \
  testing/nexus-e2e/libs/maven_upstream.py \
  testing/nexus-e2e/libs/nexus_client.py \
  testing/nexus-e2e/test_maven_repo.py
```

Expected: every command exits 0 with no syntax errors or whitespace errors.

- [ ] **Step 4: Run existing Go test compilation**

Run:

```bash
cd testing
go test ./...
```

Expected: exit 0. If this suite requires an external test environment, run
`go test -run '^$' ./...` to prove compilation and report the environment-bound
tests separately.

- [ ] **Step 5: Run two-Nexus acceptance when disposable instances are available**

With `NEXUS_PASSWORD` and `MAVEN_UPSTREAM_PASSWORD` already loaded from the
approved secret store (without shell tracing), import the built image bundle
into the upstream Nexus, then run:

```bash
cd testing/nexus-e2e
NEXUS_URL=https://tested-nexus.example \
NEXUS_USERNAME=admin \
MAVEN_UPSTREAM_URL=https://upstream-nexus.example \
MAVEN_UPSTREAM_REPOSITORY=maven-e2e-external \
MAVEN_UPSTREAM_USERNAME=reader \
python -m pytest test_maven_repo.py -k test_maven_proxy -q
```

Expected: `test_maven_proxy` passes; the tested Nexus reports the JUnit artifact
in its `maven-central` cache. Do not run this step without explicit target
instances and credentials. If they are unavailable, report this acceptance
step as outstanding.

- [ ] **Step 6: Commit documentation**

```bash
git add testing/README.md
git commit -m "docs(testing): explain authenticated Maven E2E upstream"
```

- [ ] **Step 7: Review requirements and final diff**

Run:

```bash
git status --short
git log --oneline --decorate -8
git diff HEAD~6 --stat
```

Confirm that the diff contains only the planned testing image, importer,
upstream authentication, tests, and documentation changes. Verify that no URL
contains embedded credentials and no secret-bearing local file is tracked.
