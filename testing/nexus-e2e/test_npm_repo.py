import os
import json
import tempfile
import time
import pytest
import allure

from base64 import b64encode
from pathlib import Path
from urllib.parse import urlparse


def test_npm_publish(nexus_client, nexus_config, npm_repo):
    with allure.step('Build and publish NPM package'):
        project_path = Path('test_projects/npm')
        npmrc_path = create_npmrc(nexus_config.url, nexus_config.username,
                                  nexus_config.password, npm_repo)

        cmd = f'cd {project_path} && npm --userconfig {npmrc_path} publish'
        assert os.system(cmd) == 0

    with allure.step('Get package version'):
        package_json = json.loads((project_path / 'package.json').read_text())
        package_name = package_json['name']
        package_version = package_json['version']

        base_name = package_name.split('/')[-1]
        package_path = f"{package_name}/-/{base_name}-{package_version}.tgz"

    with allure.step('Verify package availability'):
        response = nexus_client.download_artifact(
            npm_repo,
            package_path
        )
        assert response.status_code == 200


def create_npmrc(nexus_url, username, password, repo_name):
    """创建临时的 .npmrc 文件"""
    temp_dir = Path(tempfile.mkdtemp())
    npmrc_path = temp_dir / ".npmrc"

    parsed_url = urlparse(nexus_url)
    registry_url = f"{nexus_url}/repository/{repo_name}/"

    auth = b64encode(f"{username}:{password}".encode()).decode()

    npmrc_content = f"""registry={registry_url}
//{parsed_url.netloc}/repository/{repo_name}/:_auth={auth}
always-auth=true
email=test@example.com
strict-ssl=false
"""
    npmrc_path.write_text(npmrc_content)
    return npmrc_path


@pytest.fixture
def npm_repo(nexus_client):
    t = time.strftime("%Y%m%d-%H%M%S")
    repo_name = f"npm-test-repo-{t}"
    nexus_client.create_repository("npm", repo_name)
    return repo_name
