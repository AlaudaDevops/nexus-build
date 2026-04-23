---
description: Build nexus image, scan vulnerabilities with Trivy, and fix them
---

# Nexus Image Vulnerability Fix Workflow

Execute step by step. Report progress at each stage and wait for confirmation before risky changes.

## Step 0: Sync .trivyignore

```bash
./hack/sync-trivyignore.sh
```

Review the diff and commit if changed. If sync fails (e.g. network unreachable), skip this step and continue.

## Step 1: Build Image

```bash
./hack/build-nexus-image.sh --tag nexus-local:<version>
```

If source build fails due to missing `groovy-eclipse-batch:3.0.13-02`, use `--skip-source` with cached JARs from `~/.m2/repository/` or `image/jar/`.

## Step 2: Scan Vulnerabilities

```bash
./hack/scan-image.sh --image nexus-local:<version>
```

Categorize results into:
- **OS package** (alpine apk) — fixable via `apk upgrade`
- **Standalone JAR** — replaceable via `replace.sh`
- **Fat JAR embedded** (shaded JARs like pax-url-aether) — requires fork or upstream fix
- **Unfixable** — no fix version, or fix requires incompatible major version

## Step 3: Fix Vulnerabilities

### 3a. OS Packages
Add `apk upgrade --no-cache <pkg>` in `image/Containerfile.alpine.java17`.

### 3b. Standalone JARs

For each fixable JAR:

1. **Check OSGi compatibility first.** Nexus runs on Karaf (OSGi) with strict version ranges. See "OSGi Constraints" below.

2. Verify fix version exists on Maven Central:
   ```
   curl -sI "https://repo1.maven.org/maven2/<group-path>/<artifact>/<version>/<artifact>-<version>.jar"
   ```

3. Add ARG with renovate annotation + `replace.sh` call in Containerfile:
   ```dockerfile
   # renovate: datasource=maven depName=<artifact> lookupName=<group>:<artifact>
   ARG <NAME>_NEW_VERSION=<version>
   ```
   ```dockerfile
   && $NEXUS_HOME/scripts/replace.sh $NEXUS_HOME <maven/path> <old_version> ${<NAME>_NEW_VERSION}
   ```

4. For non-Maven-Central JARs, pass custom URL as 5th arg to `replace.sh`.

**NEVER put `#` comments inside a `\`-continued RUN block** — silently comments out subsequent commands.

### 3c. Fat JAR Embedded

1. Check if a newer official release fixes it — **always prefer upstream over forks**
2. Review existing AlaudaDevops forks in the Containerfile; if upstream now has a fix, switch to official and archive the fork
3. If no official fix: fork to AlaudaDevops, create `alauda-<version>` branch, fix pom.xml dependency, add GitHub Actions build workflow, push to trigger release
   - For cherry-picked vulnerability patches, the fork commit message **must** record the upstream original PR (URL and PR number).
   - Recommended commit footer:
     - `Upstream-PR: https://github.com/<owner>/<repo>/pull/<id>`
     - `Cherry-picked-from: <commit-sha>` (if applicable)
4. Reference released JAR via custom URL arg in Containerfile
5. **Keep major version unchanged** for OSGi compatibility

### 3d. Unfixable

Add CVE to `.trivyignore` with severity and reason. Submit exemption to Thanos.

## Step 4: Smoke Test

```bash
./hack/build-nexus-image.sh --tag nexus-test:local
./hack/local-smoke-test.sh run --image nexus-test:local
```

Failure types:
- **OSGi resolution error** → incompatible JAR major version, revert or find compatible version
- **Container crash** → check `docker logs nexus-smoke-test`
- **Test failure** → check HTTP status and Nexus logs

## Step 5: Re-scan

```bash
./hack/scan-image.sh --image nexus-test:local
```

Confirm targeted CVEs are resolved. Report remaining unfixable ones with reasons.

---

## OSGi Constraints (Critical)

These JARs have version range locks in Karaf bundle metadata — major version bumps break bundle resolution:

| JAR | Allowed Range | Current | Notes |
|-----|---------------|---------|-------|
| `pax-url-aether` | `[2.6.0, 3.0.0)` | 2.6.17 (AlaudaDevops fork) | 3.x breaks Karaf features.core |
| `shiro-core` | `[1.2.0, 2.0.0)` | 1.13.1-alauda (fork) | 2.x breaks shiro-web OSGi |

To verify any JAR: check `Import-Package` version ranges in `startup.properties` or assembly XML files.

## Key Files

| File | Purpose |
|------|---------|
| `image/Containerfile.alpine.java17` | ARG versions + replace.sh calls |
| `image/scripts/replace.sh` | JAR replacement (custom URL as 5th arg) |
| `image/scripts/replace-jetty.sh` | Batch Jetty replacement |
| `hack/sync-trivyignore.sh` | Sync exemptions from Thanos |
| `hack/build-nexus-image.sh` | Source build + Docker build |
| `hack/scan-image.sh` | Trivy scan wrapper |
| `hack/local-smoke-test.sh` | Local smoke test (start/test/stop/run) |
