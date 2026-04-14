#!/bin/bash
set -euo pipefail

# Sync .trivyignore from Thanos exemptions API.
#
# Usage:
#   ./hack/sync-trivyignore.sh [--branch BRANCH] [--dry-run]
#
# Fetches approved CVE exemptions and regenerates .trivyignore grouped by component.

BRANCH="release-3.76"
DRY_RUN=false
API_HOST=""
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TRIVYIGNORE="$REPO_ROOT/.trivyignore"

# Load .env from project root if it exists
if [ -f "$REPO_ROOT/.env" ]; then
  # shellcheck disable=SC1091
  source "$REPO_ROOT/.env"
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch) BRANCH="$2"; shift 2 ;;
    --api-host) API_HOST="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help)
      echo "Usage: $0 [--branch BRANCH] [--api-host HOST] [--dry-run]"
      echo "  --branch    Thanos branch (default: $BRANCH)"
      echo "  --api-host  API host (default: from .env THANOS_API_HOST)"
      echo "  --dry-run   Print to stdout instead of writing file"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Resolve API host: CLI flag > .env
API_HOST="${API_HOST:-${THANOS_API_HOST:-}}"
if [ -z "$API_HOST" ]; then
  echo "ERROR: API host not set. Use --api-host or set THANOS_API_HOST in .env"
  exit 1
fi
API_URL="https://${API_HOST}/api/v1/plugins/nexus-ce-operator/branches/${BRANCH}/exemptions?issue_type=vulnerability"

echo "==> Fetching exemptions from Thanos (branch: $BRANCH)..."
RESPONSE=$(command curl -sf "$API_URL") || {
  echo "ERROR: Failed to fetch exemptions from $API_URL"
  exit 1
}

# Validate JSON
if ! echo "$RESPONSE" | python3 -m json.tool > /dev/null 2>&1; then
  echo "ERROR: Invalid JSON response from API"
  exit 1
fi

# Generate .trivyignore content grouped by component
CONTENT=$(python3 -c "
import json, sys
from collections import defaultdict

data = json.loads(sys.stdin.read())
exemptions = data if isinstance(data, list) else data.get('data', data.get('items', data.get('exemptions', [])))

if not exemptions:
    print('# No exemptions found', file=sys.stderr)
    sys.exit(0)

# Group by component
groups = defaultdict(list)
for item in exemptions:
    issue = item.get('issue_data', {})
    cve = item.get('issue_id', issue.get('id', item.get('id', '')))
    reason = item.get('reason', item.get('description', 'No reason provided'))
    severity = issue.get('severity', item.get('severity', 'Unknown'))
    purl = issue.get('purl', '')
    component = item.get('component', item.get('package', purl if purl else 'Other'))
    groups[component].append((cve, severity, reason))

# Sort groups and output
print('# Trivy Ignore List for Nexus Build')
print('#')
print('# To update this file, run: ./hack/sync-trivyignore.sh')
print('# or: /fix-vulnerabilities (Step 0)')
print()

for component in sorted(groups.keys()):
    entries = groups[component]
    print(f'# ============================================================')
    print(f'# {component}')
    print(f'# ============================================================')
    print()
    for cve, severity, reason in sorted(entries):
        print(f'# [{severity}] {reason}')
        print(cve)
        print()
" <<< "$RESPONSE")

if [ -z "$CONTENT" ]; then
  echo "==> No exemptions found, keeping existing .trivyignore"
  exit 0
fi

if [ "$DRY_RUN" = true ]; then
  echo "==> Dry run — would write:"
  echo "$CONTENT"
  exit 0
fi

echo "$CONTENT" > "$TRIVYIGNORE"
echo "==> Updated $TRIVYIGNORE ($(grep -c '^CVE-' "$TRIVYIGNORE") CVEs)"

# Check if file changed in git
if command -v git > /dev/null && git -C "$REPO_ROOT" rev-parse --git-dir > /dev/null 2>&1; then
  if git -C "$REPO_ROOT" diff --quiet "$TRIVYIGNORE" 2>/dev/null; then
    echo "==> No changes detected"
  else
    echo "==> File changed — review with: git diff .trivyignore"
  fi
fi
