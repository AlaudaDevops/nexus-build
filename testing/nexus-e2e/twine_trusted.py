import twine.__main__
from twine.repository import Repository

def disable_server_certificate_validation():
    """Allow twine to just trust the hosts"""
    # 新版本 twine 中的正确路径
    Repository.set_client_certificate = lambda *args, **kwargs: None
    Repository.set_certificate_authority = lambda *args, **kwargs: None

def main():
    disable_server_certificate_validation()
    twine.__main__.main()

if __name__ == '__main__':
    main()
