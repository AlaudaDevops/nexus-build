import os
from dataclasses import dataclass
import pytest
from dotenv import load_dotenv
from libs.nexus_client import NexusClient

load_dotenv()

@dataclass
class NexusConfig:
    url: str
    username: str
    password: str

@pytest.fixture(scope="session")
def nexus_config() -> NexusConfig:
    return NexusConfig(
        url=os.getenv("NEXUS_URL", ""),
        username=os.getenv("NEXUS_USERNAME", ""),
        password=os.getenv("NEXUS_PASSWORD", "")
    )

@pytest.fixture(scope="session")
def nexus_client(nexus_config: NexusConfig) -> NexusClient:
    """创建Nexus客户端实例"""
    return NexusClient(
        url=nexus_config.url,
        username=nexus_config.username,
        password=nexus_config.password
    )
