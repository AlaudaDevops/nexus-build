# Nexus Lynx Connectors Parity Design

## Goal

Make the Nexus Lynx test entrypoint follow the proven connectors MR !66 behavior for ACP dailybuild environments with self-signed certificates and for setup-failure reporting.

## Design

- ACP authentication curl requests always use insecure TLS, matching connectors MR !66.
- The generated proxy kubeconfig always sets `insecure-skip-tls-verify: true`, so TLS behavior remains consistent after authentication.
- Curl stderr remains visible while credentials, tokens, and response bodies remain unlogged.
- The EXIT trap always attempts Allure result/report collection. A setup failure still returns the original non-zero status, and missing test results remain diagnosable instead of silently appearing successful.
- Existing Nexus-specific exact L5/CSV resolution and OLM readiness checks remain unchanged.

## Verification

- Unit tests prove curl uses insecure TLS and does not discard stderr.
- Unit tests prove the proxy kubeconfig contains `insecure-skip-tls-verify: true` without exposing its token.
- Unit tests prove setup failures invoke report collection and preserve failure.
- The complete Nexus Lynx unit suite, shell syntax checks, and container build configuration tests pass before pushing.

