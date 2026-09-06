#!/usr/bin/env bash
# rescue.sh — minimal local snapshot / restore-drill / explicit restore / canary helper
# Usage:
#   rescue.sh snapshot [label]
#   rescue.sh list
#   rescue.sh restore <archive> --to <DIR>   # drill only; never touches live HOME
#   rescue.sh restore <archive> --apply      # explicit live restore
#   rescue.sh canary
set -euo pipefail

RESCUE_DIR="${RESCUE_DIR:-$HOME/.ena-selfkit-rescue}"
KEEP_SNAPSHOTS="${KEEP_SNAPSHOTS:-7}"
SELF_STATE_PATHS="${SELF_STATE_PATHS:-.dsh .ssh .config}"
CANARY_CMD="${CANARY_CMD:-}"
TS="$(date +%Y%m%d-%H%M%S)"

EXCLUDE=(
  --exclude='.dsh/sessions' --exclude='.dsh/mcp' --exclude='.dsh/attachments'
  --exclude='.dsh/storages' --exclude='.dsh/llm-deepseek' --exclude='.dsh/.playwright*'
  --exclude='.dsh/.local' --exclude='.dsh/node_modules'
)

existing_paths() {
  local p
  for p in $SELF_STATE_PATHS; do
    [[ -e "$HOME/$p" ]] && printf '%s\n' "$p"
  done
}

snapshot() {
  local label="${1:-manual}"
  local paths=()
  while IFS= read -r p; do paths+=("$p"); done < <(existing_paths)
  ((${#paths[@]} > 0)) || { echo "SNAPSHOT_FAIL no configured SELF_STATE_PATHS exist under HOME"; return 2; }

  mkdir -p "$RESCUE_DIR"
  chmod 700 "$RESCUE_DIR"
  local out="$RESCUE_DIR/rescue-$TS-$label.tar.gz"
  tar czf "$out" -C "$HOME" "${EXCLUDE[@]}" "${paths[@]}"
  chmod 600 "$out"

  if [[ "$KEEP_SNAPSHOTS" =~ ^[0-9]+$ ]] && (( KEEP_SNAPSHOTS > 0 )); then
    mapfile -t old < <(find "$RESCUE_DIR" -maxdepth 1 -type f -name 'rescue-*.tar.gz' -printf '%T@ %p\n' | sort -nr | awk -v keep="$KEEP_SNAPSHOTS" 'NR>keep {sub(/^[^ ]+ /, ""); print}')
    ((${#old[@]} == 0)) || rm -f -- "${old[@]}"
  fi

  echo "SNAPSHOT_OK $out $(du -h "$out" | cut -f1)"
}

restore_drill() {
  local file="$1" target="$2"
  mkdir -p "$target"
  tar xzf "$file" -C "$target"
  echo "RESTORE_DRILL_EXTRACTED $file -> $target"

  local compared=0 differences=0 p
  for p in $SELF_STATE_PATHS; do
    if [[ -e "$target/$p" && -e "$HOME/$p" ]]; then
      compared=$((compared + 1))
      if ! diff -rq "$target/$p" "$HOME/$p"; then
        differences=$((differences + 1))
      fi
    fi
  done
  if (( compared == 0 )); then
    echo "RESTORE_DRILL_NO_SHARED_PATHS"
  elif (( differences == 0 )); then
    echo "NO_DIFF_IN_SHARED_FILES"
  else
    echo "RESTORE_DRILL_DIFF_FOUND count=$differences"
  fi
}

restore_apply() {
  local file="$1"
  # A pre-restore snapshot gives the restore itself a rollback point.
  snapshot pre-restore
  tar xzf "$file" -C "$HOME"
  echo "RESTORE_APPLIED $file -> $HOME"
  echo "Run canary and any Host-specific baseline before resuming consequential work."
}

run_canary() {
  if [[ -n "$CANARY_CMD" ]]; then
    if bash -lc "$CANARY_CMD"; then echo "CANARY_OK"; else echo "CANARY_FAIL"; return 1; fi
    return
  fi
  if command -v dsh >/dev/null 2>&1; then
    local out
    out="$(cd /tmp && dsh --profile headless "只回答数字 42" 2>/dev/null | tail -1 | tr -d '[:space:]')"
    [[ "$out" == *"42"* ]] && { echo "CANARY_OK"; return 0; }
    echo "CANARY_FAIL out='$out'"; return 1
  fi
  echo "CANARY_NOT_CONFIGURED set CANARY_CMD for this Host"
  return 2
}

case "${1:-}" in
  snapshot)
    snapshot "${2:-manual}"
    ;;
  list)
    find "$RESCUE_DIR" -maxdepth 1 -type f -name 'rescue-*.tar.gz' -printf '%T@ %p\n' 2>/dev/null | sort -nr | cut -d' ' -f2- | head -20 || true
    ;;
  restore)
    FILE="${2:-}"
    [[ -n "$FILE" && -f "$FILE" ]] || { echo "usage: restore <archive> --to <DIR> | --apply"; exit 2; }
    case "${3:-}" in
      --to)
        [[ -n "${4:-}" ]] || { echo "--to requires DIR"; exit 2; }
        restore_drill "$FILE" "$4"
        ;;
      --apply)
        restore_apply "$FILE"
        ;;
      *)
        echo "restore is never implicit: use --to <DIR> for a drill or --apply for live HOME"
        exit 2
        ;;
    esac
    ;;
  canary)
    run_canary
    ;;
  *)
    echo "usage: snapshot [label] | list | restore <archive> --to <DIR> | restore <archive> --apply | canary"
    exit 2
    ;;
esac
