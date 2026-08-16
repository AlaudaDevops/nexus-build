import json
import os
import re
import subprocess
from pathlib import Path

import pytest


COMMON = Path(__file__).parents[2] / "lynx" / "common.sh"
TIMESTAMP = r"\[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\]"


def run_bash(script, *, env=None):
    command_env = os.environ.copy()
    command_env["LC_ALL"] = "C"
    if env:
        command_env.update(env)
    return subprocess.run(
        ["bash", "-c", f'source "$1"\n{script}', "bash", str(COMMON)],
        text=True,
        capture_output=True,
        env=command_env,
    )


def test_log_and_fatal_write_timestamped_messages_to_stderr():
    result = run_bash('log "starting"; (fatal "stopped")')

    assert result.returncode != 0
    assert re.fullmatch(f"{TIMESTAMP} starting\n{TIMESTAMP} ERROR: stopped\n", result.stderr)
    assert result.stdout == ""


def test_require_env_rejects_unset_and_empty_values_without_disclosing_values():
    secret = "should-never-be-printed"
    result = run_bash(
        'require_env LYNX_TEST_SECRET',
        env={"LYNX_TEST_SECRET": ""},
    )

    assert result.returncode != 0
    assert "LYNX_TEST_SECRET" in result.stderr
    assert secret not in result.stderr


def test_require_env_accepts_a_nonempty_value_without_printing_it():
    secret = "should-never-be-printed"
    result = run_bash(
        'require_env LYNX_TEST_SECRET',
        env={"LYNX_TEST_SECRET": secret},
    )

    assert result.returncode == 0
    assert secret not in result.stdout + result.stderr


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


@pytest.mark.parametrize("value", ["1", "42", "0007"])
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
    result = run_bash(
        f'''probe() {{
          count=$(wc -l < "{attempts}" 2>/dev/null || printf 0)
          printf 'x\\n' >> "{attempts}"
          if (( count >= 1 )); then printf 'ready\\n'; else printf 'not-ready\\n'; fi
        }}
        wait_for_value "operator readiness" ready 2 probe''',
        env={"LYNX_POLL_INTERVAL": "0.01", "LYNX_WAIT_HEARTBEAT": "1"},
    )

    assert result.returncode == 0, result.stderr
    assert len(attempts.read_text().splitlines()) >= 2
    assert "not-ready" not in result.stdout + result.stderr


def test_wait_for_value_is_bounded_and_heartbeats_without_command_output():
    secret_output = "sensitive-current-value"
    result = run_bash(
        f'''probe() {{ printf '%s\\n' {json.dumps(secret_output)}; }}
        wait_for_value "operator readiness" ready 1 probe''',
        env={"LYNX_POLL_INTERVAL": "0.05", "LYNX_WAIT_HEARTBEAT": "1"},
    )

    assert result.returncode == 1
    assert "operator readiness" in result.stderr
    assert "waiting" in result.stderr.lower()
    assert "timed out" in result.stderr.lower()
    assert secret_output not in result.stdout + result.stderr
