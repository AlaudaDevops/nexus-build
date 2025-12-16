import os
from xml.etree import ElementTree
import tempfile
import time
import pytest
import allure
from pathlib import Path

def test_maven_publish(nexus_client, nexus_config, hosted_repo):
    with allure.step('Build and deploy Maven project'):
        project_path = Path(f'test_projects/maven')

        server_configs = [
            create_server_config("nexus", nexus_config.username, nexus_config.password),
        ]
        mirrors_configs = [
            create_mirror_config("ucloud", "central", os.environ.get("MACVEN_MIRROR_REGISTRY", "http://ucloud-nexus.alauda.cn:8081"), "maven-central")
        ]
        settings_path = create_settings(server_configs, mirrors_configs)
        publish_xml_path = project_path / 'publish.xml'
        # Create a temporary directory to store the modified pom file
        temp_publish_xml = f"publish-{time.strftime('%Y%m%d-%H%M%S')}.xml"
        with open(publish_xml_path, 'r') as f:
            content = f.read()
        # Replace placeholder with actual nexus repository URL
        content = content.replace('NEXUS_REPO_URL', f"{nexus_config.url}/repository/{hosted_repo}")
        # Write the modified content to the temporary file
        with open(project_path / temp_publish_xml, 'w') as f:
            f.write(content)
        assert os.system(f'cd {project_path} && mvn -s {settings_path} -f {temp_publish_xml} clean deploy') == 0

    with allure.step('Get snapshot version'):
        tree = ElementTree.parse(project_path / 'publish.xml')
        root = tree.getroot()
        ns = {'mvn': 'http://maven.apache.org/POM/4.0.0'}

        group_id = root.find('.//mvn:groupId', ns).text
        artifact_id = root.find('.//mvn:artifactId', ns).text
        version = root.find('.//mvn:version', ns).text

    with allure.step('Verify artifact availability'):
        artifact_path = nexus_client.get_maven_jar(
            hosted_repo,
            group_id,
            artifact_id,
            version
        )

        response = nexus_client.download_artifact(
            hosted_repo,
            artifact_path
        )
        assert response.status_code == 200

    with allure.step('Download dependency'):
        server_configs = [
            create_server_config("nexus", nexus_config.username, nexus_config.password),
        ]
        mirrors_configs = [
            create_mirror_config("nexus","nexus", nexus_config.url, hosted_repo),
            create_mirror_config("ucloud", "central", os.environ.get("MACVEN_MIRROR_REGISTRY", "http://ucloud-nexus.alauda.cn:8081"), "maven-central")
        ]
        settings_path = create_settings(server_configs, mirrors_configs)
        project_path = Path(f'test_projects/maven')
        cmd = (f'cd {project_path} && '
               f'mvn -s {settings_path} -f download.xml package')
        assert os.system(cmd) == 0

    with allure.step('Verify dependency download'):
        artifact_path = f"{group_id.replace('.', '/')}/{artifact_id}/{version}"
        jar_name = f"{artifact_id}-{version}.jar"

        local_repo = Path.home() / '.m2/repository' / artifact_path / jar_name
        assert local_repo.exists(), f"Dependency not found at {local_repo}"


def test_maven_proxy(nexus_client, nexus_config):
    with allure.step('Set nexus proxy config'):
        nexus_client.update_proxy_config(
            "maven",
            "maven-central",
            "proxy",
            r"{}/repository/maven-central/".format(os.environ.get("MACVEN_MIRROR_REGISTRY", "http://ucloud-nexus.alauda.cn:8081"))
        )

    with allure.step('Download dependency'):
        server_configs = [
            create_server_config("nexus", nexus_config.username, nexus_config.password),
        ]
        mirrors_configs = [
            create_mirror_config("nexus", "*", nexus_config.url, 'maven-central'),
        ]
        settings_path = create_settings(server_configs, mirrors_configs)

        project_path = Path(f'test_projects/maven')

        cmd = f'rm -rf ~/.m2/repository && cd {project_path} &&  mvn -s {settings_path} -f publish.xml clean install'
        assert os.system(cmd) == 0

    with allure.step('Verify artifact availability'):
        group_id = 'junit'
        artifact_id = 'junit'
        version = 4.11

        artifact_path = f"{group_id.replace('.', '/')}/{artifact_id}/{version}"
        jar_name = f"{artifact_id}-{version}.jar"

        local_repo = Path.home() / '.m2/repository' / artifact_path / jar_name
        assert local_repo.exists(), f"Dependency not found at {local_repo}"


def create_settings(server_configs, mirror_configs):
    settings = ElementTree.Element('settings')
    settings.set('xmlns', 'http://maven.apache.org/SETTINGS/1.0.0')
    settings.set('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance')
    settings.set('xsi:schemaLocation',
                 'http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd')

    if server_configs:
        servers = ElementTree.SubElement(settings, 'servers')
        for config in server_configs:
            servers.append(config)

    if mirror_configs:
        mirrors = ElementTree.SubElement(settings, 'mirrors')
        for config in mirror_configs:
            mirrors.append(config)

    tree = ElementTree.ElementTree(settings)

    ElementTree.indent(tree, space='    ')
    xml = '<?xml version="1.0" encoding="UTF-8"?>\n' + ElementTree.tostring(settings, encoding='unicode')

    temp_dir = Path(tempfile.mkdtemp())
    settings_path = temp_dir / "settings.xml"
    settings_path.write_text(xml)
    return settings_path

def create_server_config(id, username, password):
    server = ElementTree.Element( 'server')

    server_id = ElementTree.SubElement(server, 'id')
    server_id.text = id

    server_username = ElementTree.SubElement(server, 'username')
    server_username.text = username

    server_password = ElementTree.SubElement(server, 'password')
    server_password.text = password

    return server


def create_mirror_config(id, replace, nexus_url, repo_name):
    mirror = ElementTree.Element('mirror')

    mirror_id = ElementTree.SubElement(mirror, 'id')
    mirror_id.text = id

    mirror_of = ElementTree.SubElement(mirror, 'mirrorOf')
    mirror_of.text = replace

    mirror_url = ElementTree.SubElement(mirror, 'url')
    mirror_url.text = f"{nexus_url}/repository/{repo_name}/"

    return mirror

@pytest.fixture
def hosted_repo(nexus_client):
    t = time.strftime("%Y%m%d-%H%M%S")
    repo_name = f"maven-test-repo-{t}"
    nexus_client.create_repository("maven", repo_name)
    return repo_name


@pytest.fixture
def proxy_repo(nexus_client):
    t = time.strftime("%Y%m%d-%H%M%S")
    repo_name = f"maven-test-repo-{t}"
    nexus_client.create_repository("maven", repo_name, "proxy", r"{}/repository/maven-central/".format(os.environ.get("MACVEN_MIRROR_REGISTRY", "http://ucloud-nexus.alauda.cn:8081")))
    return repo_name
