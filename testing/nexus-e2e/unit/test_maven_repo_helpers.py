from xml.etree import ElementTree

from test_maven_repo import (
    MAVEN_NAMESPACE,
    create_download_project,
    create_mirror_config,
    create_server_config,
    create_settings,
)


def test_publish_settings_use_bundle_and_exact_nexus_mirrors():
    settings = create_settings(
        [create_server_config("nexus", "user", "password")],
        [
            create_mirror_config(
                "bundle-central",
                "central",
                "file:///opt/nexus-e2e/maven-repository",
                None,
            ),
            create_mirror_config(
                "nexus",
                "nexus",
                "http://nexus.example.test",
                "e2e-hosted",
            ),
        ],
    )

    root = ElementTree.parse(settings).getroot()
    namespace = {"s": "http://maven.apache.org/SETTINGS/1.0.0"}
    mirrors = root.findall("s:mirrors/s:mirror", namespace)
    mirror_values = {
        mirror.findtext("s:id", namespaces=namespace): (
            mirror.findtext("s:mirrorOf", namespaces=namespace),
            mirror.findtext("s:url", namespaces=namespace),
        )
        for mirror in mirrors
    }
    assert mirror_values == {
        "bundle-central": ("central", "file:///opt/nexus-e2e/maven-repository/"),
        "nexus": (
            "nexus",
            "http://nexus.example.test/repository/e2e-hosted/",
        ),
    }
    assert root.findtext("s:servers/s:server/s:id", namespaces=namespace) == "nexus"


def test_download_project_points_only_at_the_tested_hosted_repository(tmp_path):
    source = tmp_path / "source.xml"
    destination = tmp_path / "download.xml"
    source.write_text(
        f'<project xmlns="{MAVEN_NAMESPACE}"><modelVersion>4.0.0</modelVersion></project>'
    )

    create_download_project(
        source,
        destination,
        "https://nexus.example.test/repository/e2e-hosted/",
    )

    root = ElementTree.parse(destination).getroot()
    namespace = {"m": MAVEN_NAMESPACE}
    assert root.findtext("m:repositories/m:repository/m:id", namespaces=namespace) == "nexus"
    assert (
        root.findtext("m:repositories/m:repository/m:url", namespaces=namespace)
        == "https://nexus.example.test/repository/e2e-hosted/"
    )
