import requests
from xml.etree import ElementTree
from urllib.parse import urljoin


def _get_repository_config(repo_format, repo_name, repo_type="hosted", remote_url=None):
    base_config = {
        "name": repo_name,
        "online": True,
        "storage": {
            "blobStoreName": "default",
            "strictContentTypeValidation": True,
            "writePolicy": "allow_once"
        },
        "cleanup": {
            "policyNames": [
                "string"
            ]
        },
        "component": {
            "proprietaryComponents": True
        }
    }

    if repo_type == "proxy":
        base_config.update({
            "proxy": {
                "remoteUrl": remote_url,
                "contentMaxAge": 1440,
                "metadataMaxAge": 1440
            },
            "negativeCache": {
                "enabled": True,
                "timeToLive": 1440
            },
            "httpClient": {
                "blocked": False,
                "autoBlock": True,
                "connection": {
                    "retries": 0,
                    "userAgentSuffix": "string",
                    "timeout": 60,
                    "enableCircularRedirects": False,
                    "enableCookies": False,
                    "useTrustStore": False
                }
            }
        })

    if repo_format == "maven":
        base_config.update({
            "maven": {
                "versionPolicy": "MIXED",
                "layoutPolicy": "STRICT"
            },
        })

    return base_config


class NexusClient:
    def __init__(self, url, username, password):
        self.base_url = url
        self.auth = (username, password)
        self.session = requests.Session()
        self.session.auth = self.auth
        self.session.verify = False

    def create_repository(self, repo_format, repo_name, repo_type="hosted", remote_url=None):
        """创建仓库"""
        endpoint = f"service/rest/v1/repositories/{repo_format}/{repo_type}"
        config = _get_repository_config(repo_format, repo_name, repo_type, remote_url)
        response = self.session.post(urljoin(self.base_url, endpoint), json=config)
        response.raise_for_status()
        return response
    
    def update_proxy_config(self, repo_format, repo_name, repo_type="proxy", remote_url=None):
        """更新maven代理配置"""
        endpoint = f"service/rest/v1/repositories/{repo_format}/{repo_type}/{repo_name}"
        config = _get_repository_config(repo_format, repo_name, repo_type, remote_url)
        response = self.session.put(urljoin(self.base_url, endpoint), json=config)
        response.raise_for_status()
        return response

    def upload_artifact(self, repo_name, file_path, artifact_path):
        """上传构件"""
        endpoint = f"repository/{repo_name}/{artifact_path}"
        with open(file_path, 'rb') as f:
            response = self.session.put(
                urljoin(self.base_url, endpoint),
                data=f.read()
            )
        response.raise_for_status()
        return response

    def download_artifact(self, repo_name, artifact_path):
        """下载构件"""
        endpoint = f"repository/{repo_name}/{artifact_path}"
        response = self.session.get(urljoin(self.base_url, endpoint))
        response.raise_for_status()
        return response

    def get_maven_jar(self, repo_name, group_id, artifact_id, version):
        base_path = f"{group_id.replace('.', '/')}/{artifact_id}/{version}"
        metadata_url = f"{base_path}/maven-metadata.xml"

        response = self.download_artifact(repo_name, metadata_url)
        root = ElementTree.fromstring(response.content)

        # 获取最新的时间戳和构建号
        snapshot = root.find('.//snapshot')
        timestamp = snapshot.find('timestamp').text
        build_number = snapshot.find('buildNumber').text

        # 构造最终的文件名
        version_base = version.replace('-SNAPSHOT', '')
        final_name = f"{artifact_id}-{version_base}-{timestamp}-{build_number}.jar"
        return f"{base_path}/{final_name}"
