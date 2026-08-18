#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=testing/lynx/common.sh
source "$script_dir/lynx/common.sh"
# shellcheck source=testing/lynx/auth.sh
source "$script_dir/lynx/auth.sh"
# shellcheck source=testing/lynx/olm.sh
source "$script_dir/lynx/olm.sh"
# shellcheck source=testing/lynx/e2e.sh
source "$script_dir/lynx/e2e.sh"
# shellcheck source=testing/lynx/diagnostics.sh
source "$script_dir/lynx/diagnostics.sh"

credential_dir=
reports_collected=false

on_exit() {
  local status=$?
  trap - EXIT
  if [[ $reports_collected != true && -n ${RESULT_DIR:-} && -d ${RESULT_DIR:-} ]]; then
    collect_allure_results || :
    generate_allure_report || :
  fi
  if ((status != 0)) && [[ -n ${RESULT_DIR:-} && -d ${RESULT_DIR:-} ]]; then
    collect_diagnostics || log "Failure diagnostics could not be collected"
  fi
  if [[ -n $credential_dir ]]; then
    rm -rf -- "$credential_dir"
  fi
  exit "$status"
}
trap on_exit EXIT

require_env API_URL
require_env REGION_NAME
require_env L5_PLUGINS_VERSION
if [[ -z ${TOKEN:-} && (-z ${USERNAME:-} || -z ${PASSWORD:-}) ]]; then
  fatal "authentication requires TOKEN or both USERNAME and PASSWORD"
fi

RESULT_DIR=${RESULT_DIR:-${TEST_RESULT_DIR:-}}
[[ -n $RESULT_DIR ]] || fatal "RESULT_DIR or TEST_RESULT_DIR is required"
export RESULT_DIR
require_positive_integer LYNX_INSTALL_TIMEOUT "${LYNX_INSTALL_TIMEOUT:-900}"
require_positive_integer LYNX_DIAGNOSTICS_TIMEOUT "${LYNX_DIAGNOSTICS_TIMEOUT:-10}"
for command in jq kubectl timeout allure; do
  require_command "$command"
done

mkdir -p "$RESULT_DIR" || fatal "result directory could not be created"
[[ -d $RESULT_DIR && -w $RESULT_DIR ]] || fatal "result directory is not writable"
credential_dir=$(mktemp -d "$RESULT_DIR/.lynx-credentials.XXXXXX") \
  || fatal "temporary credential directory could not be created"
chmod 0700 "$credential_dir"

access_token=$(resolve_access_token)
LYNX_BDD_CONFIG=$credential_dir/config.yaml
KUBECONFIG=$credential_dir/proxy.kubeconfig
export LYNX_BDD_CONFIG KUBECONFIG
write_proxy_kubeconfig "$KUBECONFIG" "$access_token"
write_bdd_config "$LYNX_BDD_CONFIG" "$access_token"
unset access_token

install_operator
prepare_e2e

set +o errexit
run_e2e
test_status=$?
collect_allure_results
result_status=$?
set -o errexit
generate_allure_report
reports_collected=true

if ((test_status != 0)); then
  exit "$test_status"
fi
if ((result_status != 0)); then
  exit "$result_status"
fi
log "[DONE]"
