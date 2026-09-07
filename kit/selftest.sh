#!/usr/bin/env bash
# selftest.sh — lightweight Host smoke baseline for before/after self-change comparison
# Usage: selftest.sh [--baseline [label]]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="${KIT_DIR:-$SCRIPT_DIR}"
BASELINE_FILE="${BASELINE_FILE:-$KIT_DIR/baseline.jsonl}"
CANARY_CMD="${CANARY_CMD:-}"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
LABEL="manual"
WRITE_BASELINE=false
if [[ "${1:-}" == "--baseline" ]]; then
  WRITE_BASELINE=true
  LABEL="${2:-manual}"
fi

rows=()
record() {
  local name="$1" status="$2"
  rows+=("{\"ts\":\"$TS\",\"label\":\"$LABEL\",\"probe\":\"$name\",\"status\":\"$status\"}")
  printf '[%s] %s\n' "$status" "$name"
}

if [[ -n "$CANARY_CMD" ]]; then
  # Preserve the caller's environment; a login shell may rewrite HOME/PATH.
  if bash -c "$CANARY_CMD" >/dev/null 2>&1; then record canary PASS; else record canary FAIL; fi
elif command -v dsh >/dev/null 2>&1; then
  if bash -c 'cd /tmp && dsh --profile headless "只回答数字 42" 2>/dev/null | tr -d "[:space:]" | grep -q 42' >/dev/null 2>&1; then
    record canary PASS
  else
    record canary FAIL
  fi
else
  record canary SKIP
fi

if command -v git >/dev/null 2>&1; then
  if bash -c 'D=$(mktemp -d); trap "rm -rf \"$D\"" EXIT; cd "$D"; git init -q; echo hi > f.txt; git add f.txt; git -c user.email=t@t -c user.name=t commit -qm x; git log --oneline | grep -q .' >/dev/null 2>&1; then
    record git-workspace PASS
  else
    record git-workspace FAIL
  fi
else
  record git-workspace SKIP
fi

if bash -c 'F=$(mktemp); trap "rm -f \"$F\"" EXIT; echo hello > "$F"; grep -q hello "$F"' >/dev/null 2>&1; then
  record file-roundtrip PASS
else
  record file-roundtrip FAIL
fi

if $WRITE_BASELINE; then
  mkdir -p "$(dirname "$BASELINE_FILE")"
  touch "$BASELINE_FILE"
  chmod 600 "$BASELINE_FILE"
  printf '%s\n' "${rows[@]}" >> "$BASELINE_FILE"
  echo "BASELINE_APPENDED $BASELINE_FILE label=$LABEL"
fi

# A FAIL is a signal; SKIP means this Host lacks that probe and should define a better one if material.
for row in "${rows[@]}"; do
  [[ "$row" == *'\"status\":\"FAIL\"'* ]] && exit 1
done
