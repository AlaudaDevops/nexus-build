import re
from dataclasses import dataclass, field
from typing import Mapping, Optional
from urllib.parse import urlsplit


DEFAULT_REPOSITORY = "maven-e2e-external"
DEFAULT_MAVEN_MIRROR = "https://artifacts.alauda.io/repository/maven-central"


@dataclass(frozen=True)
class MavenProxyRemote:
    url: str
    username: Optional[str] = None
    password: Optional[str] = field(default=None, repr=False)


@dataclass(frozen=True)
class MavenUpstreamConfig:
    url: str
    repository: str
    username: str
    password: str = field(repr=False)

    @property
    def repository_url(self) -> str:
        return f"{self.url}/repository/{self.repository}/"


def load_maven_upstream(
    environment: Mapping[str, str],
) -> Optional[MavenUpstreamConfig]:
    url = environment.get("MAVEN_UPSTREAM_URL", "").strip().rstrip("/")
    if not url:
        return None

    try:
        parsed_url = urlsplit(url)
        invalid_url = (
            parsed_url.scheme not in {"http", "https"}
            or not parsed_url.netloc
            or parsed_url.username is not None
            or parsed_url.password is not None
            or parsed_url.query
            or parsed_url.fragment
        )
    except ValueError:
        invalid_url = True
    if invalid_url:
        raise ValueError("MAVEN_UPSTREAM_URL must be an HTTP(S) base URL")

    repository = environment.get(
        "MAVEN_UPSTREAM_REPOSITORY", DEFAULT_REPOSITORY
    ).strip()
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]*", repository):
        raise ValueError("MAVEN_UPSTREAM_REPOSITORY contains invalid characters")

    username = environment.get("MAVEN_UPSTREAM_USERNAME", "")
    if not username:
        raise ValueError("MAVEN_UPSTREAM_USERNAME is required when MAVEN_UPSTREAM_URL is set")

    password = environment.get("MAVEN_UPSTREAM_PASSWORD", "")
    if not password:
        raise ValueError("MAVEN_UPSTREAM_PASSWORD is required when MAVEN_UPSTREAM_URL is set")

    return MavenUpstreamConfig(
        url=url,
        repository=repository,
        username=username,
        password=password,
    )


def select_proxy_remote(environment: Mapping[str, str]) -> MavenProxyRemote:
    upstream = load_maven_upstream(environment)
    if upstream is not None:
        return MavenProxyRemote(
            url=upstream.repository_url,
            username=upstream.username,
            password=upstream.password,
        )

    legacy_url = environment.get("MACVEN_MIRROR_REGISTRY", "").strip()
    if not legacy_url:
        legacy_url = DEFAULT_MAVEN_MIRROR
    return MavenProxyRemote(url=f"{legacy_url.rstrip('/')}/")
