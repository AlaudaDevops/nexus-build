#!/bin/bash
set -euo pipefail

# Scan a Nexus image with Trivy and output categorized vulnerabilities.
#
# Usage:
#   ./hack/scan-image.sh [--image IMAGE] [--format FORMAT] [--full]
#
# Flags:
#   --image IMAGE   Image to scan (default: nexus-local:3.76.0-03)
#   --format FMT    Trivy output format: table, json (default: table)
#   --full          Show all severities including unfixed (skip --ignore-unfixed)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TRIVYIGNORE="$REPO_ROOT/.trivyignore"

IMAGE="nexus-local:3.76.0-03"
FORMAT="table"
IGNORE_UNFIXED="--ignore-unfixed"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --image) IMAGE="$2"; shift 2 ;;
    --format) FORMAT="$2"; shift 2 ;;
    --full) IGNORE_UNFIXED=""; shift ;;
    -h|--help)
      echo "Usage: $0 [--image IMAGE] [--format FORMAT] [--full]"
      echo "  --image IMAGE   Image to scan (default: $IMAGE)"
      echo "  --format FMT    Output format: table, json (default: table)"
      echo "  --full          Include vulnerabilities without fix versions"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

IGNOREFILE_FLAG=""
if [ -f "$TRIVYIGNORE" ]; then
  IGNOREFILE_FLAG="--ignorefile $TRIVYIGNORE"
  IGNORED_COUNT=$(grep -c '^CVE-' "$TRIVYIGNORE" 2>/dev/null || echo 0)
  echo "==> Using .trivyignore ($IGNORED_COUNT CVEs excluded)"
fi

echo "==> Scanning image: $IMAGE"
echo "==> Flags: $IGNORE_UNFIXED $IGNOREFILE_FLAG --format $FORMAT"
echo ""

trivy image $IGNOREFILE_FLAG $IGNORE_UNFIXED --format "$FORMAT" "$IMAGE"
