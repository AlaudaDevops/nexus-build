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
    if [[ -f "$STATE" ]]; then printf '%s\n' '{"spec":{"name":"nexus-ce-operator","source":"catalog","sourceNamespace":"olm","channel":"stable","startingCSV":"nexus-ce-operator.v4.2.1","installPlanApproval":"Manual"},"status":{"installPlanRef":{"name":"ip-one"}}}'; else exit 1; fi ;;
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
        '_hung_olm_probe() { sleep 10; printf ready; }; _olm_wait_value "hung OLM probe" ready 1 _hung_olm_probe',
        env={"LYNX_POLL_INTERVAL": "1", "LYNX_WAIT_HEARTBEAT": "1"},
        timeout=3,
    )

    assert result.returncode != 0
    assert time.monotonic() - started_at < 3
    assert "waiting" in result.stderr.lower()
    assert "timed out" in result.stderr.lower()


def test_wait_for_install_plan_bounds_hung_kubectl_and_emits_heartbeat(tmp_path):
    write_fake_kubectl(tmp_path, "sleep 10\n")
    started_at = time.monotonic()
    result = run_olm_bash(
        "wait_for_install_plan",
        env=olm_env(tmp_path, LYNX_INSTALL_TIMEOUT="1"),
        timeout=3,
    )

    assert result.returncode != 0
    assert time.monotonic() - started_at < 3
    assert "waiting" in result.stderr.lower()
    assert "timed out" in result.stderr.lower()


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


@pytest.mark.parametrize(
    ("tls_env", "expected_tls_option"),
    [
        ({}, None),
        ({"LYNX_TLS_INSECURE": "false"}, None),
        ({"LYNX_CA_BUNDLE": "/trusted/acp-ca.pem"}, "--cacert /trusted/acp-ca.pem"),
        ({"LYNX_TLS_INSECURE": "true"}, "--insecure"),
    ],
)
def test_password_login_uses_secure_bounded_acp_dex_flow_without_leaking_credentials(
    tmp_path, tls_env, expected_tls_option
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
            **tls_env,
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
    assert "--data-urlencode client_id=console+ui" in curl_calls
    assert "--data-urlencode state=opaque&state" in curl_calls
    assert "ignored-fragment" not in curl_calls
    assert "--url-query req=request&#+=%value" in curl_calls
    assert "--data-urlencode code=a&b#c+d=e%f" in curl_calls
    assert "--data-urlencode state=s&t#u+v=w%x" in curl_calls
    if expected_tls_option:
        assert expected_tls_option in curl_calls
    else:
        assert "--insecure" not in curl_calls
        assert "--cacert" not in curl_calls


@pytest.mark.parametrize("value", ["1", "yes", "TRUE", ""])
def test_password_login_rejects_invalid_tls_insecure_values_without_curl(tmp_path, value):
    fake_curl = tmp_path / "curl"
    fake_curl.write_text("#!/usr/bin/env bash\nprintf called >&2\nexit 99\n")
    fake_curl.chmod(0o755)

    result = run_auth_bash(
        "resolve_access_token",
        env={
            "PATH": f"{tmp_path}:{os.environ['PATH']}",
            "API_URL": "https://acp.example.test",
            "USERNAME": "user",
            "PASSWORD": "secret",
            "LYNX_TLS_INSECURE": value,
        },
    )

    assert result.returncode != 0
    assert "LYNX_TLS_INSECURE" in result.stderr
    assert "called" not in result.stderr


def test_write_proxy_kubeconfig_uses_region_proxy_and_mode_0600(tmp_path):
    kubeconfig = tmp_path / "proxy.kubeconfig"
    token = "kubeconfig-secret-token"
    result = run_auth_bash(
        f'write_proxy_kubeconfig "{kubeconfig}" "$TOKEN"',
        env={
            "API_URL": "https://acp.example.test/",
            "REGION_NAME": "region-one",
            "TOKEN": token,
        },
    )

    assert result.returncode == 0, result.stderr
    config = json.loads(kubeconfig.read_text())
    assert config["clusters"][0]["cluster"]["server"] == (
        "https://acp.example.test/kubernetes/region-one"
    )
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
            "TOKEN": token,
        },
    )

    assert result.returncode == 0, result.stderr
    config = json.loads(config_path.read_text())
    assert config == {
        "acp": {
            "baseUrl": "https://acp.example.test",
            "token": token,
            "cluster": "region-one",
        }
    }
    assert config_path.stat().st_mode & 0o777 == 0o600
    assert token not in result.stdout + result.stderr


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
