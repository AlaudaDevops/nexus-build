# Nexus Lynx Connectors Parity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Align Nexus Lynx TLS, curl diagnostics, and setup-failure reporting with connectors MR !66.

**Architecture:** Keep authentication, kubeconfig generation, and report collection in their existing focused shell modules. Change only the cross-cutting behavior proven incompatible in the live RTP while retaining Nexus-specific OLM logic.

**Tech Stack:** Bash, jq, pytest, Containerfile, GitHub Actions

---

### Task 1: Full-chain insecure TLS

**Files:**
- Modify: `testing/nexus-e2e/unit/test_lynx_entrypoint.py`
- Modify: `testing/lynx/auth.sh`

- [ ] Add tests asserting authentication curl includes `--insecure`, stderr is not redirected to `/dev/null`, and proxy kubeconfig contains `insecure-skip-tls-verify: true`.
- [ ] Run the focused tests and confirm they fail for the missing connectors parity behavior.
- [ ] Update `auth.sh` with the minimum implementation: unconditional curl `--insecure`, retained stderr, and the kubeconfig TLS field.
- [ ] Re-run the focused tests and confirm they pass.

### Task 2: Setup-failure report collection

**Files:**
- Modify: `testing/nexus-e2e/unit/test_lynx_entrypoint.py`
- Modify: `testing/lynx-entrypoint.sh`
- Modify: `testing/lynx/e2e.sh`

- [ ] Add a test that executes an early setup failure and asserts result collection is attempted while the original non-zero status is preserved.
- [ ] Run the focused test and confirm it fails because collection currently starts only after setup succeeds.
- [ ] Move safe result/report preparation and collection into the EXIT path without masking the original setup failure.
- [ ] Re-run the focused test and confirm it passes.

### Task 3: Verification and publication

**Files:**
- Verify: `testing/lynx-entrypoint.sh`
- Verify: `testing/lynx/*.sh`
- Verify: `testing/nexus-e2e/unit/test_lynx_entrypoint.py`

- [ ] Run the complete Lynx unit suite and shell syntax checks.
- [ ] Review the diff for credentials, unrelated changes, and connectors parity requirements.
- [ ] Commit and push the existing GitHub PR #45 branch.
- [ ] Trigger the existing fixed-image GitHub Actions workflow with a new unique tag and monitor it until the image is published or a concrete block is found.

