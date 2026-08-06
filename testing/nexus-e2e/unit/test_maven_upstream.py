import pytest
from libs import maven_upstream

from libs.maven_upstream import (
    DEFAULT_REPOSITORY,
    MavenUpstreamConfig,
    load_maven_upstream,
)


def test_loads_default_repository_and_normalizes_url():
    config = load_maven_upstream(
        {
            "MAVEN_UPSTREAM_URL": "  https://maven.example.test///  ",
            "MAVEN_UPSTREAM_USERNAME": "reader",
            "MAVEN_UPSTREAM_PASSWORD": "secret",
        }
    )

    assert config == MavenUpstreamConfig(
        url="https://maven.example.test",
        repository=DEFAULT_REPOSITORY,
        username="reader",
        password="secret",
    )
    assert config.repository_url == (
        "https://maven.example.test/repository/maven-e2e-external/"
    )


def test_allows_repository_override():
    config = load_maven_upstream(
        {
            "MAVEN_UPSTREAM_URL": "https://maven.example.test",
            "MAVEN_UPSTREAM_REPOSITORY": "  custom-repository  ",
            "MAVEN_UPSTREAM_USERNAME": "reader",
            "MAVEN_UPSTREAM_PASSWORD": "secret",
        }
    )

    assert config.repository == "custom-repository"
    assert config.repository_url.endswith("/repository/custom-repository/")


def test_password_is_excluded_from_repr():
    config = MavenUpstreamConfig(
        url="https://maven.example.test",
        repository=DEFAULT_REPOSITORY,
        username="reader",
        password="secret",
    )

    assert "secret" not in repr(config)


def test_authenticated_upstream_takes_priority_over_legacy_mirror():
    remote = maven_upstream.select_proxy_remote(
        {
            "MAVEN_UPSTREAM_URL": "https://maven.example.test",
            "MAVEN_UPSTREAM_REPOSITORY": "private-proxy",
            "MAVEN_UPSTREAM_USERNAME": "reader",
            "MAVEN_UPSTREAM_PASSWORD": "secret",
            "MACVEN_MIRROR_REGISTRY": "https://legacy.example.test",
        }
    )

    assert remote == maven_upstream.MavenProxyRemote(
        url="https://maven.example.test/repository/private-proxy/",
        username="reader",
        password="secret",
    )


def test_uses_legacy_mirror_override_and_normalizes_trailing_slash():
    remote = maven_upstream.select_proxy_remote(
        {"MACVEN_MIRROR_REGISTRY": "https://legacy.example.test///"}
    )

    assert remote == maven_upstream.MavenProxyRemote(url="https://legacy.example.test/")


def test_uses_default_legacy_mirror():
    remote = maven_upstream.select_proxy_remote({})

    assert remote == maven_upstream.MavenProxyRemote(
        url="https://artifacts.alauda.io/repository/maven-central/"
    )


def test_proxy_remote_password_is_excluded_from_repr():
    remote = maven_upstream.MavenProxyRemote(
        url="https://maven.example.test/repository/private-proxy/",
        username="reader",
        password="secret",
    )

    assert "secret" not in repr(remote)


@pytest.mark.parametrize(
    ("missing_variable", "environment"),
    [
        (
            "MAVEN_UPSTREAM_USERNAME",
            {
                "MAVEN_UPSTREAM_URL": "https://maven.example.test",
                "MAVEN_UPSTREAM_PASSWORD": "secret",
            },
        ),
        (
            "MAVEN_UPSTREAM_PASSWORD",
            {
                "MAVEN_UPSTREAM_URL": "https://maven.example.test",
                "MAVEN_UPSTREAM_USERNAME": "reader",
            },
        ),
    ],
)
def test_requires_credentials_when_url_is_set(missing_variable, environment):
    with pytest.raises(ValueError, match=missing_variable):
        load_maven_upstream(environment)


def test_returns_none_without_url():
    assert load_maven_upstream({}) is None
    assert load_maven_upstream({"MAVEN_UPSTREAM_URL": ""}) is None


@pytest.mark.parametrize(
    "url",
    [
        "ftp://maven.example.test",
        "maven.example.test",
        "https://reader:secret@maven.example.test",
        "https://maven.example.test?token=secret",
        "https://maven.example.test#secret",
        "https://[secret",
    ],
)
def test_rejects_invalid_upstream_url_without_echoing_input(url):
    with pytest.raises(ValueError) as error:
        load_maven_upstream(
            {
                "MAVEN_UPSTREAM_URL": url,
                "MAVEN_UPSTREAM_USERNAME": "reader",
                "MAVEN_UPSTREAM_PASSWORD": "secret",
            }
        )

    assert str(error.value) == "MAVEN_UPSTREAM_URL must be an HTTP(S) base URL"
    assert url not in str(error.value)
    assert "secret" not in str(error.value)


def test_allows_upstream_url_with_base_path_and_port():
    config = load_maven_upstream(
        {
            "MAVEN_UPSTREAM_URL": " http://maven.example.test:8081/nexus/ ",
            "MAVEN_UPSTREAM_USERNAME": "reader",
            "MAVEN_UPSTREAM_PASSWORD": "secret",
        }
    )

    assert config.url == "http://maven.example.test:8081/nexus"
    assert config.repository_url == (
        "http://maven.example.test:8081/nexus/repository/maven-e2e-external/"
    )


@pytest.mark.parametrize(
    "repository",
    ["", "   ", "nested/repository", "repository?query", "repository#fragment"],
)
def test_rejects_invalid_repository_name(repository):
    with pytest.raises(ValueError, match="MAVEN_UPSTREAM_REPOSITORY"):
        load_maven_upstream(
            {
                "MAVEN_UPSTREAM_URL": "https://maven.example.test",
                "MAVEN_UPSTREAM_REPOSITORY": repository,
                "MAVEN_UPSTREAM_USERNAME": "reader",
                "MAVEN_UPSTREAM_PASSWORD": "secret",
            }
        )
