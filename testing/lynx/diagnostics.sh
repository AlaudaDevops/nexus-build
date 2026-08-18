#!/usr/bin/env bash

_mask_diagnostic_output() {
  awk '
    {
      lower = tolower($0)
      if (lower ~ /(token|password|credential|authorization)/) next
      if ((index(lower, "http://") || index(lower, "https://")) && lower ~ /:[^@[:space:]]+@/) next
      print
    }
  '
}

collect_diagnostics() {
  local namespace=${OPERATOR_NAMESPACE:-nexus-ce-operator}
  local result_dir=${RESULT_DIR:?RESULT_DIR is required}
  local request_timeout=${LYNX_DIAGNOSTICS_TIMEOUT:-10}
  local output=$result_dir/diagnostics.log
  local stage
  local collection_status=0

  require_positive_integer LYNX_DIAGNOSTICS_TIMEOUT "$request_timeout"
  mkdir -p "$result_dir" || return 1
  [[ ! -L $output ]] || {
    log "ERROR: diagnostics destination must not be a symbolic link"
    return 1
  }
  stage=$(mktemp "$result_dir/.diagnostics.tmp.XXXXXX") || return 1

  _diagnostic_query() {
    local title=$1
    shift
    {
      printf '## %s\n' "$title"
      timeout "${request_timeout}s" kubectl --request-timeout="${request_timeout}s" "$@" 2>/dev/null || true
      printf '\n'
    } | _mask_diagnostic_output >>"$stage"
  }

  _diagnostic_query "OLM subscriptions" get subscriptions -n "$namespace" \
    -o 'custom-columns=NAME:.metadata.name,CURRENT:.status.currentCSV,INSTALLED:.status.installedCSV,STATE:.status.state' || collection_status=1
  _diagnostic_query "OLM install plans" get installplans -n "$namespace" \
    -o 'custom-columns=NAME:.metadata.name,PHASE:.status.phase' || collection_status=1
  _diagnostic_query "OLM CSVs" get clusterserviceversions -n "$namespace" \
    -o 'custom-columns=NAME:.metadata.name,PHASE:.status.phase,REASON:.status.reason' || collection_status=1
  _diagnostic_query "Deployments" get deployments -n "$namespace" \
    -o 'custom-columns=NAME:.metadata.name,READY:.status.readyReplicas,AVAILABLE:.status.availableReplicas,UNAVAILABLE:.status.unavailableReplicas' || collection_status=1
  _diagnostic_query "Pods" get pods -n "$namespace" \
    -o 'custom-columns=NAME:.metadata.name,PHASE:.status.phase,REASON:.status.reason' || collection_status=1
  _diagnostic_query "Events" get events -n "$namespace" --sort-by=.lastTimestamp \
    -o 'custom-columns=NAMESPACE:.metadata.namespace,LAST:.lastTimestamp,EVENT:.eventTime,COUNT:.count,TYPE:.type,REASON:.reason,KIND:.involvedObject.kind,OBJECT:.involvedObject.name' || collection_status=1

  if ((collection_status != 0)); then
    rm -f -- "$stage"
    return 1
  fi

  if ! mv -- "$stage" "$output"; then
    rm -f -- "$stage"
    return 1
  fi
}
