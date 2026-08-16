# Nexus Lynx Test Image Entrypoint Design

## Scope

This change is limited to the `nexus-build` testing image. It adds the Lynx
runtime contract and its automated tests, but does not update the
`nexus-ce-operator` submodule pointer, release-config, artifacts metadata, or
trigger a release build. Those follow only after this pull request is reviewed
and merged.

The image must expose an executable `/app/lynx-entrypoint.sh`. Lynx runs this
command in an IDP-side test Pod after the Nexus Operator bundle has been listed
through `l5_plugin_packages`. The entrypoint installs the listed Operator in the
target Region through OLM, runs the existing `@e2e` Godog scenario, and leaves
Allure results and failure diagnostics in the Lynx result directory.

## File boundaries

The implementation is split by responsibility:

- `testing/lynx-entrypoint.sh` validates inputs and orchestrates the phases.
- `testing/lynx/common.sh` provides timestamped logging, required-variable
  validation, bounded polling, temporary-file cleanup, and safe command checks.
- `testing/lynx/auth.sh` performs ACP OIDC login and creates a mode-0600 proxy
  kubeconfig for `${API_URL}/kubernetes/${REGION_NAME}` without logging
  credentials or tokens.
- `testing/lynx/olm.sh` validates the exact listed Nexus Operator version,
  creates the Namespace, OperatorGroup, and Subscription idempotently, approves
  a Manual InstallPlan, and waits for the CSV, Deployment, and Nexus CRD.
- `testing/lynx/e2e.sh` writes the existing BDD `config.yaml`, runs
  `nexus.test` with Godog tags, preserves its exit code, and normalizes Allure
  output into the Lynx result directory.
- `testing/lynx/diagnostics.sh` writes bounded, status-only OLM, workload, and
  Event diagnostics after a failure. It never reads Secrets or dumps
  kubeconfigs.
- `testing/nexus-e2e/unit/test_lynx_entrypoint.py` supplies behavioral and
  contract tests using temporary fake executables and subprocesses.
- `testing/Containerfile` explicitly copies the entrypoint and libraries to
  `/app` and verifies that the fixed command path is executable.

The top-level entrypoint remains small enough to review as the execution
contract, while authentication, OLM, E2E, and diagnostics can be tested and
changed independently.

## Inputs and version selection

Required inputs are `API_URL`, `USERNAME`/`PASSWORD` or a pre-issued `TOKEN`,
`REGION_NAME`, and a writable result directory. The result directory accepts
`RESULT_DIR` and the existing Lynx `TEST_RESULT_DIR`, with `RESULT_DIR` taking
precedence.

The exact Operator version is derived from the Lynx-provided
`L5_PLUGINS_VERSION` JSON entry for `nexus-ce-operator`; it is not hard-coded in
the image. The script rejects a missing version and rejects a PackageManifest
whose selected channel does not resolve to that version. Defaults are:

- package: `nexus-ce-operator`;
- namespace: the bundle's suggested namespace `nexus-ce-operator`;
- channel: `stable`;
- CatalogSource: read from the PackageManifest;
- install plan approval: `Manual`, followed by an idempotent approval patch;
- install timeout: 900 seconds, configurable with `LYNX_INSTALL_TIMEOUT`;
- E2E tags: `@e2e`, configurable with `LYNX_E2E_TAGS`.

The expected CSV is obtained from the matching PackageManifest channel and is
used as `startingCSV`. This binds the clean environment to the bundle version
that the RTP listed while avoiding a hard-coded full CSV name.

## Runtime flow

1. **Validate** required variables, commands, writable result directory, and
   timeout values.
2. **Authenticate** through ACP OIDC (or use `TOKEN`) and create a temporary
   proxy kubeconfig and BDD config. Passwords, encrypted payloads, tokens, and
   kubeconfig contents are never logged.
3. **Preflight** the Region API, Namespace permissions, PackageManifest, and
   CatalogSource readiness. A missing or mismatched listed version fails rather
   than silently selecting another version.
4. **Install** a dedicated all-namespaces OperatorGroup and a Manual
   Subscription with the expected `startingCSV`. Existing compatible resources
   are reused; incompatible OperatorGroups or Subscriptions fail clearly.
5. **Wait** on state, not fixed sleeps: Subscription conditions, InstallPlan
   `Complete`, expected CSV `Succeeded`, the CSV-owned Deployment `Available`,
   and `nexuses.operator.alaudadevops.io` established and discoverable.
6. **Test** by running the image's existing `nexus.test` binary with Godog
   `@e2e`. That scenario creates a uniquely named Nexus CR, waits for the
   instance, and invokes the Python Maven/PyPI repository checks. The real test
   exit code is preserved.
7. **Report** by retaining raw Allure results, generating the Allure report,
   and writing a small phase log. Empty Allure results are an infrastructure
   failure.
8. **Diagnose** failures with status-only OLM/workload/Event snapshots. The
   Operator installation is retained by default so the environment remains
   debuggable.

Every poll has a deadline and emits a heartbeat only when state changes or at a
bounded interval. The script has no unbounded wait and no success-masking
`|| true` around installation or test operations. Best-effort diagnostic
commands may use `|| true` only inside the failure trap.

## Idempotency and cleanup

On a second run, an existing expected `Succeeded` CSV and Available Deployment
are accepted. Namespace and OperatorGroup creation is declarative. Subscription
configuration is applied repeatedly only when its package, source, channel, and
starting CSV match the requested bundle version. An existing incompatible
resource fails instead of being overwritten silently.

Temporary authentication files and BDD configuration are always removed.
Operator, Subscription, InstallPlan, CSV, and CRDs are not removed on failure or
success. Test-resource cleanup remains the responsibility of the existing BDD
scenario; this PR does not introduce full Operator uninstall behavior.

## Test strategy

Tests are written before implementation and run in the existing pytest unit
suite. They cover:

- the fixed executable image path and Containerfile contract;
- missing required variables returning non-zero without exposing values;
- acceptance of `TOKEN` and fallback to username/password authentication;
- exact version extraction from `L5_PLUGINS_VERSION`;
- PackageManifest version mismatch and unhealthy CatalogSource failures;
- first-install and already-installed OLM paths using fake `kubectl` state;
- Manual InstallPlan approval, terminal Subscription conditions, and timeouts;
- dynamic CSV and Deployment discovery;
- propagation of the Godog E2E exit code;
- non-empty Allure result enforcement and report generation;
- diagnostics that contain no Secret reads or credential output.

Local verification consists of `bash -n`, the pytest unit suite, Containerfile
contract tests, and an image build when the local builder is available. The PR
pipeline is expected to build the test image and run the repository integration
checks; no release tag is consumed by operator or release-config until review.

## Follow-up after review

After this PR merges to `alauda-76.0`, a separate `nexus-ce-operator` PR updates
the `charts/current` gitlink to the merged commit. Its integration pipeline
builds the version-paired `nexus-ce-test` image, and the release branch's
manifest updater records the exact test image. Only then should artifacts and
release-config consume the new Operator/test-image pair.
