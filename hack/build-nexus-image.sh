#!/bin/bash
set -euo pipefail

# Build Nexus image: compile source JARs (if needed) + Docker build.
#
# Usage:
#   ./hack/build-nexus-image.sh [--tag TAG] [--skip-source] [--no-cache]
#
# Steps:
#   1. Check/build source JARs (nexus-ui-plugin, nexus-rapture, nexus-coreui-plugin)
#   2. Copy JARs to image/jar/
#   3. Docker build with cache (default)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TAG="nexus-local:3.76.0-03"
SKIP_SOURCE=false
NO_CACHE=""
NEXUS_VERSION="3.76.0-03"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag) TAG="$2"; shift 2 ;;
    --skip-source) SKIP_SOURCE=true; shift ;;
    --no-cache) NO_CACHE="--no-cache"; shift ;;
    -h|--help)
      echo "Usage: $0 [--tag TAG] [--skip-source] [--no-cache]"
      echo "  --tag TAG       Image tag (default: $TAG)"
      echo "  --skip-source   Skip source compilation, use existing JARs"
      echo "  --no-cache      Disable Docker build cache (only if cache is corrupted)"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

SOURCE_DIR="$REPO_ROOT/source"
IMAGE_DIR="$REPO_ROOT/image"
JAR_DIR="$IMAGE_DIR/jar"

# Step 1: Build source JARs if needed
if [ "$SKIP_SOURCE" = false ]; then
  JARS_EXIST=true
  for jar in \
    "$SOURCE_DIR/components/nexus-ui-plugin/target/nexus-ui-plugin-${NEXUS_VERSION}.jar" \
    "$SOURCE_DIR/components/nexus-rapture/target/nexus-rapture-${NEXUS_VERSION}.jar" \
    "$SOURCE_DIR/plugins/nexus-coreui-plugin/target/nexus-coreui-plugin-${NEXUS_VERSION}.jar"; do
    if [ ! -f "$jar" ]; then
      JARS_EXIST=false
      break
    fi
  done

  # Check for swagger-access-filter
  SWAGGER_JAR="$SOURCE_DIR/components/nexus-swagger-filter/target/swagger-access-filter.jar"

  if [ "$JARS_EXIST" = false ]; then
    echo "==> Building source JARs..."
    cd "$SOURCE_DIR"
    ./mvnw clean install -DskipTests \
      -pl components/nexus-ui-plugin,components/nexus-rapture,plugins/nexus-coreui-plugin,components/nexus-swagger-filter \
      -am
  else
    echo "==> Source JARs already exist, skipping build (use --skip-source=false to force)"
  fi

  # Step 2: Copy JARs to image/jar/
  echo "==> Copying JARs to $JAR_DIR..."
  mkdir -p "$JAR_DIR"
  cp "$SOURCE_DIR/components/nexus-ui-plugin/target/nexus-ui-plugin-${NEXUS_VERSION}.jar" "$JAR_DIR/"
  cp "$SOURCE_DIR/components/nexus-rapture/target/nexus-rapture-${NEXUS_VERSION}.jar" "$JAR_DIR/"
  cp "$SOURCE_DIR/plugins/nexus-coreui-plugin/target/nexus-coreui-plugin-${NEXUS_VERSION}.jar" "$JAR_DIR/"
  if [ -f "$SWAGGER_JAR" ]; then
    cp "$SWAGGER_JAR" "$JAR_DIR/"
  fi
fi

# Step 3: Docker build
echo "==> Building Docker image: $TAG"
cd "$REPO_ROOT"
docker build $NO_CACHE -f image/Containerfile.alpine.java17 -t "$TAG" ./image

echo "==> Build complete: $TAG"
echo "==> Next: ./hack/scan-image.sh --image $TAG"
