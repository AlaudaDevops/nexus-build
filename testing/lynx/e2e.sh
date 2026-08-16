#!/usr/bin/env bash

prepare_e2e() {
  local namespace=${BDD_LOCK_NAMESPACE:-bdd-testing}
  local timeout_seconds=${LYNX_INSTALL_TIMEOUT:-900}
  local namespace_yaml

  require_positive_integer LYNX_INSTALL_TIMEOUT "$timeout_seconds"
  require_command kubectl
  require_command timeout
  namespace_yaml=$(timeout "${timeout_seconds}s" kubectl create namespace "$namespace" \
    --dry-run=client -o yaml) || return 1
  printf '%s\n' "$namespace_yaml" \
    | timeout "${timeout_seconds}s" kubectl apply -f - >/dev/null
}

run_e2e() {
  local testing_dir=${LYNX_TESTING_DIR:-/app/testing}
  local config=${LYNX_BDD_CONFIG:-${E2E_CONFIG:-}}
  local tags=${LYNX_E2E_TAGS:-@e2e}
  local run_dir=$testing_dir
  local temporary_run_dir=
  local test_command=nexus.test
  local test_status raw_copy copy_status=0 result_dir

  [[ -n $config ]] || {
    log "ERROR: E2E configuration path is not set"
    return 1
  }
  [[ -f $config ]] || {
    log "ERROR: E2E configuration file does not exist"
    return 1
  }

  if [[ ! -w $testing_dir ]]; then
    temporary_run_dir=$(mktemp -d) || return 1
    cp -R "$testing_dir"/. "$temporary_run_dir"/ || {
      rm -rf -- "$temporary_run_dir"
      return 1
    }
    run_dir=$temporary_run_dir
  fi

  if [[ -x $run_dir/nexus.test ]]; then
    test_command=./nexus.test
  fi
  (
    cd "$run_dir" || exit 1
    E2E_CONFIG=$config "$test_command" \
      --godog.concurrency=2 \
      --godog.format=allure \
      "--godog.tags=${tags}"
  )
  test_status=$?

  if [[ -n $temporary_run_dir ]]; then
    if [[ -d $run_dir/allure-results ]]; then
      result_dir=${RESULT_DIR:-${TEST_RESULT_DIR:-}}
      if [[ -z $result_dir ]] || ! mkdir -p "$result_dir"; then
        copy_status=1
      elif raw_copy=$(mktemp -d "$result_dir/.lynx-raw-allure.XXXXXX"); then
        if cp -R "$run_dir/allure-results"/. "$raw_copy"/; then
          LYNX_RAW_ALLURE_DIR=$raw_copy
          LYNX_RAW_ALLURE_TEMP=true
          export LYNX_RAW_ALLURE_DIR LYNX_RAW_ALLURE_TEMP
        else
          rm -rf -- "$raw_copy"
          copy_status=1
        fi
      else
        copy_status=1
      fi
    fi
    rm -rf -- "$temporary_run_dir"
  else
    LYNX_RAW_ALLURE_DIR=${LYNX_RAW_ALLURE_DIR:-$run_dir/allure-results}
    export LYNX_RAW_ALLURE_DIR
  fi

  ((test_status != 0)) && return "$test_status"
  return "$copy_status"
}

collect_allure_results() {
  local raw_dir=${LYNX_RAW_ALLURE_DIR:-${LYNX_TESTING_DIR:-/app/testing}/allure-results}
  local result_dir=${RESULT_DIR:?RESULT_DIR is required}
  local destination=$result_dir/allure-result
  local stage backup status=0 cleanup_raw=false

  [[ ${LYNX_RAW_ALLURE_TEMP:-false} == true && $raw_dir == "$result_dir"/.lynx-raw-allure.* ]] && cleanup_raw=true

  if [[ ! -d $raw_dir ]] || ! find "$raw_dir" -type f -print -quit | grep -q .; then
    log "ERROR: raw Allure results are empty"
    status=1
  elif ! mkdir -p "$result_dir"; then
    status=1
  elif [[ -L $destination ]]; then
    log "ERROR: Allure result destination must not be a symbolic link"
    status=1
  elif ! stage=$(mktemp -d "$result_dir/.allure-result.tmp.XXXXXX"); then
    status=1
  elif ! cp -R "$raw_dir"/. "$stage"/; then
    rm -rf -- "$stage"
    status=1
  else
    backup=$result_dir/.allure-result.old.$$
    if [[ -e $destination ]]; then
      if [[ -e $backup ]] || ! mv -- "$destination" "$backup"; then
        rm -rf -- "$stage"
        status=1
      fi
    fi
    if ((status == 0)) && ! mv -- "$stage" "$destination"; then
      [[ -e $backup ]] && mv -- "$backup" "$destination" || true
      rm -rf -- "$stage"
      status=1
    fi
    [[ -e $backup ]] && rm -rf -- "$backup"
  fi

  if [[ $cleanup_raw == true ]]; then
    rm -rf -- "$raw_dir"
    unset LYNX_RAW_ALLURE_DIR LYNX_RAW_ALLURE_TEMP
  fi
  return "$status"
}

generate_allure_report() {
  local results=${RESULT_DIR:?RESULT_DIR is required}/allure-result
  local report=${RESULT_DIR}/allure-report

  if [[ ! -d $results ]] || ! find "$results" -type f -print -quit | grep -q .; then
    log "Allure report generation skipped because normalized results are empty"
    return 0
  fi
  if [[ -L $report ]]; then
    log "ERROR: Allure report destination must not be a symbolic link"
    return 1
  fi

  allure generate "$results" --clean -o "$report" || {
    log "Allure report generation failed; raw results were retained"
    return 0
  }
}
