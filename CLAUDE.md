# Nexus Build

Custom build and deployment project for Sonatype Nexus Repository Manager 3, maintained by the Alauda DevOps team. Builds a hardened, CVE-patched Nexus container image with Helm chart for Kubernetes deployment.

**Repo:** `AlaudaDevops/nexus-build` (upstream), branch pattern: `alauda-<version>`
**Current version:** Nexus 3.76.0-03 (appVersion), Chart 76.0.0

## Project Structure

```
source/           # Nexus Repository Manager source (Maven, Java 17 + JS/Yarn)
image/            # Container image build
  Containerfile.alpine.java17   # Main multi-stage Dockerfile (Alpine + Java 17)
  Containerfile.base            # Base build image (JDK 17 + Node 22 + Yarn 4.x)
  scripts/        # JAR replacement scripts for CVE patching
    replace.sh             # Generic JAR version replacement
    replace-jetty.sh       # Jetty server JAR batch replacement
    replace-nexus-jar.sh   # Replace rebuilt nexus JARs from source
chart/            # Helm chart (nxrm-ha) for Kubernetes deployment
  Chart.yaml      # Chart v76.0.0, appVersion 3.76.0
  values.yaml     # Image tags, resource configs, ingress, storage
testing/          # Integration & E2E tests
  features/       # BDD Gherkin features (network, storage, operator)
  steps/          # Go step definitions (AlaudaDevops/bdd framework)
  Makefile        # Test runner (godog-based)
  nexus-e2e/      # Python E2E tests (pytest + allure) for Maven/NPM/PyPI repos
hack/             # Utility scripts
  update-image-tag.sh  # Update image tags in values.yaml
.tekton/          # Tekton CI/CD pipelines (PipelinesAsCode)
  pipeline/nexus-image-build.yaml  # Main build pipeline definition
  build-image.yaml          # PipelineRun for image build (on source/image changes)
  build-base-image.yaml     # PipelineRun for base build image
  integration-test.yaml     # PipelineRun for integration tests (vcluster-based)
  build-testing-base-image.yaml  # PipelineRun for test base image
  pr-manage.yaml            # PR management automation
```

## Tech Stack

- **Application:** Java 17, Maven (mvnw), Groovy, JavaScript (Yarn 4.x, Node 22)
- **Container:** Alpine Linux, multi-stage build, non-root (uid 200)
- **Deployment:** Helm chart on Kubernetes (StatefulSet, HA support)
- **CI/CD:** Tekton Pipelines with PipelinesAsCode, Renovate for dependency updates
- **Integration tests:** Go (godog BDD framework, Ginkgo-style), vcluster for isolation
- **E2E tests:** Python (pytest, allure, requests) for repository protocol validation
- **Image scanning:** Trivy (vulnerability gate on High severity, air-gap DB from internal registry)
- **Registry:** `${HARBOR_REGISTRY_HOST}/devops/sonatype-nexus3` (see `.env` for `HARBOR_REGISTRY_HOST`)

## Build Process

1. **Source build** (`build-nexus-app`): Compiles nexus-ui-plugin, nexus-rapture, nexus-coreui-plugin from `source/` using Maven + Yarn. Outputs patched JARs to `image/jar/`.
2. **Image build** (`build-nexus-image`): Multi-stage Alpine build. Downloads Nexus binary, replaces vulnerable JARs via `replace.sh` scripts, copies rebuilt JARs, strips unnecessary tools.
3. **Image scan** (`image-scan`): Trivy scan with quality gate. Uses internal vulnerability databases (Trivy DB and Java DB) from the internal registry (latest versions required for air-gap scanning). Registry hosts are configured via `.env` file (`HARBOR_REGISTRY_HOST`).
4. **Chart update** (`update-chart-values`): Auto-commits new image tag to `chart/values.yaml` on branch push (non-PR).

## CVE Patching Strategy

Vulnerable JAR dependencies are replaced at image build time without forking Nexus:
- `image/scripts/replace.sh` downloads new JARs from Maven Central (or custom URL) and updates Karaf config references via `sed`/`find`
- `image/scripts/replace-jetty.sh` batch-replaces all Jetty modules
- JS-related vulnerabilities are fixed by rebuilding nexus-ui-plugin, nexus-rapture, nexus-coreui-plugin from patched source
- Renovate auto-creates PRs for new library versions via `ARG` annotations in the Containerfile

## Common Commands

| Command | Purpose |
|---------|---------|
| `cd source && ./mvnw clean install -DskipTests` | Build Nexus from source |
| `cd source && yarn install` | Install JS dependencies |
| `cd testing && make test-all` | Run all integration tests (non-e2e) |
| `cd testing && make test-smoke` | Run smoke tests only |
| `cd testing && make test-e2e` | Run E2E tests |
| `cd testing/nexus-e2e && python -m pytest` | Run Python E2E repo tests |
| `helm template chart/` | Render Helm chart locally |
| `bash hack/update-image-tag.sh <image-url> chart/values.yaml` | Update image tag in chart |

## Git Workflow

- **Branch naming:** `alauda-<nexus-version>` (e.g., `alauda-76.0`)
- **Commit style:** Conventional commits (`feat:`, `fix:`, `chore:`, `docs:`, `test:`)
- **CI triggers:** PipelinesAsCode on `alauda-*` branches
- **Renovate:** Auto-updates dependency versions in Containerfile ARGs (`baseBranches: alauda-*`)
- **Auto-commit:** Bot commits image tag updates with `[ci skip]` suffix

## Key Conventions

- All container images must work in air-gapped environments
- Non-root container execution (nexus user uid 200, build pods uid 65532)
- SHA256 verification for downloaded Nexus binary
- Trivy scan required before image promotion
- Helm chart values updated automatically by CI pipeline
- `source/` is upstream Nexus code with minimal patches — avoid modifying unless necessary for CVE fixes
