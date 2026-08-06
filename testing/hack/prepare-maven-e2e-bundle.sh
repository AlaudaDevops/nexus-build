#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: $0 <maven-project-directory> <bundle-directory>" >&2
}

fail() {
  echo "Error: $*" >&2
  exit 1
}

canonical_path() {
  local path=$1
  mkdir -p -- "$path"
  cd -- "$path"
  pwd -P
}

xml_escape() {
  sed \
    -e 's/&/\&amp;/g' \
    -e 's/</\&lt;/g' \
    -e 's/>/\&gt;/g' \
    -e 's/"/\&quot;/g' \
    -e "s/'/\\\&apos;/g"
}

manage_bundle() {
  local operation=$1
  python3 - "$bundle" "$operation" <<'PY'
import os
import shutil
import stat
import sys

bundle, operation = sys.argv[1:]
flags = os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW


def remove_entry(parent_fd, name):
    try:
        info = os.lstat(name, dir_fd=parent_fd)
    except FileNotFoundError:
        return
    if stat.S_ISLNK(info.st_mode):
        raise RuntimeError(f"unsafe symlink in bundle: {name}")
    if stat.S_ISDIR(info.st_mode):
        shutil.rmtree(name, dir_fd=parent_fd)
    else:
        os.unlink(name, dir_fd=parent_fd)


def open_directory(parent_fd, name):
    return os.open(name, flags, dir_fd=parent_fd)


def remove_relative_tree(root_fd, parts):
    opened = []
    parent_fd = root_fd
    try:
        for part in parts[:-1]:
            try:
                parent_fd = open_directory(parent_fd, part)
            except FileNotFoundError:
                return
            opened.append(parent_fd)
        remove_entry(parent_fd, parts[-1])
    finally:
        for descriptor in reversed(opened):
            os.close(descriptor)


def filter_metadata(directory_fd):
    with os.scandir(directory_fd) as entries:
        for entry in entries:
            info = entry.stat(follow_symlinks=False)
            if stat.S_ISLNK(info.st_mode):
                raise RuntimeError(f"unsafe symlink in Maven repository: {entry.name}")
            if stat.S_ISDIR(info.st_mode):
                child_fd = open_directory(directory_fd, entry.name)
                try:
                    filter_metadata(child_fd)
                finally:
                    os.close(child_fd)
            elif entry.name == "_remote.repositories" or entry.name == "resolver-status.properties" or entry.name.endswith(".lastUpdated"):
                os.unlink(entry.name, dir_fd=directory_fd)


def verify_regular_file(root_fd, relative):
    parts = relative.split("/")
    opened = []
    parent_fd = root_fd
    try:
        for part in parts[:-1]:
            parent_fd = open_directory(parent_fd, part)
            opened.append(parent_fd)
        info = os.stat(parts[-1], dir_fd=parent_fd, follow_symlinks=False)
        if not stat.S_ISREG(info.st_mode):
            raise RuntimeError(f"missing or unsafe representative artifact: {relative}")
    finally:
        for descriptor in reversed(opened):
            os.close(descriptor)


bundle_fd = os.open(bundle, flags)
try:
    if operation == "reset":
        for child in ("repository", "deployment", "settings.xml"):
            remove_entry(bundle_fd, child)
        os.mkdir("repository", dir_fd=bundle_fd)
        os.mkdir("deployment", dir_fd=bundle_fd)
    elif operation == "finalize":
        repository_fd = open_directory(bundle_fd, "repository")
        try:
            filter_metadata(repository_fd)
            remove_relative_tree(repository_fd, ["com", "nexus", "test", "test-publish"])
            for artifact in (
                "junit/junit/4.11/junit-4.11.jar",
                "org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar",
                "org/apache/maven/plugins/maven-deploy-plugin/2.8.2/maven-deploy-plugin-2.8.2.jar",
                "org/apache/maven/plugins/maven-deploy-plugin/2.8.2/maven-deploy-plugin-2.8.2.pom",
            ):
                verify_regular_file(repository_fd, artifact)
        finally:
            os.close(repository_fd)
        remove_entry(bundle_fd, "deployment")
        remove_entry(bundle_fd, "settings.xml")
    else:
        raise RuntimeError(f"unknown bundle operation: {operation}")
finally:
    os.close(bundle_fd)
PY
}

if [[ $# -ne 2 ]]; then
  usage
  exit 2
fi

project_input=$1
bundle_input=$2

[[ -d "$project_input" ]] || fail "Maven project directory does not exist: $project_input"
[[ -f "$project_input/publish.xml" ]] || fail "Maven project is missing publish.xml"
[[ -f "$project_input/download.xml" ]] || fail "Maven project is missing download.xml"
[[ -n "$bundle_input" ]] || fail "unsafe empty bundle directory"
bundle_probe=$bundle_input
while [[ "$bundle_probe" != "/" && "$bundle_probe" == */ ]]; do
  bundle_probe=${bundle_probe%/}
done
[[ ! -L "$bundle_probe" ]] || fail "unsafe symlink bundle directory: $bundle_input"

project=$(cd -- "$project_input" && pwd -P)
bundle=$(canonical_path "$bundle_input")
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source_root=$(cd -- "$script_dir/../.." && pwd -P)
case "$bundle" in
  /|"$project"|"$source_root") fail "unsafe bundle directory: $bundle" ;;
esac

repository="$bundle/repository"
deployment="$bundle/deployment"
settings="$bundle/settings.xml"

manage_bundle reset

mirror_url=${MAVEN_BUNDLE_MIRROR_URL:-${MACVEN_MIRROR_REGISTRY:-https://artifacts.alauda.io/repository/maven-central}}
[[ "$mirror_url" != *$'\n'* && "$mirror_url" != *$'\r'* ]] || fail "mirror URL contains a newline"
escaped_repository=$(printf '%s' "$repository" | xml_escape)
escaped_mirror=$(printf '%s' "$mirror_url" | xml_escape)

{
  printf '%s\n' '<?xml version="1.0" encoding="UTF-8"?>'
  printf '%s\n' '<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">'
  printf '  <localRepository>%s</localRepository>\n' "$escaped_repository"
  printf '%s\n' '  <mirrors>' '    <mirror>' '      <id>bundle-central</id>' '      <mirrorOf>central</mirrorOf>'
  printf '      <url>%s</url>\n' "$escaped_mirror"
  printf '%s\n' '    </mirror>' '  </mirrors>' '</settings>'
} >"$settings"

common_args=(-s "$settings" "-Dmaven.repo.local=$repository")
deploy_url="file://$deployment"

mvn "${common_args[@]}" -f "$project/publish.xml" \
  "-DaltDeploymentRepository=bundle::default::$deploy_url" clean deploy
mvn "${common_args[@]}" -f "$project/download.xml" package
mvn -o "${common_args[@]}" -f "$project/publish.xml" clean install
mvn -o "${common_args[@]}" -f "$project/download.xml" package

manage_bundle finalize
