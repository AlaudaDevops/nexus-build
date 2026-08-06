#!/usr/bin/env python3
"""Import the Maven E2E dependency bundle into a Nexus repository."""

from __future__ import annotations

import argparse
import getpass
import os
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Mapping, Sequence, TextIO
from urllib.parse import quote, urlsplit

import requests


DEFAULT_BUNDLE = Path("/opt/nexus-e2e/maven-repository")
DEFAULT_REPOSITORY = "maven-e2e-external"
REPOSITORY_NAME = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]*$")
REPRESENTATIVE_ARTIFACTS = (
    "junit/junit/4.11/junit-4.11.jar",
    "org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar",
    "org/apache/maven/plugins/maven-deploy-plugin/2.8.2/maven-deploy-plugin-2.8.2.jar",
    "org/apache/maven/plugins/maven-deploy-plugin/2.8.2/maven-deploy-plugin-2.8.2.pom",
)
HTTP_TIMEOUT = 60
COMPARE_CHUNK_SIZE = 64 * 1024


class ImportError(RuntimeError):
    """A safe-to-display import failure."""


@dataclass(frozen=True)
class ImportConfig:
    base_url: str
    repository: str
    username: str
    password: str = field(repr=False)
    bundle: Path = DEFAULT_BUNDLE

    @property
    def repository_url(self) -> str:
        return f"{self.base_url}/repository/{self.repository}"


@dataclass(frozen=True)
class ImportResult:
    uploaded: int
    skipped: int
    failed: int


def load_config(
    argv: Sequence[str] | None = None,
    environ: Mapping[str, str] | None = None,
) -> ImportConfig:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bundle", type=Path, default=DEFAULT_BUNDLE)
    args = parser.parse_args(argv)
    values = os.environ if environ is None else environ

    base_url = values.get("MAVEN_UPSTREAM_URL", "").strip().rstrip("/")
    parsed = urlsplit(base_url)
    if (
        parsed.scheme not in {"http", "https"}
        or not parsed.netloc
        or parsed.username is not None
        or parsed.password is not None
        or parsed.query
        or parsed.fragment
    ):
        raise ImportError("MAVEN_UPSTREAM_URL must be an http or https URL")

    repository = values.get("MAVEN_UPSTREAM_REPOSITORY", DEFAULT_REPOSITORY).strip()
    if not REPOSITORY_NAME.fullmatch(repository):
        raise ImportError("MAVEN_UPSTREAM_REPOSITORY contains invalid characters")

    username = values.get("MAVEN_UPSTREAM_USERNAME", "").strip()
    if not username:
        raise ImportError("MAVEN_UPSTREAM_USERNAME is required")
    password = values.get("MAVEN_UPSTREAM_PASSWORD", "")
    if not password:
        password = getpass.getpass("Maven upstream password: ")
    if not password:
        raise ImportError("MAVEN_UPSTREAM_PASSWORD is required")
    return ImportConfig(base_url, repository, username, password, args.bundle)


def _check_response(response, expected: set[int], operation: str, safe_url: str) -> None:
    if response.status_code in expected:
        return
    if response.status_code in {401, 403}:
        raise ImportError(
            f"authentication/authorization failed during {operation} "
            f"for {safe_url} (HTTP {response.status_code})"
        )
    if response.status_code >= 400:
        raise ImportError(f"{operation} failed for {safe_url} (HTTP {response.status_code})")
    raise ImportError(f"unexpected response during {operation} for {safe_url} (HTTP {response.status_code})")


def _request(session, method: str, url: str, **kwargs):
    return session.request(
        method,
        url,
        timeout=HTTP_TIMEOUT,
        allow_redirects=False,
        **kwargs,
    )


def _ensure_repository(config: ImportConfig, session) -> None:
    api_url = f"{config.base_url}/service/rest/v1/repositories"
    response = _request(session, "GET", api_url)
    _check_response(response, {200}, "repository lookup", api_url)
    repositories = response.json()
    existing = next((item for item in repositories if item.get("name") == config.repository), None)
    if existing:
        if existing.get("format") not in {"maven", "maven2"} or existing.get("type") != "hosted":
            raise ImportError(f"repository {config.repository!r} is incompatible; expected hosted Maven")
        return

    create_url = f"{api_url}/maven/hosted"
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
    response = _request(session, "POST", create_url, json=payload)
    _check_response(response, {201, 204}, "repository creation", create_url)


def _artifact_url(config: ImportConfig, relative: str) -> str:
    return f"{config.repository_url}/{quote(relative, safe='/')}"


def _is_regular_file(path: Path) -> bool:
    return path.is_file() and not path.is_symlink()


def _response_matches_file(response, path: Path) -> bool:
    try:
        with path.open("rb") as local:
            for remote_chunk in response.iter_content(chunk_size=COMPARE_CHUNK_SIZE):
                if remote_chunk and local.read(len(remote_chunk)) != remote_chunk:
                    return False
            return local.read(1) == b""
    finally:
        response.close()


def import_bundle(config: ImportConfig, session=None) -> ImportResult:
    missing = [
        item for item in REPRESENTATIVE_ARTIFACTS if not _is_regular_file(config.bundle / item)
    ]
    if missing:
        raise ImportError("bundle is missing representative artifacts: " + ", ".join(missing))

    client = requests.Session() if session is None else session
    client.auth = (config.username, config.password)
    _ensure_repository(config, client)

    uploaded = skipped = failed = 0
    for path in sorted(item for item in config.bundle.rglob("*") if _is_regular_file(item)):
        relative = path.relative_to(config.bundle).as_posix()
        url = _artifact_url(config, relative)
        response = _request(client, "GET", url, stream=True)
        if response.status_code == 404:
            response.close()
            with path.open("rb") as local:
                upload = _request(client, "PUT", url, data=local)
                _check_response(upload, {200, 201, 204}, "artifact upload", url)
            uploaded += 1
        elif response.status_code == 200:
            if _response_matches_file(response, path):
                skipped += 1
            else:
                failed += 1
        else:
            try:
                _check_response(response, {200, 404}, "artifact lookup", url)
            finally:
                response.close()

    for relative in REPRESENTATIVE_ARTIFACTS:
        url = _artifact_url(config, relative)
        response = _request(client, "GET", url, stream=True)
        if response.status_code != 200:
            try:
                _check_response(response, {200}, "artifact verification", url)
            finally:
                response.close()
        if not _response_matches_file(response, config.bundle / relative):
            raise ImportError(f"artifact verification failed for {url}")
    return ImportResult(uploaded, skipped, failed)


def main(argv: Sequence[str] | None = None, *, output: TextIO = sys.stdout) -> int:
    try:
        config = load_config(argv)
        result = import_bundle(config)
    except (ImportError, requests.RequestException, OSError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    print(config.repository_url, file=output)
    print(
        f"uploaded={result.uploaded} skipped={result.skipped} failed={result.failed}",
        file=output,
    )
    return 1 if result.failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
