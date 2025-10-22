from setuptools import setup, find_packages

setup(
    name="test-example-package",
    version="1.0.0",
    packages=find_packages(),
    description="Test package for Nexus",
    author="Test Author",
    author_email="test@example.com"
)

def greeting():
    return "Hello from test package"