#!/usr/bin/env bash

log() {
  printf '[%s] %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*" >&2
}

fatal() {
  log "ERROR: $*"
  exit 1
}

require_env() {
  local name=$1

  [[ -n ${!name:-} ]] || fatal "required environment variable ${name} is not set"
}

require_command() {
  local name=$1

  command -v -- "$name" >/dev/null 2>&1 || fatal "required command ${name} was not found"
}

require_positive_integer() {
  local name=$1
  local value=$2

  if [[ ! $value =~ ^[0-9]+$ || ! $value =~ [1-9] ]]; then
    fatal "${name} must be a positive integer"
  fi
}

listed_operator_version() {
  local version

  if ! version=$(printf '%s' "${L5_PLUGINS_VERSION:-}" |
    jq -er '
      if type == "object"
         and (.["nexus-ce-operator"] | type) == "string"
         and (.["nexus-ce-operator"] | length) > 0
      then .["nexus-ce-operator"]
      else error("missing operator version")
      end
    ' 2>/dev/null); then
    log "ERROR: nexus-ce-operator version is missing from L5_PLUGINS_VERSION"
    return 1
  fi

  printf '%s\n' "$version"
}

wait_for_value() {
  local description=$1
  local expected=$2
  local timeout_seconds=$3
  shift 3

  local poll_interval=${LYNX_POLL_INTERVAL-5}
  local heartbeat_interval=${LYNX_WAIT_HEARTBEAT-30}
  require_positive_integer LYNX_POLL_INTERVAL "$poll_interval"
  require_positive_integer LYNX_WAIT_HEARTBEAT "$heartbeat_interval"
  require_positive_integer timeout "$timeout_seconds"
  poll_interval=$((10#$poll_interval))
  heartbeat_interval=$((10#$heartbeat_interval))
  timeout_seconds=$((10#$timeout_seconds))
  require_command timeout

  local started_at=$SECONDS
  local now next_heartbeat current remaining sleep_for
  next_heartbeat=$started_at

  while :; do
    now=$SECONDS
    remaining=$((timeout_seconds - (now - started_at)))
    if ((remaining <= 0)); then
      log "Timed out after ${timeout_seconds}s waiting for ${description}"
      return 1
    fi

    current=$(timeout "${remaining}s" "$@" 2>/dev/null) || current=
    if [[ $current == "$expected" ]]; then
      return 0
    fi

    now=$SECONDS
    remaining=$((timeout_seconds - (now - started_at)))
    if ((remaining <= 0)); then
      log "Timed out after ${timeout_seconds}s waiting for ${description}"
      return 1
    fi

    if ((now >= next_heartbeat)); then
      log "Waiting for ${description} (${now-started_at}s elapsed)"
      next_heartbeat=$((now + heartbeat_interval))
    fi
    sleep_for=$poll_interval
    if ((sleep_for > remaining)); then
      sleep_for=$remaining
    fi
    sleep "$sleep_for"
  done
}
