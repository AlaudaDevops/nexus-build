#!/usr/bin/env bash

_mask_diagnostic_output() {
  sed -E \
    -e 's#(https?://)[^/@[:space:]]+:[^/@[:space:]]+@#\1<redacted>@#g' \
    -e 's/([Tt]oken[[:space:]:=]+)[^[:space:]",]+/\1<redacted>/g' \
    -e 's/([Pp]assword[[:space:]:=]+)[^[:space:]",]+/\1<redacted>/g' \
    -e 's/([Cc]redential(s)?[[:space:]:=]+)[^[:space:]",]+/\1<redacted>/g' \
    -e 's/([Aa]uthorization[[:space:]:=]+)[^[:space:]",]+/\1<redacted>/g'
}

collect_diagnostics() {
  local namespace=${OPERATOR_NAMESPACE:-nexus-ce-operator}
  local result_dir=${RESULT_DIR:?RESULT_DIR is required}
  local request_timeout=${LYNX_DIAGNOSTICS_TIMEOUT:-10}
  local output=$result_dir/diagnostics.log

  require_positive_integer LYNX_DIAGNOSTICS_TIMEOUT "$request_timeout"
  mkdir -p "$result_dir" || return 1
  : >"$output" || return 1

  _diagnostic_query() {
    local title=$1
    shift
    {
      printf '## %s\n' "$title"
      timeout "${request_timeout}s" kubectl --request-timeout="${request_timeout}s" "$@" 2>&1 || true
      printf '\n'
    } | _mask_diagnostic_output >>"$output" || true
  }

  _diagnostic_query "OLM subscriptions" get subscriptions -n "$namespace" \
    -o 'custom-columns=NAME:.metadata.name,CURRENT:.status.currentCSV,INSTALLED:.status.installedCSV,STATE:.status.state'
  _diagnostic_query "OLM install plans" get installplans -n "$namespace" \
    -o 'custom-columns=NAME:.metadata.name,PHASE:.status.phase'
  _diagnostic_query "OLM CSVs" get clusterserviceversions -n "$namespace" \
    -o 'custom-columns=NAME:.metadata.name,PHASE:.status.phase,REASON:.status.reason'
  _diagnostic_query "Deployments" get deployments -n "$namespace" \
    -o 'custom-columns=NAME:.metadata.name,READY:.status.readyReplicas,AVAILABLE:.status.availableReplicas,UNAVAILABLE:.status.unavailableReplicas'
  _diagnostic_query "Pods" get pods -n "$namespace" \
    -o 'custom-columns=NAME:.metadata.name,PHASE:.status.phase,REASON:.status.reason'
  _diagnostic_query "Events" get events -n "$namespace" --sort-by=.lastTimestamp \
    -o 'custom-columns=NAMESPACE:.metadata.namespace,LAST:.lastTimestamp,EVENT:.eventTime,COUNT:.count,TYPE:.type,REASON:.reason,KIND:.involvedObject.kind,OBJECT:.involvedObject.name'

  return 0
}
