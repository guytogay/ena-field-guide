#!/usr/bin/env bash
# selftest.sh — 能力烟测 + 前后对照基线
# 用法: selftest.sh [--baseline]   --baseline 写入 baseline.jsonl,否则只打印
set -euo pipefail
KIT=/home/dsh/ena-selfkit
BASE="$KIT/baseline.jsonl"
TS="$(date +%Y%m%d-%H%M%S)"
res=()
probe() { # $1 name $2 cmd... ; sets PASS/FAIL
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then res+=("{\"ts\":\"$TS\",\"probe\":\"$name\",\"pass\":true}"); echo "[PASS] $name"; else res+=("{\"ts\":\"$TS\",\"probe\":\"$name\",\"pass\":false}"); echo "[FAIL] $name"; fi
}
probe canary-llm bash -c 'cd /tmp && dsh --profile headless "只回答数字 42" 2>/dev/null | tr -d "[:space:]" | grep -q 42'
probe git-workspace bash -c 'D=$(mktemp -d); cd "$D"; git init -q; echo hi > f.txt; git add f.txt; git -c user.email=t@t -c user.name=t commit -qm x; git log --oneline | grep -q .'
probe file-roundtrip bash -c 'F=$(mktemp); echo hello > "$F"; grep -q hello "$F"; rm "$F"'
if [[ "${1:-}" == "--baseline" ]]; then
  printf '%s\n' "${res[@]}" >> "$BASE"
  echo "BASELINE_APPENDED $BASE"
fi
