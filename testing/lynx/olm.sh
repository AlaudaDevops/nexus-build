#!/usr/bin/env bash

_olm_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "${_olm_dir}/common.sh"
unset _olm_dir

OPERATOR_PACKAGE=${OPERATOR_PACKAGE:-nexus-ce-operator}
OPERATOR_NAMESPACE=${OPERATOR_NAMESPACE:-nexus-ce-operator}
OPERATOR_CHANNEL=${OPERATOR_CHANNEL:-stable}
INSTALL_TIMEOUT=${INSTALL_TIMEOUT:-${LYNX_INSTALL_TIMEOUT:-900}}
export OPERATOR_PACKAGE OPERATOR_NAMESPACE OPERATOR_CHANNEL INSTALL_TIMEOUT

_olm_timeout() {
  require_positive_integer INSTALL_TIMEOUT "$INSTALL_TIMEOUT"
  printf '%d\n' "$((10#$INSTALL_TIMEOUT))"
}

_olm_wait_value() {
  local description=$1 expected=$2 timeout_seconds=$3
  shift 3
  local started=$SECONDS current remaining sleep_for
  local poll_interval=${LYNX_POLL_INTERVAL:-5}
  local heartbeat_interval=${LYNX_WAIT_HEARTBEAT:-30}
  local next_heartbeat=$SECONDS
  require_positive_integer LYNX_POLL_INTERVAL "$poll_interval"
  require_positive_integer LYNX_WAIT_HEARTBEAT "$heartbeat_interval"
  require_positive_integer timeout "$timeout_seconds"
  require_command timeout
  poll_interval=$((10#$poll_interval))
  heartbeat_interval=$((10#$heartbeat_interval))
  timeout_seconds=$((10#$timeout_seconds))
  while :; do
    remaining=$((timeout_seconds - (SECONDS - started)))
    ((remaining > 0)) || { log "Timed out after ${timeout_seconds}s waiting for ${description}"; return 1; }
    current=$(_olm_timed_probe "$remaining" "$@") || current=
    [[ $current == "$expected" ]] && return 0
    remaining=$((timeout_seconds - (SECONDS - started)))
    ((remaining > 0)) || { log "Timed out after ${timeout_seconds}s waiting for ${description}"; return 1; }
    if ((SECONDS >= next_heartbeat)); then
      log "Waiting for ${description} (${SECONDS-started}s elapsed)"
      next_heartbeat=$((SECONDS + heartbeat_interval))
    fi
    sleep_for=$poll_interval
    ((sleep_for > remaining)) && sleep_for=$remaining
    sleep "$sleep_for"
  done
}

_olm_timed_probe() {
  local remaining=$1 probe=$2
  shift 2
  export -f "$probe"
  timeout "${remaining}s" bash -c '"$@"' bash "$probe" "$@"
}

resolve_operator_catalog() {
  local expected manifests resolved
  expected=$(listed_operator_version) || return 1
  manifests=$(kubectl get packagemanifests -A -o json) || {
    log "ERROR: failed to list OLM PackageManifests"
    return 1
  }
  resolved=$(printf '%s' "$manifests" | jq -er \
    --arg package "$OPERATOR_PACKAGE" --arg channel "$OPERATOR_CHANNEL" '
      [.items[] | select(.metadata.name == $package)] as $matches
      | if ($matches | length) != 1 then error("package must resolve exactly once") else $matches[0] end
      | . as $manifest
      | [.status.channels[]? | select(.name == $channel)] as $channels
      | if ($channels | length) != 1 then error("channel must resolve exactly once") else $channels[0] end
      | [$channels[0].currentCSV, $manifest.status.catalogSource,
         $manifest.status.catalogSourceNamespace]
      | if any(.[]; type != "string" or length == 0) then error("incomplete catalog data") else @tsv end
    ' 2>/dev/null) || {
      log "ERROR: package ${OPERATOR_PACKAGE} channel ${OPERATOR_CHANNEL} could not be resolved uniquely"
      return 1
    }
  IFS=$'\t' read -r OPERATOR_CSV CATALOG_SOURCE CATALOG_NAMESPACE <<<"$resolved"
  if [[ $OPERATOR_CSV != "$expected" ]]; then
    log "ERROR: selected channel CSV does not match the listed operator version"
    return 1
  fi
  export OPERATOR_CSV CATALOG_SOURCE CATALOG_NAMESPACE
}

_catalog_ready() {
  kubectl get catalogsource "$CATALOG_SOURCE" -n "$CATALOG_NAMESPACE" -o json 2>/dev/null |
    jq -r '.status.connectionState.lastObservedState // ""'
}

ensure_operator_group() {
  local groups count valid
  groups=$(kubectl get operatorgroups -n "$OPERATOR_NAMESPACE" -o json) || return 1
  count=$(printf '%s' "$groups" | jq '.items | length') || return 1
  case $count in
    0)
      kubectl apply -f - <<EOF
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: ${OPERATOR_PACKAGE}
  namespace: ${OPERATOR_NAMESPACE}
spec: {}
EOF
      ;;
    1)
      valid=$(printf '%s' "$groups" | jq -r '
        .items[0].spec.targetNamespaces as $targets
        | ($targets == null or ($targets | length) == 0)') || return 1
      [[ $valid == true ]] || {
        log "ERROR: existing OperatorGroup is not configured for AllNamespaces"
        return 1
      }
      ;;
    *)
      log "ERROR: multiple OperatorGroups exist in ${OPERATOR_NAMESPACE}"
      return 1
      ;;
  esac
}

ensure_subscription() {
  local existing compatible
  if existing=$(kubectl get subscription "$OPERATOR_PACKAGE" -n "$OPERATOR_NAMESPACE" -o json 2>/dev/null); then
    compatible=$(printf '%s' "$existing" | jq -r \
      --arg package "$OPERATOR_PACKAGE" --arg source "$CATALOG_SOURCE" \
      --arg source_ns "$CATALOG_NAMESPACE" --arg channel "$OPERATOR_CHANNEL" \
      --arg csv "$OPERATOR_CSV" '
        .spec.name == $package and .spec.source == $source
        and .spec.sourceNamespace == $source_ns and .spec.channel == $channel
        and .spec.startingCSV == $csv and .spec.installPlanApproval == "Manual"') || return 1
    [[ $compatible == true ]] || {
      log "ERROR: existing Subscription is incompatible with the requested operator"
      return 1
    }
  fi

  kubectl apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ${OPERATOR_PACKAGE}
  namespace: ${OPERATOR_NAMESPACE}
spec:
  channel: ${OPERATOR_CHANNEL}
  installPlanApproval: Manual
  name: ${OPERATOR_PACKAGE}
  source: ${CATALOG_SOURCE}
  sourceNamespace: ${CATALOG_NAMESPACE}
  startingCSV: ${OPERATOR_CSV}
EOF
}

_subscription_state() {
  local subscription terminal ref
  subscription=$(kubectl get subscription "$OPERATOR_PACKAGE" -n "$OPERATOR_NAMESPACE" -o json 2>/dev/null) || {
    printf 'waiting\n'
    return
  }
  terminal=$(printf '%s' "$subscription" | jq -r '
    [.status.conditions[]?
      | select(.status == "True" and (.type == "ResolutionFailed" or .type == "CatalogSourcesUnhealthy"))
      | .type] | first // ""') || return 1
  if [[ -n $terminal ]]; then
    printf 'terminal:%s\n' "$terminal"
    return
  fi
  ref=$(printf '%s' "$subscription" | jq -r '.status.installPlanRef.name // ""') || return 1
  if [[ -n $ref ]]; then printf 'ready:%s\n' "$ref"; else printf 'waiting\n'; fi
}

wait_for_install_plan() {
  local timeout_seconds started state install_plan phase remaining sleep_for
  local poll_interval=${LYNX_POLL_INTERVAL:-5}
  local heartbeat_interval=${LYNX_WAIT_HEARTBEAT:-30}
  local next_heartbeat=$SECONDS
  timeout_seconds=$(_olm_timeout) || return 1
  require_positive_integer LYNX_POLL_INTERVAL "$poll_interval"
  require_positive_integer LYNX_WAIT_HEARTBEAT "$heartbeat_interval"
  require_command timeout
  poll_interval=$((10#$poll_interval))
  heartbeat_interval=$((10#$heartbeat_interval))
  started=$SECONDS
  while :; do
    remaining=$((timeout_seconds - (SECONDS - started)))
    ((remaining > 0)) || { log "Timed out after ${timeout_seconds}s waiting for InstallPlan reference"; return 1; }
    state=$(_olm_timed_probe "$remaining" _subscription_state) || state=waiting
    case $state in
      terminal:*) log "ERROR: Subscription reported ${state#terminal:}"; return 1 ;;
      ready:*) install_plan=${state#ready:}; break ;;
    esac
    remaining=$((timeout_seconds - (SECONDS - started)))
    ((remaining > 0)) || { log "Timed out after ${timeout_seconds}s waiting for InstallPlan reference"; return 1; }
    if ((SECONDS >= next_heartbeat)); then
      log "Waiting for InstallPlan reference (${SECONDS-started}s elapsed)"
      next_heartbeat=$((SECONDS + heartbeat_interval))
    fi
    sleep_for=$poll_interval
    ((sleep_for > remaining)) && sleep_for=$remaining
    sleep "$sleep_for"
  done
  kubectl patch installplan "$install_plan" -n "$OPERATOR_NAMESPACE" \
    --type merge -p '{"spec":{"approved":true}}' >/dev/null || return 1
  while :; do
    remaining=$((timeout_seconds - (SECONDS - started)))
    ((remaining > 0)) || { log "Timed out after ${timeout_seconds}s waiting for InstallPlan completion"; return 1; }
    state=$(_olm_timed_probe "$remaining" _subscription_state) || state=waiting
    case $state in terminal:*) log "ERROR: Subscription reported ${state#terminal:}"; return 1 ;; esac
    phase=$(timeout "${remaining}s" kubectl get installplan "$install_plan" -n "$OPERATOR_NAMESPACE" -o json 2>/dev/null |
      jq -r '.status.phase // ""')
    [[ $phase == Complete ]] && return 0
    [[ $phase == Failed ]] && { log "ERROR: InstallPlan failed"; return 1; }
    remaining=$((timeout_seconds - (SECONDS - started)))
    ((remaining > 0)) || { log "Timed out after ${timeout_seconds}s waiting for InstallPlan completion"; return 1; }
    if ((SECONDS >= next_heartbeat)); then
      log "Waiting for InstallPlan completion (${SECONDS-started}s elapsed)"
      next_heartbeat=$((SECONDS + heartbeat_interval))
    fi
    sleep_for=$poll_interval
    ((sleep_for > remaining)) && sleep_for=$remaining
    sleep "$sleep_for"
  done
}

_csv_phase() {
  kubectl get clusterserviceversion "$OPERATOR_CSV" -n "$OPERATOR_NAMESPACE" -o json 2>/dev/null |
    jq -r '.status.phase // ""'
}

wait_for_csv() {
  local timeout_seconds
  timeout_seconds=$(_olm_timeout) || return 1
  _olm_wait_value "CSV ${OPERATOR_CSV} to succeed" Succeeded "$timeout_seconds" _csv_phase
}

wait_for_deployment() {
  local csv deployments deployment timeout_seconds
  csv=$(kubectl get clusterserviceversion "$OPERATOR_CSV" -n "$OPERATOR_NAMESPACE" -o json) || return 1
  deployments=$(printf '%s' "$csv" | jq -r '.spec.install.spec.deployments // [] | length') || return 1
  [[ $deployments == 1 ]] || {
    log "ERROR: expected the CSV to own exactly one Deployment"
    return 1
  }
  deployment=$(printf '%s' "$csv" | jq -r '.spec.install.spec.deployments[0].name') || return 1
  export deployment
  _deployment_available() {
    kubectl get deployment "$deployment" -n "$OPERATOR_NAMESPACE" -o json 2>/dev/null |
      jq -r 'any(.status.conditions[]?; .type == "Available" and .status == "True")'
  }
  timeout_seconds=$(_olm_timeout) || return 1
  _olm_wait_value "Deployment ${deployment} to become Available" true "$timeout_seconds" _deployment_available
}

_nexus_crd_ready() {
  local crd conditions served discovered
  crd=$(kubectl get crd nexuses.operator.alaudadevops.io -o json 2>/dev/null) || { printf 'false\n'; return; }
  conditions=$(printf '%s' "$crd" | jq -r '
    any(.status.conditions[]?; .type == "Established" and .status == "True")
    and any(.status.conditions[]?; .type == "NamesAccepted" and .status == "True")') || return 1
  served=$(printf '%s' "$crd" | jq -r 'any(.spec.versions[]?; .name == "v1alpha1" and .served == true)') || return 1
  discovered=$(kubectl api-resources --api-group=operator.alaudadevops.io -o name 2>/dev/null |
    awk '$0 == "nexuses.operator.alaudadevops.io" { found=1 } END { print found ? "true" : "false" }')
  [[ $conditions == true && $served == true && $discovered == true ]] && printf 'true\n' || printf 'false\n'
}

wait_for_nexus_crd() {
  local timeout_seconds
  timeout_seconds=$(_olm_timeout) || return 1
  _olm_wait_value "Nexus v1alpha1 CRD discovery" true "$timeout_seconds" _nexus_crd_ready
}

install_operator() {
  local timeout_seconds
  require_command kubectl
  require_command jq
  timeout_seconds=$(_olm_timeout) || return 1
  kubectl create namespace "$OPERATOR_NAMESPACE" --dry-run=client -o yaml |
    kubectl apply -f - >/dev/null || return 1
  resolve_operator_catalog || return 1
  _olm_wait_value "CatalogSource ${CATALOG_SOURCE} readiness" READY "$timeout_seconds" _catalog_ready || return 1
  ensure_operator_group || return 1
  ensure_subscription || return 1
  if [[ $(_csv_phase) != Succeeded ]]; then
    wait_for_install_plan || return 1
    wait_for_csv || return 1
  fi
  wait_for_deployment || return 1
  wait_for_nexus_crd
}
