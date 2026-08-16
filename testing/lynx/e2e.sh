#!/usr/bin/env bash

run_e2e() {
  local testing_dir=${LYNX_TESTING_DIR:-/app/testing}
  local config=${LYNX_BDD_CONFIG:-${E2E_CONFIG:-}}
  local tags=${LYNX_E2E_TAGS:-@e2e}
  local run_dir=$testing_dir
  local temporary_run_dir=
  local test_command=nexus.test
  local test_status raw_copy

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
    E2E_CONFIG=$config "$test_command" "--godog.tags=${tags}"
  )
  test_status=$?

  if [[ -n $temporary_run_dir ]]; then
    if [[ -d $run_dir/allure-results ]]; then
      raw_copy=$(mktemp -d) || {
        rm -rf -- "$temporary_run_dir"
        return "$test_status"
      }
      cp -R "$run_dir/allure-results"/. "$raw_copy"/ || true
      LYNX_RAW_ALLURE_DIR=$raw_copy
      export LYNX_RAW_ALLURE_DIR
    fi
    rm -rf -- "$temporary_run_dir"
  else
    LYNX_RAW_ALLURE_DIR=${LYNX_RAW_ALLURE_DIR:-$run_dir/allure-results}
    export LYNX_RAW_ALLURE_DIR
  fi

  return "$test_status"
}

collect_allure_results() {
  local raw_dir=${LYNX_RAW_ALLURE_DIR:-${LYNX_TESTING_DIR:-/app/testing}/allure-results}
  local destination=${RESULT_DIR:?RESULT_DIR is required}/allure-result

  if [[ ! -d $raw_dir ]] || ! find "$raw_dir" -type f -print -quit | grep -q .; then
    log "ERROR: raw Allure results are empty"
    return 1
  fi

  mkdir -p "$destination" || return 1
  cp -R "$raw_dir"/. "$destination"/ || return 1
}

generate_allure_report() {
  local results=${RESULT_DIR:?RESULT_DIR is required}/allure-result
  local report=${RESULT_DIR}/allure-report

  if [[ ! -d $results ]] || ! find "$results" -type f -print -quit | grep -q .; then
    log "Allure report generation skipped because normalized results are empty"
    return 0
  fi

  allure generate "$results" --clean -o "$report" || {
    log "Allure report generation failed; raw results were retained"
    return 0
  }
}
