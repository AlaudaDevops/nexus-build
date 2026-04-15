#!/bin/bash
set -euo pipefail

# Local smoke test for Nexus Repository Manager image.
#
# Usage:
#   ./hack/local-smoke-test.sh start [--image IMG:TAG]  # start container only
#   ./hack/local-smoke-test.sh test                      # run tests against running container
#   ./hack/local-smoke-test.sh stop                      # stop & remove container
#   ./hack/local-smoke-test.sh run [--image IMG:TAG]     # start + test + stop (legacy mode)
#   ./hack/local-smoke-test.sh run --keep [--image ...]  # start + test, keep container

IMAGE="nexus-local:3.76.0-03"
CONTAINER_NAME="nexus-smoke-test"
PORT=8081
TIMEOUT=300
KEEP=false
CURL="command curl"

usage() {
  cat <<EOF
Usage: $0 <command> [options]

Commands:
  start [--image IMG:TAG]       Start Nexus container (default image: $IMAGE)
  test                          Run smoke tests against running container
  stop                          Stop and remove container
  run [--image IMG:TAG] [--keep] Start, test, and optionally stop

Options:
  --image IMG:TAG  Container image (default: $IMAGE)
  --keep           Keep container after 'run' (no effect with 'start')
EOF
  exit 1
}

CMD="${1:-}"
[ -z "$CMD" ] && usage
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --image) IMAGE="$2"; shift 2 ;;
    --keep) KEEP=true; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

# =============================================
# Functions
# =============================================

do_start() {
  echo "==> Starting Nexus container ($IMAGE)..."
  docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
  docker run -d --name "$CONTAINER_NAME" \
    -p "$PORT:8081" \
    -e INSTALL4J_ADD_VM_PARAMS="-Xms1200m -Xmx1200m -XX:MaxDirectMemorySize=1200m -Djava.util.prefs.userRoot=/nexus-data/javaprefs" \
    "$IMAGE"

  echo "==> Waiting for Nexus to become ready (timeout: ${TIMEOUT}s)..."
  ELAPSED=0
  INTERVAL=5
  while [ $ELAPSED -lt $TIMEOUT ]; do
    CONTAINER_STATUS=$(docker inspect -f '{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null || echo "missing")
    if [ "$CONTAINER_STATUS" != "running" ]; then
      echo "==> ERROR: Container exited unexpectedly (status: $CONTAINER_STATUS)"
      echo "==> Container logs:"
      command docker logs "$CONTAINER_NAME" 2>&1
      exit 1
    fi
    if command docker logs "$CONTAINER_NAME" 2>&1 | grep -q "Unable to resolve.*missing requirement"; then
      echo "==> ERROR: OSGi bundle resolution failure — incompatible JAR replacement"
      echo "==> Relevant errors:"
      command docker logs "$CONTAINER_NAME" 2>&1 | grep "Unable to resolve" | head -5
      exit 1
    fi
    if $CURL -sf "http://localhost:${PORT}/service/rest/v1/status" > /dev/null 2>&1; then
      echo "==> Nexus is ready after ${ELAPSED}s"
      return 0
    fi
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
  done

  echo "==> TIMEOUT: Nexus did not become ready in ${TIMEOUT}s"
  echo "==> Last 50 lines of container logs:"
  command docker logs "$CONTAINER_NAME" --tail 50
  exit 1
}

do_stop() {
  echo "==> Stopping container $CONTAINER_NAME..."
  docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
  echo "==> Done."
}

do_test() {
  # Verify container is running
  CONTAINER_STATUS=$(docker inspect -f '{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null || echo "missing")
  if [ "$CONTAINER_STATUS" != "running" ]; then
    echo "==> ERROR: Container '$CONTAINER_NAME' is not running (status: $CONTAINER_STATUS)"
    echo "==> Run '$0 start' first."
    exit 1
  fi

  # Get admin password
  ADMIN_PASSWORD=$(docker exec "$CONTAINER_NAME" cat /nexus-data/admin.password 2>/dev/null || echo "")
  if [ -z "$ADMIN_PASSWORD" ]; then
    echo "==> Warning: Could not read initial admin password (may already be changed)"
    ADMIN_PASSWORD="admin123"
  fi
  echo "==> Admin password: ${ADMIN_PASSWORD:0:4}****"

  BASE_URL="http://localhost:${PORT}"
  FAILURES=0
  TESTS=0

  pass() { echo "  [PASS] $1"; }
  fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }

  echo ""
  echo "=========================================="
  echo "  Nexus Smoke Tests"
  echo "=========================================="

  # Test 1: Status endpoint (anonymous)
  TESTS=$((TESTS + 1))
  echo ""
  echo "--- Test 1: Status endpoint ---"
  HTTP_CODE=$($CURL -s -o /dev/null -w "%{http_code}" "${BASE_URL}/service/rest/v1/status")
  if [ "$HTTP_CODE" = "200" ]; then
    pass "GET /service/rest/v1/status -> $HTTP_CODE"
  else
    fail "GET /service/rest/v1/status -> $HTTP_CODE (expected 200)"
  fi

  # Test 2: Status check (writable)
  TESTS=$((TESTS + 1))
  echo ""
  echo "--- Test 2: Status writable check ---"
  HTTP_CODE=$($CURL -s -o /dev/null -w "%{http_code}" -u "admin:${ADMIN_PASSWORD}" \
    "${BASE_URL}/service/rest/v1/status/writable")
  if [ "$HTTP_CODE" = "200" ]; then
    pass "GET /service/rest/v1/status/writable -> $HTTP_CODE"
  else
    fail "GET /service/rest/v1/status/writable -> $HTTP_CODE (expected 200)"
  fi

  # Test 3: List repositories
  TESTS=$((TESTS + 1))
  echo ""
  echo "--- Test 3: List repositories ---"
  REPOS=$($CURL -sf -u "admin:${ADMIN_PASSWORD}" "${BASE_URL}/service/rest/v1/repositories" 2>/dev/null || echo "")
  if echo "$REPOS" | grep -q "maven-central"; then
    pass "Default maven-central repository exists"
  else
    fail "Default maven-central repository not found"
  fi

  # Test 4: List built-in repository formats
  TESTS=$((TESTS + 1))
  echo ""
  echo "--- Test 4: Repository formats available ---"
  FORMATS=$(echo "$REPOS" | grep -o '"format" *: *"[^"]*"' | sed 's/.*: *"//;s/"//' | sort -u | tr '\n' ',' | sed 's/,$//')
  if [ -n "$FORMATS" ]; then
    pass "Repository formats: $FORMATS"
  else
    fail "No repository formats found"
  fi

  # Test 5: Create a hosted maven repository
  TESTS=$((TESTS + 1))
  echo ""
  echo "--- Test 5: Create hosted Maven repository ---"
  REPO_NAME="smoke-test-maven-$(date +%s)"
  HTTP_CODE=$($CURL -s -o /dev/null -w "%{http_code}" -X POST \
    -u "admin:${ADMIN_PASSWORD}" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"${REPO_NAME}\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\",\"strictContentTypeValidation\":false,\"writePolicy\":\"allow\"},\"maven\":{\"versionPolicy\":\"MIXED\",\"layoutPolicy\":\"PERMISSIVE\"}}" \
    "${BASE_URL}/service/rest/v1/repositories/maven/hosted")
  if [ "$HTTP_CODE" = "201" ]; then
    pass "Created hosted Maven repo: $REPO_NAME"
  else
    fail "Failed to create hosted Maven repo -> $HTTP_CODE (expected 201)"
  fi

  # Test 6: Upload artifact via raw PUT
  TESTS=$((TESTS + 1))
  echo ""
  echo "--- Test 6: Upload artifact ---"
  TEMP_FILE=$(mktemp /tmp/smoke-test-XXXXXX.txt)
  echo "smoke-test-content" > "$TEMP_FILE"
  HTTP_CODE=$($CURL -s -o /dev/null -w "%{http_code}" \
    -u "admin:${ADMIN_PASSWORD}" \
    -T "$TEMP_FILE" \
    -H "Content-Type: application/octet-stream" \
    "${BASE_URL}/repository/${REPO_NAME}/com/example/smoke-test/1.0/smoke-test-1.0.txt")
  rm -f "$TEMP_FILE"
  if [ "$HTTP_CODE" = "201" ]; then
    pass "Uploaded artifact to $REPO_NAME"
  else
    fail "Failed to upload artifact -> $HTTP_CODE (expected 201)"
  fi

  # Test 7: Download the uploaded artifact
  TESTS=$((TESTS + 1))
  echo ""
  echo "--- Test 7: Download artifact ---"
  HTTP_CODE=$($CURL -s -o /dev/null -w "%{http_code}" -u "admin:${ADMIN_PASSWORD}" \
    "${BASE_URL}/repository/${REPO_NAME}/com/example/smoke-test/1.0/smoke-test-1.0.txt")
  if [ "$HTTP_CODE" = "200" ]; then
    pass "Downloaded artifact from $REPO_NAME"
  else
    fail "Failed to download artifact -> $HTTP_CODE (expected 200)"
  fi

  # Test 8: Create NPM hosted repository
  TESTS=$((TESTS + 1))
  echo ""
  echo "--- Test 8: Create hosted NPM repository ---"
  NPM_REPO="smoke-test-npm-$(date +%s)"
  HTTP_CODE=$($CURL -s -o /dev/null -w "%{http_code}" -X POST \
    -u "admin:${ADMIN_PASSWORD}" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"${NPM_REPO}\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\",\"strictContentTypeValidation\":true,\"writePolicy\":\"allow\"}}" \
    "${BASE_URL}/service/rest/v1/repositories/npm/hosted")
  if [ "$HTTP_CODE" = "201" ]; then
    pass "Created hosted NPM repo: $NPM_REPO"
  else
    fail "Failed to create hosted NPM repo -> $HTTP_CODE (expected 201)"
  fi

  # Test 9: Create PyPI hosted repository
  TESTS=$((TESTS + 1))
  echo ""
  echo "--- Test 9: Create hosted PyPI repository ---"
  PYPI_REPO="smoke-test-pypi-$(date +%s)"
  HTTP_CODE=$($CURL -s -o /dev/null -w "%{http_code}" -X POST \
    -u "admin:${ADMIN_PASSWORD}" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"${PYPI_REPO}\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\",\"strictContentTypeValidation\":true,\"writePolicy\":\"allow\"}}" \
    "${BASE_URL}/service/rest/v1/repositories/pypi/hosted")
  if [ "$HTTP_CODE" = "201" ]; then
    pass "Created hosted PyPI repo: $PYPI_REPO"
  else
    fail "Failed to create hosted PyPI repo -> $HTTP_CODE (expected 201)"
  fi

  # Test 10: Delete created test repos (cleanup)
  TESTS=$((TESTS + 1))
  echo ""
  echo "--- Test 10: Cleanup test repositories ---"
  CLEANUP_OK=true
  for REPO in "$REPO_NAME" "$NPM_REPO" "$PYPI_REPO"; do
    HTTP_CODE=$($CURL -s -o /dev/null -w "%{http_code}" -X DELETE \
      -u "admin:${ADMIN_PASSWORD}" \
      "${BASE_URL}/service/rest/v1/repositories/${REPO}")
    if [ "$HTTP_CODE" != "204" ]; then
      CLEANUP_OK=false
    fi
  done
  if [ "$CLEANUP_OK" = true ]; then
    pass "Cleaned up all test repositories"
  else
    fail "Some test repositories could not be deleted"
  fi

  # Summary
  echo ""
  echo "=========================================="
  echo "  Results: $((TESTS - FAILURES))/$TESTS passed"
  if [ $FAILURES -gt 0 ]; then
    echo "  $FAILURES FAILED"
    echo "=========================================="
    return 1
  else
    echo "  All smoke tests passed!"
    echo "=========================================="
    return 0
  fi
}

# =============================================
# Main
# =============================================
case "$CMD" in
  start)
    do_start
    echo "==> Container ready. Run '$0 test' to execute smoke tests."
    ;;
  test)
    do_test
    ;;
  stop)
    do_stop
    ;;
  run)
    do_start
    TEST_RESULT=0
    do_test || TEST_RESULT=$?
    if [ "$KEEP" = false ]; then
      do_stop
    else
      echo "==> Container '$CONTAINER_NAME' kept running on port $PORT"
    fi
    exit $TEST_RESULT
    ;;
  *)
    echo "Unknown command: $CMD"
    usage
    ;;
esac
