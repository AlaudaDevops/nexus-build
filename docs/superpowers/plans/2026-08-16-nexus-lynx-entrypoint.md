# Nexus Lynx Test Entrypoint Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an executable `/app/lynx-entrypoint.sh` to the Nexus test image that authenticates to an ACP Region, installs the exact listed Nexus Operator through OLM, runs the existing Godog E2E, and preserves reports and failure status.

**Architecture:** Keep the fixed entrypoint as a small phase orchestrator. Put common validation/polling, ACP authentication, OLM installation, E2E/report handling, and diagnostics in separate sourceable shell libraries under `testing/lynx/`, with subprocess-based pytest tests and fake command binaries.

**Tech Stack:** Bash 5, kubectl/OLM, ACP OIDC HTTP APIs, jq/yq, Python 3.12 pytest, Godog `nexus.test`, Allure CLI, OCI Containerfile.

---

### Task 1: Contract tests and common helpers

**Files:**
- Create: `testing/nexus-e2e/unit/test_lynx_entrypoint.py`
- Create: `testing/lynx/common.sh`

- [ ] **Step 1: Write failing tests** for timestamped phase logging, required variables, integer timeout validation, exact version extraction from `L5_PLUGINS_VERSION`, and bounded polling. The test helper invokes Bash with `source testing/lynx/common.sh` and captures stdout/stderr/return code.
- [ ] **Step 2: Verify RED** with `/tmp/nexus-lynx-venv/bin/python -m pytest unit/test_lynx_entrypoint.py -q`; expect failure because `testing/lynx/common.sh` does not exist.
- [ ] **Step 3: Implement minimal helpers:** `log`, `fatal`, `require_env`, `require_command`, `require_positive_integer`, `listed_operator_version`, and `wait_for_value`. `fatal` returns non-zero without echoing environment values; polling uses `SECONDS`, a deadline, and a configurable heartbeat.
- [ ] **Step 4: Verify GREEN** with the focused pytest command; expect all Task 1 tests to pass.
- [ ] **Step 5: Commit** `test_lynx_entrypoint.py` and `common.sh` with `test: define Lynx entrypoint runtime contract`.

### Task 2: ACP authentication and safe target configuration

**Files:**
- Modify: `testing/nexus-e2e/unit/test_lynx_entrypoint.py`
- Create: `testing/lynx/auth.sh`

- [ ] **Step 1: Write failing tests** proving pre-issued `TOKEN` bypasses password login, missing both authentication methods fails, proxy kubeconfig points at `${API_URL}/kubernetes/${REGION_NAME}`, generated files are mode 0600, and captured output does not contain password/token values.
- [ ] **Step 2: Verify RED** and confirm failure is caused by missing `auth.sh` functions.
- [ ] **Step 3: Implement** `resolve_access_token`, ACP Dex password login using `/dex/pubkey` RSA PKCS#1 encryption, `write_proxy_kubeconfig`, and `write_bdd_config`. Use temporary files, no xtrace, curl deadlines, and never print usernames or credential payloads.
- [ ] **Step 4: Verify GREEN** with the focused pytest command and `bash -n testing/lynx/auth.sh`.
- [ ] **Step 5: Commit** with `feat(testing): add secure ACP authentication for Lynx`.

### Task 3: Idempotent exact-version OLM installer

**Files:**
- Modify: `testing/nexus-e2e/unit/test_lynx_entrypoint.py`
- Create: `testing/lynx/olm.sh`

- [ ] **Step 1: Write failing tests** using a stateful fake `kubectl` for: exact PackageManifest channel/CSV resolution, version mismatch, CatalogSource Ready, zero/one/multiple OperatorGroups, Manual Subscription creation with `startingCSV`, InstallPlan approval, terminal Subscription conditions, already-installed CSV, CSV timeout, dynamic Deployment discovery, and established CRD.
- [ ] **Step 2: Verify RED** and confirm missing OLM functions are the reason.
- [ ] **Step 3: Implement** `resolve_operator_catalog`, `ensure_operator_group`, `ensure_subscription`, `wait_for_install_plan`, `wait_for_csv`, `wait_for_deployment`, `wait_for_nexus_crd`, and `install_operator`. Read source/channel/currentCSV from the PackageManifest; require it to match the version parsed from `L5_PLUGINS_VERSION`; use Manual approval and reject incompatible existing resources.
- [ ] **Step 4: Verify GREEN** with pytest and `bash -n testing/lynx/olm.sh`.
- [ ] **Step 5: Commit** with `feat(testing): install listed Nexus operator through OLM`.

### Task 4: E2E, reports, and failure diagnostics

**Files:**
- Modify: `testing/nexus-e2e/unit/test_lynx_entrypoint.py`
- Create: `testing/lynx/e2e.sh`
- Create: `testing/lynx/diagnostics.sh`

- [ ] **Step 1: Write failing tests** proving `nexus.test` receives `--godog.tags=${LYNX_E2E_TAGS:-@e2e}`, its non-zero exit code is returned, Allure results are copied to `${RESULT_DIR}/allure-result`, empty results fail, Allure report generation is attempted after non-empty results, and diagnostics query only OLM/workload/Event status without reading Secrets.
- [ ] **Step 2: Verify RED** for missing E2E/diagnostic functions.
- [ ] **Step 3: Implement** `run_e2e`, `collect_allure_results`, `generate_allure_report`, and `collect_diagnostics`. Run from a writable temporary copy when `/app/testing` is read-only, set `E2E_CONFIG`, and retain the real test exit status. Permit best-effort `|| true` only in diagnostics/report collection.
- [ ] **Step 4: Verify GREEN** with pytest and `bash -n` for both libraries.
- [ ] **Step 5: Commit** with `feat(testing): run Nexus E2E and retain Lynx diagnostics`.

### Task 5: Entrypoint orchestration and image contract

**Files:**
- Modify: `testing/nexus-e2e/unit/test_lynx_entrypoint.py`
- Create: `testing/lynx-entrypoint.sh`
- Modify: `testing/Containerfile`
- Modify: `testing/README.md`

- [ ] **Step 1: Write failing tests** asserting the top-level phase order, required-variable return code, EXIT diagnostic behavior, fixed `/app/lynx-entrypoint.sh` executable contract, explicit library copy, and absence of xtrace or success masking around tests.
- [ ] **Step 2: Verify RED** because the entrypoint and Containerfile clauses do not exist.
- [ ] **Step 3: Implement** the orchestrator: validate inputs and tools; create the result directory; authenticate; preflight/install/wait; run E2E; collect/generate reports; clean only temporary credentials; emit `[DONE]`; preserve failures through the EXIT trap. Add explicit Containerfile `COPY`/`chmod`/`test -x` and document inputs/output paths.
- [ ] **Step 4: Verify GREEN** with focused pytest, `bash -n testing/lynx-entrypoint.sh testing/lynx/*.sh`, and `git diff --check`.
- [ ] **Step 5: Commit** with `feat(testing): add Nexus Lynx image entrypoint`.

### Task 6: Full verification and PR

**Files:**
- Verify all files above; no new production scope.

- [ ] **Step 1: Run** `/tmp/nexus-lynx-venv/bin/python -m pytest unit -q`; expect all existing and new unit tests to pass.
- [ ] **Step 2: Run** shell syntax checks and a test-image build if a compatible local container builder is available. If unavailable, record that the PR pipeline is the image-build evidence.
- [ ] **Step 3: Inspect** `git diff --check`, executable modes, staged diff, and secret-pattern scan; ensure no generated files are tracked.
- [ ] **Step 4: Push** `codex/devops-44609-lynx-entrypoint` and open a draft MR targeting `alauda-76.0`, describing the two-stage delivery and explicitly stating that the operator gitlink is not updated yet.
- [ ] **Step 5: Monitor** the MR pipeline read-only and report failures; do not merge or start the operator update until user review.
