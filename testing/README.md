## 目录结构

- features：BDD feature 文件
- hack: 一些脚本，用于生成测试数据或者测试环境准备脚本
- steps: 自定义step
- testdata：测试数据
- main_test.go: 测试入口文件
- Makefile: 包含了一些常用命令

## 执行测试

### 基于chart 的集成测试

前置条件：
1. 设置好 kubeconfig，可以连接到 k8s 集群
2. 集群已安装 ingress controller（可以是 alb 或者是 nginx ingress controller，不限制）
3. 存在存储类，存储类需要支持 readwritemany 方式（nfs 和 ceph 都支持）

在 testing 目录下面执行命令即可。

```bash
make test-all
```

备注：目前 vcluster 所在的集群资源不足，无法运行测试。

### 基于 nexus operator 的 e2e 测试

前置条件：

1. 准备一个配置文件，配置内容如下：

```yaml
acp:
  baseUrl: https://acp.example.test # acp 的 url
  token: xxxx # acp 的 token
  cluster: business-1 # 运行测试的集群名称
```
将配置文件保存在 testing 目录下，文件名称为 config.yaml。（也可以保存在其他路径，然后通过 E2E_CONFIG 环境变量指定配置文件的路径）

在 testing 目录下执行命令：

```bash
make test-e2e
```

### 认证 Maven 上游的离线 E2E

这个场景使用两个独立的 Nexus：

- **upstream Nexus（第二 Nexus）**：使用 hosted Maven 仓库承载测试镜像中预置的离线依赖 bundle，默认仓库名为 `maven-e2e-external`。
- **tested Nexus**：当前被测 Nexus；测试会将其 `maven-central` proxy 的 remote 指向 upstream Nexus 的 hosted 仓库，并为该 remote 配置 Basic auth。

upstream Nexus 由以下环境变量配置：

- `MAVEN_UPSTREAM_URL`：upstream Nexus 的基础 URL。
- `MAVEN_UPSTREAM_REPOSITORY`：hosted Maven 仓库名，默认为 `maven-e2e-external`。
- `MAVEN_UPSTREAM_USERNAME`：upstream Nexus 用户名。
- `MAVEN_UPSTREAM_PASSWORD`：upstream Nexus 密码。

密码应由容器运行时、CI secret 或 Kubernetes Secret 注入环境，不要将密码值直接写在命令行、脚本或版本库中。运行导入命令前，宿主环境需要已准备 `TESTING_IMAGE`、`MAVEN_UPSTREAM_URL`、`MAVEN_UPSTREAM_USERNAME` 和由安全 secret 注入的 `MAVEN_UPSTREAM_PASSWORD`；`MAVEN_UPSTREAM_REPOSITORY` 可选，未设置时使用 `maven-e2e-external`。例如，CI 或运行时先导出这些变量，以下命令负责校验并透传，不在命令行中展开密码：

```bash
: "${TESTING_IMAGE:?TESTING_IMAGE is required}"
: "${MAVEN_UPSTREAM_URL:?MAVEN_UPSTREAM_URL is required}"
: "${MAVEN_UPSTREAM_USERNAME:?MAVEN_UPSTREAM_USERNAME is required}"
: "${MAVEN_UPSTREAM_PASSWORD:?MAVEN_UPSTREAM_PASSWORD is required}"
MAVEN_UPSTREAM_REPOSITORY="${MAVEN_UPSTREAM_REPOSITORY:-maven-e2e-external}"
export MAVEN_UPSTREAM_REPOSITORY

docker run --rm \
  --entrypoint /usr/local/bin/import-maven-e2e-dependencies \
  -e MAVEN_UPSTREAM_URL \
  -e MAVEN_UPSTREAM_REPOSITORY \
  -e MAVEN_UPSTREAM_USERNAME \
  -e MAVEN_UPSTREAM_PASSWORD \
  "$TESTING_IMAGE"
```

导入器会自动创建或复用 hosted Maven 仓库。导入阶段的账户需要 repository list 权限、仓库不存在时的 create 权限，以及该 hosted 仓库内容的 GET/PUT 权限。重复导入相同内容是幂等的；如果目标路径已存在但内容不同，则视为冲突并以非零状态退出。可用同样的 entrypoint override 查看帮助：

```bash
docker run --rm \
  --entrypoint /usr/local/bin/import-maven-e2e-dependencies \
  "$TESTING_IMAGE" --help
```

之所以需要 `--entrypoint`，是因为测试镜像的默认 entrypoint 是 `nexus.test`，而非导入器。导入器使用 `requests` 访问 HTTPS upstream，默认校验 TLS 证书。当前测试进程到 tested Nexus 的 `NexusClient` 连接使用 `verify=False`，会跳过该段证书校验。tested Nexus 到 upstream 的 proxy remote 未启用 Nexus custom trust store（`useTrustStore=false`），因此依赖 Nexus 运行环境的 JVM 默认信任链；使用私有 CA 时需在该运行环境中另行配置，不在本 E2E 流程的自动配置范围内。

运行 pytest 中的 Maven proxy E2E 时，必须向测试进程传入 `MAVEN_UPSTREAM_URL`、`MAVEN_UPSTREAM_USERNAME` 和 `MAVEN_UPSTREAM_PASSWORD`；`MAVEN_UPSTREAM_REPOSITORY` 可省略并使用默认值。proxy 运行阶段应改用独立的 upstream 只读账户，只授予读取该 hosted 仓库的权限，避免将导入阶段的创建/写入账户保存到 tested Nexus 的 proxy 配置中。两个阶段可以轮换同名 `MAVEN_UPSTREAM_USERNAME` 和 `MAVEN_UPSTREAM_PASSWORD` 的值：导入完成后，在启动 pytest 前将它们替换为只读账户凭据。tested Nexus 自身的连接信息仍通过独立的 `NEXUS_URL`、`NEXUS_USERNAME` 和 `NEXUS_PASSWORD` 配置，不要与 upstream Nexus 凭据混用。测试会用 upstream 的 URL 和只读凭据配置 tested Nexus 的 `maven-central` Basic-auth remote，然后通过 tested Nexus 验证依赖下载。

为了兼容旧配置，仅在未设置 `MAVEN_UPSTREAM_URL` 时，测试才会使用历史变量 `MACVEN_MIRROR_REGISTRY`（保留原有拼写）作为匿名 mirror fallback。该 fallback 不会配置 upstream Basic auth。
