import json
import os
import re
import subprocess
import time
from pathlib import Path

import pytest


COMMON = Path(__file__).parents[2] / "lynx" / "common.sh"
AUTH = Path(__file__).parents[2] / "lynx" / "auth.sh"
OLM = Path(__file__).parents[2] / "lynx" / "olm.sh"
E2E = Path(__file__).parents[2] / "lynx" / "e2e.sh"
DIAGNOSTICS = Path(__file__).parents[2] / "lynx" / "diagnostics.sh"
ENTRYPOINT = Path(__file__).parents[2] / "lynx-entrypoint.sh"
CONTAINERFILE = Path(__file__).parents[2] / "Containerfile"
HOTFIX_CONTAINERFILE = Path(__file__).parents[2] / "Containerfile.lynx-hotfix"
INTEGRATION_PIPELINE = Path(__file__).parents[3] / ".tekton" / "integration-test.yaml"
TIMESTAMP = r"\[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\]"


def run_bash(script, *, env=None, timeout=5):
    command_env = os.environ.copy()
    command_env["LC_ALL"] = "C"
    if env:
        command_env.update(env)
    return subprocess.run(
        ["bash", "-c", f'source "$1"\n{script}', "bash", str(COMMON)],
        text=True,
        capture_output=True,
        env=command_env,
        timeout=timeout,
    )


def run_auth_bash(script, *, env=None, timeout=5):
    return run_bash(f'source "{AUTH}"\n{script}', env=env, timeout=timeout)


def run_olm_bash(script, *, env=None, timeout=5):
    return run_bash(f'source "{OLM}"\n{script}', env=env, timeout=timeout)


def run_e2e_bash(script, *, env=None, timeout=5):
    return run_bash(f'source "{E2E}"\n{script}', env=env, timeout=timeout)


def run_diagnostics_bash(script, *, env=None, timeout=5):
    return run_bash(f'source "{DIAGNOSTICS}"\n{script}', env=env, timeout=timeout)


def write_fake_kubectl(tmp_path, body):
    fake = tmp_path / "kubectl"
    fake.write_text("#!/usr/bin/env bash\nset -eu\n" + body)
    fake.chmod(0o755)
    return fake


def olm_env(tmp_path, **extra):
    return {
        "PATH": f"{tmp_path}:{os.environ['PATH']}",
        "L5_PLUGINS_VERSION": '{"nexus-ce-operator":"nexus-ce-operator.v4.2.1"}',
        "LYNX_POLL_INTERVAL": "1",
        "LYNX_WAIT_HEARTBEAT": "1",
        "LYNX_INSTALL_TIMEOUT": "2",
        **extra,
    }


def test_resolve_operator_catalog_uses_selected_channel_and_exact_listed_csv(tmp_path):
    write_fake_kubectl(
        tmp_path,
        '''
[[ "$*" == *"get packagemanifests"* ]] || exit 91
cat <<'JSON'
{"items":[{"metadata":{"name":"other"}},{"metadata":{"name":"nexus-ce-operator"},"status":{"catalogSource":"nexus-catalog","catalogSourceNamespace":"olm","channels":[{"name":"fast","currentCSV":"wrong.v9"},{"name":"stable","currentCSV":"nexus-ce-operator.v4.2.1"}]}}]}
JSON
''',
    )
    result = run_olm_bash(
        'resolve_operator_catalog; printf "%s|%s|%s\\n" "$OPERATOR_CSV" "$CATALOG_SOURCE" "$CATALOG_NAMESPACE"',
        env=olm_env(tmp_path),
    )

    assert result.returncode == 0, result.stderr
    assert result.stdout == "nexus-ce-operator.v4.2.1|nexus-catalog|olm\n"


def test_resolve_operator_catalog_accepts_release_version_from_lynx(tmp_path):
    write_fake_kubectl(
        tmp_path,
        '''cat <<'JSON'
{"items":[{"metadata":{"name":"nexus-ce-operator"},"status":{"catalogSource":"catalog","catalogSourceNamespace":"olm","channels":[{"name":"stable","currentCSV":"nexus-ce-operator.v3.76.12"}]}}]}
JSON
''',
    )
    result = run_olm_bash(
        'resolve_operator_catalog; printf "%s\\n" "$OPERATOR_CSV"',
        env=olm_env(tmp_path, L5_PLUGINS_VERSION='{"nexus-ce-operator":"3.76.12"}'),
    )

    assert result.returncode == 0, result.stderr
    assert result.stdout == "nexus-ce-operator.v3.76.12\n"


def test_resolve_operator_catalog_rejects_channel_version_mismatch(tmp_path):
    write_fake_kubectl(
        tmp_path,
        '''cat <<'JSON'
{"items":[{"metadata":{"name":"nexus-ce-operator"},"status":{"catalogSource":"catalog","catalogSourceNamespace":"olm","channels":[{"name":"stable","currentCSV":"nexus-ce-operator.v9.9.9"}]}}]}
JSON
''',
    )
    result = run_olm_bash("resolve_operator_catalog", env=olm_env(tmp_path))

    assert result.returncode != 0
    assert "does not match" in result.stderr


@pytest.mark.parametrize(("operator_groups", "target_namespaces", "ok"), [("0", "", True), ("1", "", True), ("1", "other", False), ("2", "", False)])
def test_ensure_operator_group_requires_one_dedicated_all_namespaces_group(
    tmp_path, operator_groups, target_namespaces, ok
):
    calls = tmp_path / "calls"
    write_fake_kubectl(
        tmp_path,
        '''
printf '%s\n' "$*" >> "$CALLS"
if [[ "$*" == *"get operatorgroups"* ]]; then
  printf '{"items":['
  if [[ "$OG_COUNT" != 0 ]]; then printf '{"spec":{"targetNamespaces":%s}}' "${OG_TARGET:-[]}"; fi
  if [[ "$OG_COUNT" == 2 ]]; then printf ',{"spec":{}}'; fi
  printf ']}\n'
elif [[ "$*" == *"apply -f -"* ]]; then cat >/dev/null
fi
''',
    )
    target = json.dumps([target_namespaces]) if target_namespaces else "[]"
    result = run_olm_bash(
        "ensure_operator_group",
        env=olm_env(tmp_path, CALLS=str(calls), OG_COUNT=operator_groups, OG_TARGET=target),
    )

    assert (result.returncode == 0) is ok
    if operator_groups == "0":
        assert "apply -f -" in calls.read_text()


def test_ensure_subscription_rejects_incompatible_existing_resource(tmp_path):
    write_fake_kubectl(
        tmp_path,
        '''
if [[ "$*" == *"get subscription"* ]]; then
cat <<'JSON'
{"spec":{"name":"nexus-ce-operator","source":"wrong-catalog","sourceNamespace":"olm","channel":"stable","startingCSV":"nexus-ce-operator.v4.2.1","installPlanApproval":"Manual"}}
JSON
fi
''',
    )
    result = run_olm_bash(
        'OPERATOR_CSV=nexus-ce-operator.v4.2.1; CATALOG_SOURCE=catalog; CATALOG_NAMESPACE=olm; ensure_subscription',
        env=olm_env(tmp_path),
    )

    assert result.returncode != 0
    assert "incompatible" in result.stderr


def test_ensure_subscription_applies_only_after_successful_not_found_get(tmp_path):
    calls = tmp_path / "calls"
    write_fake_kubectl(
        tmp_path,
        '''
printf '%s\n' "$*" >> "$CALLS"
if [[ "$*" == *"get subscription"* ]]; then
  [[ "$*" == *"--ignore-not-found"* ]] || exit 88
elif [[ "$*" == *"apply -f -"* ]]; then
  cat >/dev/null
fi
''',
    )
    result = run_olm_bash(
        'OPERATOR_CSV=nexus-ce-operator.v4.2.1; CATALOG_SOURCE=catalog; CATALOG_NAMESPACE=olm; ensure_subscription',
        env=olm_env(tmp_path, CALLS=str(calls)),
    )

    assert result.returncode == 0, result.stderr
    assert "apply -f -" in calls.read_text()


def test_ensure_subscription_does_not_apply_after_operational_get_failure(tmp_path):
    calls = tmp_path / "calls"
    write_fake_kubectl(
        tmp_path,
        '''
printf '%s\n' "$*" >> "$CALLS"
if [[ "$*" == *"get subscription"* ]]; then exit 73
elif [[ "$*" == *"apply -f -"* ]]; then cat >/dev/null
fi
''',
    )
    result = run_olm_bash(
        'OPERATOR_CSV=nexus-ce-operator.v4.2.1; CATALOG_SOURCE=catalog; CATALOG_NAMESPACE=olm; ensure_subscription',
        env=olm_env(tmp_path, CALLS=str(calls)),
    )

    assert result.returncode != 0
    assert "apply -f -" not in calls.read_text()


def test_wait_for_install_plan_fails_on_terminal_subscription_condition(tmp_path):
    write_fake_kubectl(
        tmp_path,
        '''
if [[ "$*" == *"get subscription"* ]]; then
  printf '%s\n' '{"status":{"conditions":[{"type":"ResolutionFailed","status":"True","reason":"ConstraintsNotSatisfiable"}]}}'
fi
''',
    )
    result = run_olm_bash("wait_for_install_plan", env=olm_env(tmp_path))

    assert result.returncode != 0
    assert "ResolutionFailed" in result.stderr


def test_install_operator_is_idempotent_and_verifies_dynamic_deployment_and_crd(tmp_path):
    calls = tmp_path / "calls"
    state = tmp_path / "state"
    write_fake_kubectl(
        tmp_path,
        '''
printf '%s\n' "$*" >> "$CALLS"
case "$*" in
  *"get packagemanifests"*) printf '%s\n' '{"items":[{"metadata":{"name":"nexus-ce-operator"},"status":{"catalogSource":"catalog","catalogSourceNamespace":"olm","channels":[{"name":"stable","currentCSV":"nexus-ce-operator.v4.2.1"}]}}]}' ;;
  *"get catalogsource catalog -n olm"*) printf '%s\n' '{"status":{"connectionState":{"lastObservedState":"READY"}}}' ;;
  *"get operatorgroups"*) if [[ -f "$STATE" ]]; then printf '%s\n' '{"items":[{"spec":{}}]}'; else printf '%s\n' '{"items":[]}'; fi ;;
  *"get subscription nexus-ce-operator"*)
    if [[ -f "$STATE" ]]; then printf '%s\n' '{"spec":{"name":"nexus-ce-operator","source":"catalog","sourceNamespace":"olm","channel":"stable","startingCSV":"nexus-ce-operator.v4.2.1","installPlanApproval":"Manual"},"status":{"installPlanRef":{"name":"ip-one"}}}'; fi ;;
  *"get installplan ip-one"*) printf '%s\n' '{"status":{"phase":"Complete"}}' ;;
  *"patch installplan ip-one"*) touch "$PLAN" ;;
  *"get clusterserviceversion nexus-ce-operator.v4.2.1"*) if [[ -f "$PLAN" ]]; then printf '%s\n' '{"status":{"phase":"Succeeded"},"spec":{"install":{"spec":{"deployments":[{"name":"nexus-operator-controller-manager"}]}}}}'; else printf '%s\n' '{"status":{"phase":"Pending"}}'; fi ;;
  *"get deployment nexus-operator-controller-manager"*) printf '%s\n' '{"status":{"conditions":[{"type":"Available","status":"True"}]}}' ;;
  *"get crd nexuses.operator.alaudadevops.io"*) printf '%s\n' '{"spec":{"versions":[{"name":"v1alpha1","served":true}]},"status":{"conditions":[{"type":"Established","status":"True"},{"type":"NamesAccepted","status":"True"}]}}' ;;
  *"api-resources"*) printf '%s\n' 'nexuses.operator.alaudadevops.io' ;;
  *"create namespace"*) printf '%s\n' 'apiVersion: v1' 'kind: Namespace' ;;
  *"apply -f -"*) cat >/dev/null; touch "$STATE" ;;
  *) exit 92 ;;
esac
''',
    )
    env = olm_env(tmp_path, CALLS=str(calls), STATE=str(state), PLAN=str(tmp_path / "plan"))

    first = run_olm_bash("install_operator", env=env, timeout=8)
    second = run_olm_bash("install_operator", env=env, timeout=8)

    assert first.returncode == 0, first.stderr
    assert second.returncode == 0, second.stderr
    all_calls = calls.read_text()
    assert "patch installplan ip-one" in all_calls
    assert "get deployment nexus-operator-controller-manager" in all_calls
    assert "api-resources" in all_calls


def test_wait_for_csv_times_out_with_bounded_polling(tmp_path):
    write_fake_kubectl(tmp_path, "printf '%s\\n' '{\"status\":{\"phase\":\"Pending\"}}'\n")
    result = run_olm_bash(
        "OPERATOR_CSV=nexus-ce-operator.v4.2.1; wait_for_csv",
        env=olm_env(tmp_path, LYNX_INSTALL_TIMEOUT="1"),
        timeout=3,
    )

    assert result.returncode != 0
    assert "timed out" in result.stderr.lower()


def test_install_operator_skips_install_plan_for_succeeded_exact_csv_but_verifies_runtime(tmp_path):
    marker = tmp_path / "verified"
    write_fake_kubectl(
        tmp_path,
        '''
if [[ "$*" == *"create namespace"* ]]; then printf '%s\n' 'kind: Namespace'
elif [[ "$*" == *"apply -f -"* ]]; then cat >/dev/null
else exit 90
fi
''',
    )
    result = run_olm_bash(
        f'''
resolve_operator_catalog() {{ OPERATOR_CSV=nexus-ce-operator.v4.2.1; CATALOG_SOURCE=c; CATALOG_NAMESPACE=n; }}
_catalog_ready() {{ printf READY; }}
ensure_operator_group() {{ :; }}
ensure_subscription() {{ :; }}
_csv_phase() {{ printf Succeeded; }}
wait_for_install_plan() {{ log "InstallPlan must not be required"; return 77; }}
wait_for_deployment() {{ printf deployment >> "{marker}"; }}
wait_for_nexus_crd() {{ printf crd >> "{marker}"; }}
install_operator
''',
        env=olm_env(tmp_path),
    )

    assert result.returncode == 0, result.stderr
    assert marker.read_text() == "deploymentcrd"


def test_olm_wait_value_bounds_hung_probe_and_emits_heartbeat():
    started_at = time.monotonic()
    result = run_olm_bash(
        '_hung_olm_probe() { sleep 10; printf ready; }; _olm_wait_value "hung OLM probe" ready 3 _hung_olm_probe',
        env={"LYNX_POLL_INTERVAL": "1", "LYNX_WAIT_HEARTBEAT": "1"},
        timeout=5,
    )

    assert result.returncode != 0
    assert time.monotonic() - started_at < 5
    assert result.stderr.lower().count("waiting") >= 2
    assert "timed out" in result.stderr.lower()


def test_wait_for_install_plan_bounds_hung_kubectl_and_emits_heartbeat(tmp_path):
    write_fake_kubectl(tmp_path, "sleep 10\n")
    started_at = time.monotonic()
    result = run_olm_bash(
        "wait_for_install_plan",
        env=olm_env(tmp_path, LYNX_INSTALL_TIMEOUT="3"),
        timeout=5,
    )

    assert result.returncode != 0
    assert time.monotonic() - started_at < 5
    assert result.stderr.lower().count("waiting") >= 2
    assert "timed out" in result.stderr.lower()


def test_wait_for_install_plan_bounds_hung_approval_patch(tmp_path):
    write_fake_kubectl(
        tmp_path,
        '''
if [[ "$*" == *"get subscription"* ]]; then
  printf '%s\n' '{"status":{"installPlanRef":{"name":"ip-one"}}}'
elif [[ "$*" == *"patch installplan ip-one"* ]]; then
  sleep 10
fi
''',
    )
    started_at = time.monotonic()
    result = run_olm_bash(
        "wait_for_install_plan",
        env=olm_env(tmp_path, LYNX_INSTALL_TIMEOUT="2"),
        timeout=4,
    )

    assert result.returncode != 0
    assert time.monotonic() - started_at < 4
    assert "deadline" in result.stderr.lower()


def test_install_operator_bounds_hung_namespace_precheck(tmp_path):
    write_fake_kubectl(tmp_path, "sleep 10\n")
    started_at = time.monotonic()
    result = run_olm_bash(
        "install_operator",
        env=olm_env(tmp_path, LYNX_INSTALL_TIMEOUT="1"),
        timeout=3,
    )

    assert result.returncode != 0
    assert time.monotonic() - started_at < 3


def test_log_and_fatal_write_timestamped_messages_to_stderr():
    result = run_bash('log "starting"; (fatal "stopped")')

    assert result.returncode != 0
    assert re.fullmatch(f"{TIMESTAMP} starting\n{TIMESTAMP} ERROR: stopped\n", result.stderr)
    assert result.stdout == ""


@pytest.mark.parametrize("state", ["unset", "empty"])
def test_require_env_rejects_unset_and_empty_values(state):
    setup = "unset LYNX_TEST_SECRET" if state == "unset" else "export LYNX_TEST_SECRET="
    result = run_bash(
        f'{setup}\nrequire_env LYNX_TEST_SECRET',
    )

    assert result.returncode != 0
    assert "LYNX_TEST_SECRET" in result.stderr


def test_require_env_accepts_a_nonempty_value_without_printing_it():
    secret = "should-never-be-printed"
    result = run_bash(
        'require_env LYNX_TEST_SECRET',
        env={"LYNX_TEST_SECRET": secret},
    )

    assert result.returncode == 0
    assert secret not in result.stdout + result.stderr


def test_run_bash_bounds_test_processes():
    with pytest.raises(subprocess.TimeoutExpired):
        run_bash("sleep 0.2", timeout=0.01)


def test_require_command_accepts_present_command_and_rejects_missing_command():
    present = run_bash("require_command bash")
    missing = run_bash("require_command definitely-not-a-real-lynx-command")

    assert present.returncode == 0
    assert missing.returncode != 0
    assert "definitely-not-a-real-lynx-command" in missing.stderr


@pytest.mark.parametrize("value", ["", "0", "-1", "+1", "1.0", " 1", "1 ", "abc"])
def test_require_positive_integer_rejects_invalid_values(value):
    result = run_bash(f"require_positive_integer RETRIES {json.dumps(value)}")

    assert result.returncode != 0
    assert "RETRIES" in result.stderr


@pytest.mark.parametrize("value", ["1", "42", "0007", "0008", "0009"])
def test_require_positive_integer_accepts_digit_only_nonzero_values(value):
    result = run_bash(f"require_positive_integer RETRIES {value}")

    assert result.returncode == 0
    assert value not in result.stdout + result.stderr


def test_listed_operator_version_selects_only_exact_operator_name():
    plugins = json.dumps(
        {
            "other-nexus-ce-operator": "secret-wrong",
            "nexus-ce-operator": "v4.2.1",
            "nexus-ce-operator-addon": "secret-addon",
        }
    )
    result = run_bash("listed_operator_version", env={"L5_PLUGINS_VERSION": plugins})

    assert result.returncode == 0, result.stderr
    assert result.stdout == "v4.2.1\n"
    assert "secret-wrong" not in result.stderr
    assert "secret-addon" not in result.stderr


@pytest.mark.parametrize(
    "plugins",
    ["not-json", "{}", '{"nexus-ce-operator": null}', '{"nexus-ce-operator": ""}'],
)
def test_listed_operator_version_fails_safely_for_invalid_or_missing_listing(plugins):
    result = run_bash("listed_operator_version", env={"L5_PLUGINS_VERSION": plugins})

    assert result.returncode != 0
    assert plugins not in result.stdout + result.stderr


def test_wait_for_value_returns_when_command_output_exactly_matches(tmp_path):
    attempts = tmp_path / "attempts"
    probe = tmp_path / "probe"
    probe.write_text(
        f'''#!/usr/bin/env bash
count=$(wc -l < "{attempts}" 2>/dev/null || printf 0)
printf 'x\\n' >> "{attempts}"
if (( count >= 1 )); then printf 'ready\\n'; else printf 'not-ready\\n'; fi
'''
    )
    probe.chmod(0o755)
    result = run_bash(
        f'wait_for_value "operator readiness" ready 3 "{probe}"',
        env={"LYNX_POLL_INTERVAL": "1", "LYNX_WAIT_HEARTBEAT": "1"},
    )

    assert result.returncode == 0, result.stderr
    assert len(attempts.read_text().splitlines()) >= 2
    assert "not-ready" not in result.stdout + result.stderr


def test_wait_for_value_is_bounded_and_heartbeats_without_command_output():
    secret_output = "sensitive-current-value"
    result = run_bash(
        f'''wait_for_value "operator readiness" ready 1 \
          bash -c "printf '%s\\n' {secret_output}"''',
        env={"LYNX_POLL_INTERVAL": "1", "LYNX_WAIT_HEARTBEAT": "1"},
    )

    assert result.returncode == 1
    assert "operator readiness" in result.stderr
    assert "waiting" in result.stderr.lower()
    assert "timed out" in result.stderr.lower()
    assert secret_output not in result.stdout + result.stderr


@pytest.mark.parametrize("name", ["LYNX_POLL_INTERVAL", "LYNX_WAIT_HEARTBEAT"])
@pytest.mark.parametrize("value", ["", "0", "-1", "1.5", "abc"])
def test_wait_for_value_rejects_invalid_timing_settings(name, value):
    result = run_bash(
        'wait_for_value "operator readiness" ready 1 printf ready',
        env={name: value},
    )

    assert result.returncode != 0
    assert name in result.stderr


@pytest.mark.parametrize("name", ["LYNX_POLL_INTERVAL", "LYNX_WAIT_HEARTBEAT"])
def test_wait_for_value_does_not_evaluate_malicious_timing_settings(tmp_path, name):
    sentinel = tmp_path / "arithmetic-was-evaluated"
    malicious = f'1+$(touch "{sentinel}")'
    result = run_bash(
        'wait_for_value "operator readiness" ready 1 printf ready',
        env={name: malicious},
    )

    assert result.returncode != 0
    assert name in result.stderr
    assert not sentinel.exists()
    assert malicious not in result.stdout + result.stderr


def test_wait_for_value_times_out_a_hanging_probe():
    started_at = time.monotonic()
    result = run_bash(
        'wait_for_value "hanging probe" ready 1 bash -c "sleep 10; printf ready"',
        env={"LYNX_POLL_INTERVAL": "1", "LYNX_WAIT_HEARTBEAT": "1"},
        timeout=3,
    )

    assert result.returncode == 1
    assert time.monotonic() - started_at < 3
    assert "timed out" in result.stderr.lower()


@pytest.mark.parametrize("timeout", ["0008", "0009"])
def test_wait_for_value_treats_leading_zero_timeout_as_decimal(timeout):
    result = run_bash(
        f'wait_for_value "operator readiness" ready {timeout} printf ready',
        env={"LYNX_POLL_INTERVAL": "1", "LYNX_WAIT_HEARTBEAT": "1"},
    )

    assert result.returncode == 0, result.stderr


@pytest.mark.parametrize("name", ["LYNX_POLL_INTERVAL", "LYNX_WAIT_HEARTBEAT"])
@pytest.mark.parametrize("value", ["0008", "0009"])
def test_wait_for_value_treats_leading_zero_timing_settings_as_decimal(name, value):
    result = run_bash(
        'wait_for_value "operator readiness" ready 1 printf not-ready',
        env={name: value},
        timeout=3,
    )

    assert result.returncode == 1
    assert "timed out" in result.stderr.lower()


def test_resolve_access_token_uses_preissued_token_without_password_login(tmp_path):
    fake_curl = tmp_path / "curl"
    fake_curl.write_text("#!/usr/bin/env bash\nprintf 'curl must not run\\n' >&2\nexit 99\n")
    fake_curl.chmod(0o755)
    token = "preissued-secret-token"

    result = run_auth_bash(
        "resolve_access_token",
        env={"PATH": f"{tmp_path}:{os.environ['PATH']}", "TOKEN": token},
    )

    assert result.returncode == 0, result.stderr
    assert result.stdout == token
    assert result.stderr == ""


def test_resolve_access_token_requires_a_complete_authentication_method():
    result = run_auth_bash(
        "unset TOKEN USERNAME PASSWORD\nresolve_access_token",
        env={"API_URL": "https://acp.example.test"},
    )

    assert result.returncode != 0
    assert "TOKEN" in result.stderr
    assert "USERNAME" in result.stderr
    assert "PASSWORD" in result.stderr


def test_password_login_uses_secure_bounded_acp_dex_flow_without_leaking_credentials(
    tmp_path,
):
    fake_bin = tmp_path / "bin"
    fake_bin.mkdir()
    calls = tmp_path / "curl.calls"
    fake_curl = fake_bin / "curl"
    fake_curl.write_text(
        '''#!/usr/bin/env bash
printf '%s\\n' "$*" >> "$LYNX_TEST_CURL_CALLS"
case "$*" in
  *'/console-platform/api/v1/token/login'*)
    printf '%s\\n' '{"auth_url":"https://external/dex/auth?client_id=console%2Bui&state=opaque%26state#ignored-fragment"}' ;;
  *'/dex/api/v1/authorize/local'*)
    printf '%s\\n' '{"redirect_url":"https://acp.example.test/console-platform?code=a%26b%23c%2Bd%3De%25f&state=s%26t%23u%2Bv%3Dw%25x#ignored"}' ;;
  *'/dex/api/v1/authorize'*) printf '%s\\n' '{"req":"request&#+=%value"}' ;;
  *'/dex/pubkey'*) printf '%s\\n' '{"pubkey":"PUBLIC KEY DATA","ts":"123"}' ;;
  *'/console-platform/api/v1/token/callback'*) printf '%s\\n' '{"id_token":"issued-secret-token"}' ;;
  *) exit 88 ;;
esac
'''
    )
    fake_curl.chmod(0o755)
    fake_openssl = fake_bin / "openssl"
    fake_openssl.write_text(
        '''#!/usr/bin/env bash
if [[ $1 == pkeyutl ]]; then
  [[ "$*" == *'-pkeyopt rsa_padding_mode:pkcs1'* ]] || exit 91
  cat >/dev/null
  printf cipher
elif [[ $1 == base64 ]]; then
  cat >/dev/null
  printf encrypted-password
else
  exit 92
fi
'''
    )
    fake_openssl.chmod(0o755)
    password = "password-must-stay-secret"
    username = "username-must-stay-secret"

    result = run_auth_bash(
        "resolve_access_token",
        env={
            "PATH": f"{fake_bin}:{os.environ['PATH']}",
            "API_URL": "https://acp.example.test/",
            "USERNAME": username,
            "PASSWORD": password,
            "LYNX_TEST_CURL_CALLS": str(calls),
            "LYNX_HTTP_TIMEOUT": "7",
        },
    )

    assert result.returncode == 0, result.stderr
    assert result.stdout == "issued-secret-token"
    assert password not in result.stdout + result.stderr
    assert username not in result.stdout + result.stderr
    curl_calls = calls.read_text()
    assert "/console-platform/api/v1/token/login" in curl_calls
    assert "/dex/api/v1/authorize" in curl_calls
    assert "/dex/pubkey" in curl_calls
    assert "/dex/api/v1/authorize/local" in curl_calls
    assert "/console-platform/api/v1/token/callback" in curl_calls
    assert "--max-time 7" in curl_calls
    assert "--fail-with-body" in curl_calls
    assert "--data-urlencode client_id=console+ui" in curl_calls
    assert "--data-urlencode state=opaque&state" in curl_calls
    assert "ignored-fragment" not in curl_calls
    assert "--url-query req=request&#+=%value" in curl_calls
    assert "--data-urlencode code=a&b#c+d=e%f" in curl_calls
    assert "--data-urlencode state=s&t#u+v=w%x" in curl_calls
    assert "--insecure" in curl_calls


def test_password_login_preserves_curl_error_details(tmp_path):
    fake_curl = tmp_path / "curl"
    fake_curl.write_text("#!/usr/bin/env bash\nprintf 'certificate verification failed\\n' >&2\nexit 60\n")
    fake_curl.chmod(0o755)

    result = run_auth_bash(
        "resolve_access_token",
        env={
            "PATH": f"{tmp_path}:{os.environ['PATH']}",
            "API_URL": "https://acp.example.test",
            "USERNAME": "user",
            "PASSWORD": "secret",
        },
    )

    assert result.returncode != 0
    assert "certificate verification failed" in result.stderr
    assert "ACP token login request failed" in result.stderr


def test_write_proxy_kubeconfig_uses_region_proxy_and_mode_0600(tmp_path):
    kubeconfig = tmp_path / "proxy.kubeconfig"
    token = "kubeconfig-secret-token"
    result = run_auth_bash(
        f'write_proxy_kubeconfig "{kubeconfig}" "$TOKEN"',
        env={
            "API_URL": "https://acp.example.test/",
            "REGION_NAME": "region-one",
            "REGISTRY_CLUSTER": "registry.example.test",
            "TOKEN": token,
        },
    )

    assert result.returncode == 0, result.stderr
    config = json.loads(kubeconfig.read_text())
    assert config["clusters"][0]["cluster"]["server"] == (
        "https://acp.example.test/kubernetes/region-one"
    )
    assert config["clusters"][0]["cluster"]["insecure-skip-tls-verify"] is True
    assert config["users"][0]["user"]["token"] == token
    assert kubeconfig.stat().st_mode & 0o777 == 0o600
    assert token not in result.stdout + result.stderr


def test_write_bdd_config_uses_acp_target_and_mode_0600(tmp_path):
    config_path = tmp_path / "config.yaml"
    token = "bdd-secret-token"
    result = run_auth_bash(
        f'write_bdd_config "{config_path}" "$TOKEN"',
        env={
            "API_URL": "https://acp.example.test/",
            "REGION_NAME": "region-one",
            "REGISTRY_CLUSTER": "registry.example.test",
            "TOKEN": token,
        },
    )

    assert result.returncode == 0, result.stderr
    config = json.loads(config_path.read_text())
    assert config == {
        "registry": {"cluster": "registry.example.test"},
        "acp": {
            "baseUrl": "https://acp.example.test",
            "token": token,
            "cluster": "region-one",
        }
    }
    assert config_path.stat().st_mode & 0o777 == 0o600
    assert token not in result.stdout + result.stderr


def test_write_bdd_config_reads_builtin_registry_from_target_cluster(tmp_path):
    config_path = tmp_path / "config.yaml"
    write_fake_kubectl(
        tmp_path,
        '''[[ "$*" == "get configmap global-info -n kube-public -o jsonpath={.data.registryAddress}" ]]
printf registry.from.cluster
''',
    )
    result = run_auth_bash(
        f'write_bdd_config "{config_path}" "$TOKEN"',
        env={
            "PATH": f"{tmp_path}:{os.environ['PATH']}",
            "API_URL": "https://acp.example.test",
            "REGION_NAME": "region-one",
            "TOKEN": "bdd-secret-token",
        },
    )

    assert result.returncode == 0, result.stderr
    assert json.loads(config_path.read_text())["registry"] == {
        "cluster": "registry.from.cluster"
    }


@pytest.mark.parametrize(
    ("function_name", "filename"),
    [("write_proxy_kubeconfig", "proxy.kubeconfig"), ("write_bdd_config", "config.yaml")],
)
@pytest.mark.parametrize("failed_command", ["chmod", "mv"])
def test_secret_config_writers_clean_temporary_files_on_command_failure(
    tmp_path, function_name, filename, failed_command
):
    fake_bin = tmp_path / "bin"
    fake_bin.mkdir()
    for command in ("chmod", "mv"):
        fake_command = fake_bin / command
        if command == failed_command:
            fake_command.write_text("#!/usr/bin/env bash\nexit 73\n")
        else:
            fake_command.write_text(f'#!/usr/bin/env bash\nexec /bin/{command} "$@"\n')
        fake_command.chmod(0o755)
    destination = tmp_path / filename
    token = "cleanup-secret-token"

    result = run_auth_bash(
        f'{function_name} "{destination}" "$TOKEN"',
        env={
            "PATH": f"{fake_bin}:{os.environ['PATH']}",
            "API_URL": "https://acp.example.test/",
            "REGION_NAME": "region-one",
            "TOKEN": token,
        },
    )

    assert result.returncode != 0
    assert not list(tmp_path.glob(f"{filename}.tmp.*"))
    assert token not in result.stdout + result.stderr


@pytest.mark.parametrize(
    ("function_name", "filename"),
    [("write_proxy_kubeconfig", "proxy.kubeconfig"), ("write_bdd_config", "config.yaml")],
)
def test_secret_config_writers_use_secure_destination_local_temporary_files(
    tmp_path, function_name, filename
):
    fake_bin = tmp_path / "bin"
    fake_bin.mkdir()
    mktemp_calls = tmp_path / "mktemp.calls"
    fake_mktemp = fake_bin / "mktemp"
    fake_mktemp.write_text(
        '#!/usr/bin/env bash\nprintf \'%s\\n\' "$*" >> "$LYNX_TEST_MKTEMP_CALLS"\n'
        'exec /usr/bin/mktemp "$@"\n'
    )
    fake_mktemp.chmod(0o755)
    destination = tmp_path / filename
    protected_target = tmp_path / "protected-target"
    protected_target.write_text("must-not-change")
    destination.symlink_to(protected_target)

    result = run_auth_bash(
        f'{function_name} "{destination}" "$TOKEN"',
        env={
            "PATH": f"{fake_bin}:{os.environ['PATH']}",
                "API_URL": "https://acp.example.test/",
                "REGION_NAME": "region-one",
                "REGISTRY_CLUSTER": "registry.example.test",
                "TOKEN": "temporary-file-secret",
            "LYNX_TEST_MKTEMP_CALLS": str(mktemp_calls),
        },
    )

    assert result.returncode == 0, result.stderr
    assert mktemp_calls.read_text().strip() == f"{destination}.tmp.XXXXXX"
    assert protected_target.read_text() == "must-not-change"
    assert not destination.is_symlink()
    assert not list(tmp_path.glob(f"{filename}.tmp.*"))


@pytest.mark.parametrize(
    ("function_name", "filename"),
    [("write_proxy_kubeconfig", "proxy.kubeconfig"), ("write_bdd_config", "config.yaml")],
)
def test_secret_config_writers_clean_temporary_files_when_signalled(
    tmp_path, function_name, filename
):
    fake_jq = tmp_path / "jq"
    fake_jq.write_text(
        "#!/usr/bin/env bash\n"
        "printf partial-secret-output\n"
        'kill -TERM "$PPID"\n'
    )
    fake_jq.chmod(0o755)
    destination = tmp_path / filename

    result = run_auth_bash(
        f'{function_name} "{destination}" "$TOKEN"',
        env={
            "PATH": f"{tmp_path}:{os.environ['PATH']}",
            "API_URL": "https://acp.example.test/",
            "REGION_NAME": "region-one",
            "TOKEN": "signal-cleanup-secret",
        },
    )

    assert result.returncode != 0
    assert not list(tmp_path.glob(f"{filename}.tmp.*"))


def test_run_e2e_uses_godog_tags_config_and_preserves_test_exit(tmp_path):
    testing_dir = tmp_path / "testing"
    testing_dir.mkdir()
    calls = tmp_path / "nexus.calls"
    nexus = testing_dir / "nexus.test"
    nexus.write_text(
        "#!/usr/bin/env bash\n"
        'printf \'%s|%s|%s\\n\' "$PWD" "$TESTING_CONFIG" "$*" > "$LYNX_TEST_CALLS"\n'
        "exit 37\n"
    )
    nexus.chmod(0o755)
    config = tmp_path / "config.yaml"
    config.write_text("{}\n")

    result = run_e2e_bash(
        "run_e2e",
        env={
            "LYNX_TESTING_DIR": str(testing_dir),
            "LYNX_BDD_CONFIG": str(config),
            "LYNX_E2E_TAGS": "@e2e && ~@slow",
            "LYNX_TEST_CALLS": str(calls),
        },
    )

    assert result.returncode == 37
    cwd, e2e_config, args = calls.read_text().strip().split("|", 2)
    assert cwd == str(testing_dir)
    assert e2e_config == str(config)
    assert args == (
        "--godog.concurrency=2 --godog.format=allure "
        "--godog.tags=@e2e && ~@slow"
    )


def test_prepare_e2e_idempotently_applies_bdd_lock_namespace(tmp_path):
    calls = tmp_path / "kubectl.calls"
    write_fake_kubectl(
        tmp_path,
        '''printf '%s\n' "$*" >> "$CALLS"
if [[ "$*" == *"create namespace"* ]]; then
  printf '%s\n' 'apiVersion: v1' 'kind: Namespace' 'metadata:' '  name: bdd-testing'
else
  cat >/dev/null
fi
''',
    )
    env = {
        "PATH": f"{tmp_path}:{os.environ['PATH']}",
        "CALLS": str(calls),
        "LYNX_INSTALL_TIMEOUT": "2",
    }

    first = run_e2e_bash("prepare_e2e", env=env)
    second = run_e2e_bash("prepare_e2e", env=env)

    assert first.returncode == 0, first.stderr
    assert second.returncode == 0, second.stderr
    recorded = calls.read_text()
    assert recorded.count("create namespace bdd-testing --dry-run=client -o yaml") == 2
    assert recorded.count("apply -f -") == 2


def test_run_e2e_defaults_to_e2e_tag_and_uses_writable_copy(tmp_path):
    testing_dir = tmp_path / "read-only-testing"
    testing_dir.mkdir()
    calls = tmp_path / "nexus.calls"
    nexus = testing_dir / "nexus.test"
    nexus.write_text(
        "#!/usr/bin/env bash\n"
        'printf \'%s|%s\\n\' "$PWD" "$*" > "$LYNX_TEST_CALLS"\n'
    )
    nexus.chmod(0o555)
    testing_dir.chmod(0o555)
    config = tmp_path / "config.yaml"
    config.write_text("{}\n")

    result = run_e2e_bash(
        "run_e2e",
        env={
            "LYNX_TESTING_DIR": str(testing_dir),
            "LYNX_BDD_CONFIG": str(config),
            "LYNX_TEST_CALLS": str(calls),
        },
    )

    assert result.returncode == 0, result.stderr
    cwd, args = calls.read_text().strip().split("|", 1)
    assert cwd != str(testing_dir)
    assert args == "--godog.concurrency=2 --godog.format=allure --godog.tags=@e2e"
    assert Path(cwd).exists() is False


def test_collect_allure_results_normalizes_raw_results(tmp_path):
    raw = tmp_path / "raw" / "allure-results"
    raw.mkdir(parents=True)
    (raw / "one-result.json").write_text('{"status":"passed"}\n')
    result_dir = tmp_path / "results"

    result = run_e2e_bash(
        "collect_allure_results",
        env={"LYNX_RAW_ALLURE_DIR": str(raw), "RESULT_DIR": str(result_dir)},
    )

    assert result.returncode == 0, result.stderr
    assert (result_dir / "allure-result" / "one-result.json").is_file()


def test_collect_allure_results_replaces_stale_destination(tmp_path):
    raw = tmp_path / "raw"
    raw.mkdir()
    (raw / "new.json").write_text("new\n")
    destination = tmp_path / "results" / "allure-result"
    destination.mkdir(parents=True)
    (destination / "stale.json").write_text("stale\n")

    result = run_e2e_bash(
        "collect_allure_results",
        env={"LYNX_RAW_ALLURE_DIR": str(raw), "RESULT_DIR": str(tmp_path / "results")},
    )

    assert result.returncode == 0, result.stderr
    assert sorted(path.name for path in destination.iterdir()) == ["new.json"]


def test_collect_allure_results_rejects_symlink_destination(tmp_path):
    raw = tmp_path / "raw"
    raw.mkdir()
    (raw / "new.json").write_text("new\n")
    protected = tmp_path / "protected"
    protected.mkdir()
    (protected / "keep").write_text("unchanged\n")
    result_dir = tmp_path / "results"
    result_dir.mkdir()
    (result_dir / "allure-result").symlink_to(protected)

    result = run_e2e_bash(
        "collect_allure_results",
        env={"LYNX_RAW_ALLURE_DIR": str(raw), "RESULT_DIR": str(result_dir)},
    )

    assert result.returncode != 0
    assert (protected / "keep").read_text() == "unchanged\n"
    assert not (protected / "new.json").exists()


def test_collect_allure_results_copy_failure_keeps_old_results_and_cleans_stage(tmp_path):
    raw = tmp_path / "raw"
    raw.mkdir()
    (raw / "new.json").write_text("new\n")
    result_dir = tmp_path / "results"
    destination = result_dir / "allure-result"
    destination.mkdir(parents=True)
    (destination / "old.json").write_text("old\n")
    fake_cp = tmp_path / "cp"
    fake_cp.write_text(
        "#!/usr/bin/env bash\n"
        'destination=${!#}\nmkdir -p "$destination"\nprintf partial > "$destination/partial"\nexit 74\n'
    )
    fake_cp.chmod(0o755)

    result = run_e2e_bash(
        "collect_allure_results",
        env={
            "PATH": f"{tmp_path}:{os.environ['PATH']}",
            "LYNX_RAW_ALLURE_DIR": str(raw),
            "RESULT_DIR": str(result_dir),
        },
    )

    assert result.returncode != 0
    assert sorted(path.name for path in destination.iterdir()) == ["old.json"]
    assert not list(result_dir.glob(".allure-result.tmp.*"))


def test_collect_allure_results_fails_when_raw_results_are_empty(tmp_path):
    raw = tmp_path / "allure-results"
    raw.mkdir()

    result = run_e2e_bash(
        "collect_allure_results",
        env={"LYNX_RAW_ALLURE_DIR": str(raw), "RESULT_DIR": str(tmp_path / "results")},
    )

    assert result.returncode != 0
    assert "empty" in result.stderr.lower()


def test_generate_allure_report_is_attempted_for_nonempty_results(tmp_path):
    result_dir = tmp_path / "results"
    raw = result_dir / "allure-result"
    raw.mkdir(parents=True)
    (raw / "one-result.json").write_text("{}\n")
    calls = tmp_path / "allure.calls"
    fake_allure = tmp_path / "allure"
    fake_allure.write_text(
        "#!/usr/bin/env bash\n"
        'printf \'%s\\n\' "$*" > "$LYNX_TEST_CALLS"\n'
        "exit 29\n"
    )
    fake_allure.chmod(0o755)

    result = run_e2e_bash(
        "generate_allure_report",
        env={
            "PATH": f"{tmp_path}:{os.environ['PATH']}",
            "RESULT_DIR": str(result_dir),
            "LYNX_TEST_CALLS": str(calls),
        },
    )

    assert result.returncode == 0, result.stderr
    assert calls.read_text().strip() == (
        f"generate {raw} --clean -o {result_dir / 'allure-report'}"
    )


def test_generate_allure_report_rejects_symlink_destination_without_invoking_allure(tmp_path):
    result_dir = tmp_path / "results"
    raw = result_dir / "allure-result"
    raw.mkdir(parents=True)
    (raw / "one-result.json").write_text("{}\n")
    protected = tmp_path / "protected-report"
    protected.mkdir()
    (protected / "keep").write_text("unchanged\n")
    (result_dir / "allure-report").symlink_to(protected)
    marker = tmp_path / "allure-called"
    fake_allure = tmp_path / "allure"
    fake_allure.write_text(
        "#!/usr/bin/env bash\n"
        'touch "$LYNX_TEST_MARKER"\n'
        "exit 99\n"
    )
    fake_allure.chmod(0o755)

    result = run_e2e_bash(
        "generate_allure_report",
        env={
            "PATH": f"{tmp_path}:{os.environ['PATH']}",
            "RESULT_DIR": str(result_dir),
            "LYNX_TEST_MARKER": str(marker),
        },
    )

    assert result.returncode != 0
    assert (protected / "keep").read_text() == "unchanged\n"
    assert not marker.exists()


@pytest.mark.parametrize("test_exit", [0, 37])
def test_run_e2e_raw_copy_failure_is_not_masked_and_preserves_test_failure(tmp_path, test_exit):
    testing_dir = tmp_path / "testing"
    testing_dir.mkdir()
    nexus = testing_dir / "nexus.test"
    nexus.write_text(
        "#!/usr/bin/env bash\nmkdir -p allure-results\nprintf result > allure-results/result.json\n"
        f"exit {test_exit}\n"
    )
    nexus.chmod(0o555)
    testing_dir.chmod(0o555)
    config = tmp_path / "config.yaml"
    config.write_text("{}\n")
    fake_bin = tmp_path / "bin"
    fake_bin.mkdir()
    fake_cp = fake_bin / "cp"
    fake_cp.write_text(
        "#!/usr/bin/env bash\n"
        'if [[ "$*" == *allure-results* ]]; then exit 74; fi\nexec /bin/cp "$@"\n'
    )
    fake_cp.chmod(0o755)

    result = run_e2e_bash(
        "run_e2e",
        env={
            "PATH": f"{fake_bin}:{os.environ['PATH']}",
            "LYNX_TESTING_DIR": str(testing_dir),
            "LYNX_BDD_CONFIG": str(config),
            "RESULT_DIR": str(tmp_path / "results"),
        },
    )

    assert result.returncode == (test_exit or 1)
    assert not list((tmp_path / "results").glob(".lynx-raw-allure.*"))


def test_collect_allure_results_cleans_temporary_raw_copy(tmp_path):
    testing_dir = tmp_path / "testing"
    testing_dir.mkdir()
    nexus = testing_dir / "nexus.test"
    nexus.write_text(
        "#!/usr/bin/env bash\nmkdir -p allure-results\nprintf result > allure-results/result.json\n"
    )
    nexus.chmod(0o555)
    testing_dir.chmod(0o555)
    config = tmp_path / "config.yaml"
    config.write_text("{}\n")
    raw_path = tmp_path / "raw-path"

    result = run_e2e_bash(
        f'run_e2e && printf %s "$LYNX_RAW_ALLURE_DIR" > "{raw_path}" && collect_allure_results',
        env={
            "LYNX_TESTING_DIR": str(testing_dir),
            "LYNX_BDD_CONFIG": str(config),
            "RESULT_DIR": str(tmp_path / "results"),
        },
    )

    assert result.returncode == 0, result.stderr
    assert not Path(raw_path.read_text()).exists()


def test_collect_diagnostics_queries_only_bounded_status_resources(tmp_path):
    calls = tmp_path / "kubectl.calls"
    write_fake_kubectl(
        tmp_path,
        '''printf '%s\n' "$*" >> "$LYNX_TEST_CALLS"
printf '%s\n' 'status output containing token diagnostic-secret-token'
printf '%s\n' 'endpoint https://diagnostic-user:diagnostic-password@example.test/repository'
printf '%s\n' 'credential diagnostic-generic-credential'
printf '%s\n' 'TOKEN=DIAGNOSTIC-UPPER-TOKEN'
printf '%s\n' 'token="diagnostic quoted token"'
printf '%s\n' 'Authorization: Bearer diagnostic-bearer remainder-secret'
printf '%s\n' 'nexus-ce-operator Succeeded Available'
printf '%s\n' 'stderr diagnostic-stderr-secret' >&2
''',
    )
    result_dir = tmp_path / "results"

    result = run_diagnostics_bash(
        "collect_diagnostics",
        env={
            "PATH": f"{tmp_path}:{os.environ['PATH']}",
            "KUBECONFIG": str(tmp_path / "proxy.kubeconfig"),
            "OPERATOR_NAMESPACE": "nexus-ce-operator",
            "RESULT_DIR": str(result_dir),
            "LYNX_DIAGNOSTICS_TIMEOUT": "2",
            "LYNX_TEST_CALLS": str(calls),
        },
    )

    assert result.returncode == 0, result.stderr
    all_calls = calls.read_text().lower()
    assert "--request-timeout=2s" in all_calls
    assert any(resource in all_calls for resource in ("subscription", "clusterserviceversion"))
    assert "deployment" in all_calls
    assert "event" in all_calls
    assert "secret" not in all_calls
    assert "configmap" not in all_calls
    event_call = next(line for line in all_calls.splitlines() if "get events" in line)
    assert ".message" not in event_call
    diagnostic = (result_dir / "diagnostics.log").read_text()
    assert "## OLM subscriptions" in diagnostic
    assert "nexus-ce-operator Succeeded Available" in diagnostic
    assert "diagnostic-secret-token" not in diagnostic
    assert "diagnostic-user" not in diagnostic
    assert "diagnostic-password" not in diagnostic
    assert "diagnostic-generic-credential" not in diagnostic
    assert "DIAGNOSTIC-UPPER-TOKEN" not in diagnostic
    assert "diagnostic quoted token" not in diagnostic
    assert "diagnostic-bearer" not in diagnostic
    assert "remainder-secret" not in diagnostic
    assert "diagnostic-stderr-secret" not in diagnostic


def test_collect_diagnostics_rejects_symlink_log_destination(tmp_path):
    protected = tmp_path / "protected.log"
    protected.write_text("unchanged\n")
    result_dir = tmp_path / "results"
    result_dir.mkdir()
    (result_dir / "diagnostics.log").symlink_to(protected)

    result = run_diagnostics_bash(
        "collect_diagnostics",
        env={"RESULT_DIR": str(result_dir)},
    )

    assert result.returncode != 0
    assert protected.read_text() == "unchanged\n"
    assert not list(result_dir.glob(".diagnostics.tmp.*"))


def test_collect_diagnostics_does_not_publish_when_sanitizer_fails(tmp_path):
    result_dir = tmp_path / "results"
    result_dir.mkdir()
    output = result_dir / "diagnostics.log"
    output.write_text("previous diagnostics\n")

    result = run_diagnostics_bash(
        "_mask_diagnostic_output() { return 71; }; collect_diagnostics",
        env={"RESULT_DIR": str(result_dir)},
    )

    assert result.returncode != 0
    assert output.read_text() == "previous diagnostics\n"
    assert not list(result_dir.glob(".diagnostics.tmp.*"))


def write_entrypoint_fixture(tmp_path, functions):
    fixture = tmp_path / "fixture"
    libraries = fixture / "lynx"
    libraries.mkdir(parents=True)
    (fixture / "lynx-entrypoint.sh").write_bytes(ENTRYPOINT.read_bytes())
    for name in ("common", "auth", "olm", "e2e", "diagnostics"):
        (libraries / f"{name}.sh").write_text(functions)
    return fixture / "lynx-entrypoint.sh"


def test_entrypoint_runs_phases_in_order_and_cleans_credentials(tmp_path):
    calls = tmp_path / "calls"
    result_dir = tmp_path / "results"
    functions = '''
log() { printf '%s\n' "$*" >> "$CALLS"; }
fatal() { log "ERROR: $*"; exit 1; }
require_env() { [[ -n ${!1:-} ]] || fatal "missing $1"; }
require_command() { :; }
require_positive_integer() { :; }
resolve_access_token() { printf token; }
write_proxy_kubeconfig() { printf kubeconfig > "$1"; log auth; }
write_bdd_config() { printf config > "$1"; }
install_operator() { log install; }
prepare_e2e() { log prepare-e2e; }
run_e2e() { log e2e; }
collect_allure_results() { log collect; }
generate_allure_report() { log report; }
collect_diagnostics() { log diagnostics; }
'''
    entrypoint = write_entrypoint_fixture(tmp_path, functions)

    result = subprocess.run(
        ["bash", str(entrypoint)],
        text=True,
        capture_output=True,
        env={
            **os.environ,
            "API_URL": "https://acp.example.test",
            "REGION_NAME": "region-one",
            "TOKEN": "secret-token",
            "L5_PLUGINS_VERSION": '{"nexus-ce-operator":"nexus-ce-operator.v4.2.1"}',
            "RESULT_DIR": str(result_dir),
            "CALLS": str(calls),
        },
    )

    assert result.returncode == 0, result.stderr
    assert calls.read_text().splitlines() == [
        "auth", "install", "prepare-e2e", "e2e", "collect", "report", "[DONE]"
    ]
    assert not list(result_dir.glob(".lynx-credentials.*"))


def test_entrypoint_failure_preserves_status_collects_diagnostics_and_cleans_credentials(tmp_path):
    calls = tmp_path / "calls"
    result_dir = tmp_path / "results"
    functions = '''
log() { printf '%s\n' "$*" >> "$CALLS"; }
fatal() { log "ERROR: $*"; exit 1; }
require_env() { [[ -n ${!1:-} ]] || fatal "missing $1"; }
require_command() { :; }
require_positive_integer() { :; }
resolve_access_token() { printf token; }
write_proxy_kubeconfig() { printf kubeconfig > "$1"; }
write_bdd_config() { printf config > "$1"; }
install_operator() { :; }
prepare_e2e() { :; }
run_e2e() { return 37; }
collect_allure_results() { log collect; }
generate_allure_report() { log report; }
collect_diagnostics() { log diagnostics; }
'''
    entrypoint = write_entrypoint_fixture(tmp_path, functions)

    result = subprocess.run(
        ["bash", str(entrypoint)],
        text=True,
        capture_output=True,
        env={
            **os.environ,
            "API_URL": "https://acp.example.test",
            "REGION_NAME": "region-one",
            "TOKEN": "secret-token",
            "L5_PLUGINS_VERSION": '{"nexus-ce-operator":"nexus-ce-operator.v4.2.1"}',
            "RESULT_DIR": str(result_dir),
            "CALLS": str(calls),
        },
    )

    assert result.returncode == 37
    assert calls.read_text().splitlines() == ["collect", "report", "diagnostics"]
    assert not list(result_dir.glob(".lynx-credentials.*"))


def test_entrypoint_setup_failure_collects_reports_and_diagnostics(tmp_path):
    calls = tmp_path / "calls"
    result_dir = tmp_path / "results"
    functions = '''
log() { printf '%s\n' "$*" >> "$CALLS"; }
fatal() { log "ERROR: $*"; exit 1; }
require_env() { [[ -n ${!1:-} ]] || fatal "missing $1"; }
require_command() { :; }
require_positive_integer() { :; }
resolve_access_token() { log auth-failed; return 23; }
write_proxy_kubeconfig() { return 99; }
write_bdd_config() { return 99; }
install_operator() { return 99; }
run_e2e() { return 99; }
collect_allure_results() { log collect; return 1; }
generate_allure_report() { log report; }
collect_diagnostics() { log diagnostics; }
'''
    entrypoint = write_entrypoint_fixture(tmp_path, functions)

    result = subprocess.run(
        ["bash", str(entrypoint)],
        text=True,
        capture_output=True,
        env={
            **os.environ,
            "API_URL": "https://acp.example.test",
            "REGION_NAME": "region-one",
            "TOKEN": "secret-token",
            "L5_PLUGINS_VERSION": '{"nexus-ce-operator":"nexus-ce-operator.v4.2.1"}',
            "RESULT_DIR": str(result_dir),
            "CALLS": str(calls),
        },
    )

    assert result.returncode == 23
    assert calls.read_text().splitlines() == [
        "auth-failed", "collect", "report", "diagnostics"
    ]


def test_entrypoint_requires_target_and_authentication_without_leaking_values(tmp_path):
    result = subprocess.run(
        ["bash", str(ENTRYPOINT)], text=True, capture_output=True,
        env={"PATH": os.environ["PATH"], "RESULT_DIR": str(tmp_path / "results")},
    )

    assert result.returncode != 0
    assert "API_URL" in result.stderr


def test_containerfile_installs_fixed_executable_entrypoint_and_libraries_explicitly():
    text = CONTAINERFILE.read_text()
    entrypoint = ENTRYPOINT.read_text()

    assert re.search(r"COPY\s+testing/lynx-entrypoint\.sh\s+/app/lynx-entrypoint\.sh", text)
    assert re.search(r"COPY\s+testing/lynx\s+/app/lynx", text)
    assert "chmod 755 /app/lynx-entrypoint.sh" in text
    assert "test -x /app/lynx-entrypoint.sh" in text
    assert "ENTRYPOINT [\"/app/lynx-entrypoint.sh\"]" in text
    assert "ln -sfn /opt/allure-${ALLURE_VERSION}/bin/allure /usr/local/bin/allure" in text
    assert "ENV GOPROXY='https://goproxy.cn,direct'" in text
    assert "set -x" not in entrypoint
    assert not re.search(r"run_e2e\s*\|\|\s*true", entrypoint)


def test_hotfix_containerfile_updates_lynx_runtime_and_removes_unit_tests():
    text = HOTFIX_CONTAINERFILE.read_text()

    assert text.startswith("FROM build-harbor.alauda.cn/devops/nexus-ce-test:")
    assert "COPY testing/lynx /app/lynx" in text
    assert "COPY testing/lynx-entrypoint.sh /app/lynx-entrypoint.sh" in text
    assert "COPY testing/nexus-e2e/test_maven_repo.py /app/testing/nexus-e2e/test_maven_repo.py" in text
    assert "rm -rf /app/testing/nexus-e2e/unit" in text
    assert "test ! -e /app/testing/nexus-e2e/unit" in text
    assert 'ENTRYPOINT ["/app/lynx-entrypoint.sh"]' in text
    assert "go test" not in text
    assert "prepare-maven-e2e-bundle" not in text


def test_integration_pipeline_supplies_complete_test_image_build_context():
    text = INTEGRATION_PIPELINE.read_text()
    build_test_image = text.split("- name: buildTestImage", 1)[1].split(
        "- name: test", 1
    )[0]

    assert 'containerfilePath: testing/Containerfile' in build_test_image
    assert 'context: "."' in build_test_image
    assert 'workingDir: "."' in build_test_image


def test_integration_pipeline_supplies_complete_report_upload_object():
    text = INTEGRATION_PIPELINE.read_text()
    report_upload = text.split("- name: reportUpload", 1)[1].split(
        "- name: vmLabels", 1
    )[0]

    for field in (
        "endpoint",
        "bucket",
        "component",
        "dirs",
        "pathTemplate",
        "preCommand",
        "baseURL",
    ):
        assert re.search(rf"^\s*{field}:", report_upload, re.MULTILINE)
