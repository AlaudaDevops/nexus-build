import os
import tempfile
import time
from pathlib import Path
import pytest
import allure

def test_pypi_publish(nexus_client, nexus_config, pypi_repo):
    with allure.step('Build and publish Python package'):
        project_path = Path('test_projects/pypi')

        script_path = Path('twine_trusted.py')
        upload_cmd = (
            f'cd {project_path} && '
            f'python -m build && '
            f'python {script_path.absolute()} upload '
            f'--non-interactive '
            f'--username "{nexus_config.username}" '
            f'--password \'{nexus_config.password}\' ' 
            f'--repository-url {nexus_config.url}/repository/{pypi_repo}/ '
            f'dist/*'
        )
        return_code = os.system(upload_cmd)
        assert return_code == 0, f"Failed to upload package, return code: {return_code}"

    with allure.step('Get package version'):
        package_name = "test-example-package"
        package_version = "1.0.0"
        package_path = f"{package_name.replace('-', '_')}-{package_version}.tar.gz"

    with allure.step('Verify package availability'):
        response = nexus_client.download_artifact(
            pypi_repo,
            f'packages/{package_name}/{package_version}/{package_path}'
        )
        assert response.status_code == 200


def create_pypirc(nexus_url, username, password, repo_name):
    temp_dir = Path(tempfile.mkdtemp())
    pypirc_path = temp_dir / ".pypirc"

    pypirc_content = f"""[distutils]
index-servers = nexus

[nexus]
repository: {nexus_url}/repository/{repo_name}/
username: {username}
password: {password}
"""

    pypirc_path.write_text(pypirc_content)
    return pypirc_path


@pytest.fixture
def pypi_repo(nexus_client):
    t = time.strftime("%Y%m%d-%H%M%S")
    repo_name = f"pypi-test-repo-{t}"
    nexus_client.create_repository("pypi", repo_name)
    return repo_name
