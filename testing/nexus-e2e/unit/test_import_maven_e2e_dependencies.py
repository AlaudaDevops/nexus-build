import importlib.util
import io
import sys
from pathlib import Path

import pytest


SCRIPT = Path(__file__).parents[2] / "hack" / "import-maven-e2e-dependencies.py"
TEST_REPRESENTATIVES = (
    "junit/junit/4.11/junit-4.11.jar",
    "org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar",
    "org/apache/maven/plugins/maven-deploy-plugin/2.8.2/maven-deploy-plugin-2.8.2.jar",
    "org/apache/maven/plugins/maven-deploy-plugin/2.8.2/maven-deploy-plugin-2.8.2.pom",
)
SPEC = importlib.util.spec_from_file_location("maven_bundle_importer", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)


class Response:
    def __init__(self, status=200, *, content=b"", json_data=None, url="https://nexus.test/x"):
        self.status_code = status
        self.content = content
        self._json = json_data
        self.url = url
        self.closed = False

    def json(self):
        return self._json

    def iter_content(self, chunk_size):
        for offset in range(0, len(self.content), chunk_size):
            yield self.content[offset:offset + chunk_size]

    def close(self):
        self.closed = True


class FakeSession:
    def __init__(self, responses):
        self.responses = list(responses)
        self.calls = []
        self.auth = None
        self.uploaded_data = []

    def _call(self, method, url, **kwargs):
        self.calls.append((method, url, kwargs))
        data = kwargs.get("data")
        if method == "PUT" and hasattr(data, "read"):
            self.uploaded_data.append(data.read())
            data.seek(0)
        return self.responses.pop(0)

    def get(self, url, **kwargs):
        return self._call("GET", url, **kwargs)

    def request(self, method, url, **kwargs):
        return self._call(method.upper(), url, **kwargs)

    def post(self, url, **kwargs):
        return self._call("POST", url, **kwargs)

    def put(self, url, **kwargs):
        return self._call("PUT", url, **kwargs)


def env(**updates):
    values = {
        "MAVEN_UPSTREAM_URL": " https://nexus.test/ ",
        "MAVEN_UPSTREAM_USERNAME": "alice",
        "MAVEN_UPSTREAM_PASSWORD": "secret-value",
    }
    values.update(updates)
    return values


def bundle(tmp_path):
    root = tmp_path / "bundle"
    artifacts = {
        "junit/junit/4.11/junit-4.11.jar": b"junit",
        "org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar": b"hamcrest",
        "org/apache/maven/plugins/maven-deploy-plugin/2.8.2/maven-deploy-plugin-2.8.2.jar": b"deploy-jar",
        "org/apache/maven/plugins/maven-deploy-plugin/2.8.2/maven-deploy-plugin-2.8.2.pom": b"deploy-pom",
    }
    for relative, content in artifacts.items():
        path = root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(content)
    return root, artifacts


def scan_responses(artifacts):
    return [Response(200, content=artifacts[path]) for path in sorted(artifacts)]


def verification_responses(artifacts):
    return [Response(200, content=artifacts[path]) for path in TEST_REPRESENTATIVES]


def test_config_defaults_override_and_hidden_password(tmp_path):
    config = MODULE.load_config(["--bundle", str(tmp_path)], env())
    assert config.base_url == "https://nexus.test"
    assert config.repository == "maven-e2e-external"
    assert config.bundle == tmp_path
    assert config.repository_url == "https://nexus.test/repository/maven-e2e-external"
    assert "secret-value" not in repr(config)
    with pytest.raises(Exception):
        config.repository = "changed"


@pytest.mark.parametrize("url", ["", "ftp://nexus.test", "nexus.test"])
def test_config_rejects_missing_or_invalid_url(url):
    with pytest.raises(MODULE.ImportError):
        MODULE.load_config([], env(MAVEN_UPSTREAM_URL=url))


def test_config_rejects_credentials_embedded_in_url():
    with pytest.raises(MODULE.ImportError):
        MODULE.load_config([], env(MAVEN_UPSTREAM_URL="https://alice:url-secret@nexus.test"))


def test_config_rejects_invalid_repository_name():
    with pytest.raises(MODULE.ImportError):
        MODULE.load_config([], env(MAVEN_UPSTREAM_REPOSITORY="bad/name"))


def test_password_prompts_without_echo_when_environment_is_missing(monkeypatch):
    monkeypatch.setattr(MODULE.getpass, "getpass", lambda prompt: "prompt-secret")
    config = MODULE.load_config([], env(MAVEN_UPSTREAM_PASSWORD=""))
    assert config.password == "prompt-secret"


def test_username_and_prompted_password_are_required(monkeypatch):
    with pytest.raises(MODULE.ImportError, match="USERNAME"):
        MODULE.load_config([], env(MAVEN_UPSTREAM_USERNAME=""))
    monkeypatch.setattr(MODULE.getpass, "getpass", lambda prompt: "")
    with pytest.raises(MODULE.ImportError, match="PASSWORD"):
        MODULE.load_config([], env(MAVEN_UPSTREAM_PASSWORD=""))


def test_create_repository_payload_and_basic_auth(tmp_path):
    root, artifacts = bundle(tmp_path)
    session = FakeSession([
        Response(200, json_data=[]), Response(201),
        *[response for _ in sorted(artifacts) for response in (Response(404), Response(201))],
        *verification_responses(artifacts),
    ])
    result = MODULE.import_bundle(MODULE.load_config(["--bundle", str(root)], env()), session)
    assert session.auth == ("alice", "secret-value")
    post = next(call for call in session.calls if call[0] == "POST")
    assert post[2]["json"] == {
        "name": "maven-e2e-external", "online": True,
        "storage": {"blobStoreName": "default", "strictContentTypeValidation": True, "writePolicy": "ALLOW_ONCE"},
        "maven": {"versionPolicy": "MIXED", "layoutPolicy": "STRICT", "contentDisposition": "INLINE"},
    }
    assert result == MODULE.ImportResult(uploaded=4, skipped=0, failed=0)
    assert session.responses == []


def test_all_http_requests_disable_redirects_and_have_timeout(tmp_path):
    root, artifacts = bundle(tmp_path)
    session = FakeSession([
        Response(200, json_data=[]), Response(201),
        *[response for _ in sorted(artifacts) for response in (Response(404), Response(201))],
        *verification_responses(artifacts),
    ])

    MODULE.import_bundle(MODULE.load_config(["--bundle", str(root)], env()), session)

    assert {call[0] for call in session.calls} == {"GET", "POST", "PUT"}
    assert all(call[2]["timeout"] == 60 for call in session.calls)
    assert all(call[2]["allow_redirects"] is False for call in session.calls)
    artifact_gets = [call for call in session.calls if call[0] == "GET" and "/repository/" in call[1]]
    assert all(call[2]["stream"] is True for call in artifact_gets)
    put_calls = [call for call in session.calls if call[0] == "PUT"]
    assert all(hasattr(call[2]["data"], "read") for call in put_calls)
    assert all(call[2]["data"].closed for call in put_calls)
    assert session.uploaded_data == [artifacts[path] for path in sorted(artifacts)]


def test_artifact_upload_redirect_fails_without_counting_upload(tmp_path):
    root, _ = bundle(tmp_path)
    session = FakeSession([
        Response(200, json_data=[{"name": "maven-e2e-external", "format": "maven2", "type": "hosted"}]),
        Response(404), Response(302),
    ])

    with pytest.raises(MODULE.ImportError, match="unexpected|redirect"):
        MODULE.import_bundle(MODULE.load_config(["--bundle", str(root)], env()), session)

    assert len([call for call in session.calls if call[0] == "PUT"]) == 1


def test_reuses_compatible_repository_and_puts_relative_posix_path(tmp_path):
    root, artifacts = bundle(tmp_path)
    session = FakeSession([
        Response(200, json_data=[{"name": "maven-e2e-external", "format": "maven2", "type": "hosted"}]),
        *[response for _ in sorted(artifacts) for response in (Response(404), Response(204))],
        *verification_responses(artifacts),
    ])
    MODULE.import_bundle(MODULE.load_config(["--bundle", str(root)], env()), session)
    assert not any(call[0] == "POST" for call in session.calls)
    put_urls = [call[1] for call in session.calls if call[0] == "PUT"]
    assert "https://nexus.test/repository/maven-e2e-external/junit/junit/4.11/junit-4.11.jar" in put_urls


@pytest.mark.parametrize("repository", [
    {"name": "maven-e2e-external", "format": "raw", "type": "hosted"},
    {"name": "maven-e2e-external", "format": "maven2", "type": "proxy"},
])
def test_rejects_incompatible_repository_before_upload(tmp_path, repository):
    root, _ = bundle(tmp_path)
    session = FakeSession([Response(200, json_data=[repository])])
    with pytest.raises(MODULE.ImportError, match="incompatible"):
        MODULE.import_bundle(MODULE.load_config(["--bundle", str(root)], env()), session)
    assert not any(call[0] == "PUT" for call in session.calls)


def test_identical_is_skipped_and_different_is_conflict(tmp_path):
    root, artifacts = bundle(tmp_path)
    session = FakeSession([
        Response(200, json_data=[{"name": "maven-e2e-external", "format": "maven", "type": "hosted"}]),
        *[
            Response(200, content=b"different" if "hamcrest-core" in relative else artifacts[relative])
            for relative in sorted(artifacts)
        ],
        *verification_responses(artifacts),
    ])
    result = MODULE.import_bundle(MODULE.load_config(["--bundle", str(root)], env()), session)
    assert result == MODULE.ImportResult(uploaded=0, skipped=3, failed=1)
    assert not any(call[0] == "PUT" for call in session.calls)
    artifact_gets = [call[1] for call in session.calls if call[0] == "GET"][1:]
    assert artifact_gets.count(
        "https://nexus.test/repository/maven-e2e-external/junit/junit/4.11/junit-4.11.jar"
    ) == 2
    assert artifact_gets.count(
        "https://nexus.test/repository/maven-e2e-external/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar"
    ) == 2


def test_symlinked_file_is_not_imported(tmp_path):
    root, artifacts = bundle(tmp_path)
    outside = tmp_path / "outside.jar"
    outside.write_bytes(b"outside")
    (root / "linked.jar").symlink_to(outside)
    session = FakeSession([
        Response(200, json_data=[{"name": "maven-e2e-external", "format": "maven2", "type": "hosted"}]),
        *scan_responses(artifacts),
        *verification_responses(artifacts),
    ])

    result = MODULE.import_bundle(MODULE.load_config(["--bundle", str(root)], env()), session)

    assert result == MODULE.ImportResult(uploaded=0, skipped=4, failed=0)
    assert all("linked.jar" not in call[1] for call in session.calls)


@pytest.mark.parametrize("status", [401, 403])
def test_authentication_errors_are_sanitized(tmp_path, status):
    root, _ = bundle(tmp_path)
    session = FakeSession([Response(status, url="https://alice:secret-value@nexus.test/service/rest/v1/repositories")])
    with pytest.raises(MODULE.ImportError) as caught:
        MODULE.import_bundle(MODULE.load_config(["--bundle", str(root)], env()), session)
    message = str(caught.value)
    assert "authentication/authorization" in message
    assert "secret-value" not in message
    assert "Authorization" not in message
    assert "alice:" not in message


def test_missing_representative_artifact_fails_before_network(tmp_path):
    root = tmp_path / "bundle"
    root.mkdir()
    session = FakeSession([])
    with pytest.raises(MODULE.ImportError, match="missing representative"):
        MODULE.import_bundle(MODULE.load_config(["--bundle", str(root)], env()), session)
    assert session.calls == []


def test_missing_lifecycle_plugin_fails_before_network(tmp_path):
    root, _ = bundle(tmp_path)
    plugin = root / "org/apache/maven/plugins/maven-deploy-plugin/2.8.2/maven-deploy-plugin-2.8.2.jar"
    plugin.unlink()
    session = FakeSession([])

    with pytest.raises(MODULE.ImportError, match="maven-deploy-plugin-2.8.2.jar"):
        MODULE.import_bundle(MODULE.load_config(["--bundle", str(root)], env()), session)

    assert session.calls == []


def test_symlinked_representative_artifact_fails_before_network(tmp_path):
    root, _ = bundle(tmp_path)
    representative = root / "junit/junit/4.11/junit-4.11.jar"
    representative.unlink()
    outside = tmp_path / "outside-junit.jar"
    outside.write_bytes(b"outside")
    representative.symlink_to(outside)
    session = FakeSession([])

    with pytest.raises(MODULE.ImportError, match="missing representative"):
        MODULE.import_bundle(MODULE.load_config(["--bundle", str(root)], env()), session)

    assert session.calls == []


def test_post_import_verification_detects_lifecycle_plugin_mismatch(tmp_path):
    root, artifacts = bundle(tmp_path)
    session = FakeSession([
        Response(200, json_data=[{"name": "maven-e2e-external", "format": "maven2", "type": "hosted"}]),
        *scan_responses(artifacts),
        Response(200, content=artifacts["junit/junit/4.11/junit-4.11.jar"]),
        Response(200, content=artifacts["org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar"]),
        Response(200, content=b"corrupt-plugin"),
    ])
    with pytest.raises(MODULE.ImportError, match="maven-deploy-plugin-2.8.2.jar"):
        MODULE.import_bundle(MODULE.load_config(["--bundle", str(root)], env()), session)


def test_main_summary_contains_only_url_counts_and_no_password(tmp_path, monkeypatch):
    root, _ = bundle(tmp_path)
    config = MODULE.load_config(["--bundle", str(root)], env())
    monkeypatch.setattr(MODULE, "load_config", lambda argv=None, environ=None: config)
    monkeypatch.setattr(MODULE, "import_bundle", lambda config: MODULE.ImportResult(2, 3, 0))
    output = io.StringIO()
    assert MODULE.main([], output=output) == 0
    assert output.getvalue() == "https://nexus.test/repository/maven-e2e-external\nuploaded=2 skipped=3 failed=0\n"
    assert "secret-value" not in output.getvalue()
