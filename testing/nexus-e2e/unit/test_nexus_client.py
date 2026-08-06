import pytest

from libs.nexus_client import NexusClient, _get_repository_config


def test_proxy_config_includes_remote_authentication():
    config = _get_repository_config(
        "maven",
        "authenticated-proxy",
        repo_type="proxy",
        remote_url="https://maven.example.test/repository/releases/",
        remote_username="reader",
        remote_password="upstream-secret",
    )

    assert config["httpClient"]["authentication"] == {
        "type": "username",
        "username": "reader",
        "password": "upstream-secret",
    }


def test_proxy_config_without_credentials_omits_authentication():
    config = _get_repository_config(
        "maven",
        "anonymous-proxy",
        repo_type="proxy",
        remote_url="https://repo.maven.apache.org/maven2/",
    )

    assert "authentication" not in config["httpClient"]


@pytest.mark.parametrize(
    ("remote_username", "remote_password"),
    [("reader", None), (None, "upstream-secret")],
)
def test_proxy_config_rejects_partial_credentials_without_exposing_password(
    remote_username, remote_password
):
    with pytest.raises(ValueError) as exc_info:
        _get_repository_config(
            "maven",
            "invalid-proxy",
            repo_type="proxy",
            remote_url="https://maven.example.test/repository/releases/",
            remote_username=remote_username,
            remote_password=remote_password,
        )

    assert "upstream-secret" not in str(exc_info.value)
    assert "upstream-secret" not in repr(exc_info.value)


def test_update_proxy_config_sends_remote_authentication_without_changing_session_auth(
    monkeypatch,
):
    client = NexusClient("https://nexus.example.test/base/", "admin", "nexus-secret")
    original_auth = client.session.auth
    request = {}

    class FakeResponse:
        def raise_for_status(self):
            return None

    def fake_put(url, json):
        request.update(url=url, json=json)
        return FakeResponse()

    monkeypatch.setattr(client.session, "put", fake_put)

    client.update_proxy_config(
        "maven",
        "authenticated-proxy",
        remote_url="https://maven.example.test/repository/releases/",
        remote_username="reader",
        remote_password="upstream-secret",
    )

    assert request["url"] == (
        "https://nexus.example.test/base/service/rest/v1/repositories/"
        "maven/proxy/authenticated-proxy"
    )
    assert request["json"]["httpClient"]["authentication"] == {
        "type": "username",
        "username": "reader",
        "password": "upstream-secret",
    }
    assert client.session.auth == original_auth == ("admin", "nexus-secret")
