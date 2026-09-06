#!/usr/bin/env bash
# rescue.sh — Agent 自保套件:改自己之前的快照 / 恢复 / 金丝雀自检
# 使用: rescue.sh snapshot [label] | rescue.sh list | rescue.sh restore <file> [--to DIR] | rescue.sh canary
set -euo pipefail

RESCUE_DIR="${RESCUE_DIR:-/home/dsh/.dsh-rescue}"
# 覆盖面:能决定"我是谁/怎么跑/怎么连出去"的配置;排除大体积运行时目录
INCLUDE_PATHS=(.dsh .ssh .config)
EXCLUDE=(
  --exclude='.dsh/sessions' --exclude='.dsh/mcp' --exclude='.dsh/attachments'
  --exclude='.dsh/storages' --exclude='.dsh/llm-deepseek' --exclude='.dsh/.playwright*'
  --exclude='.dsh/.local' --exclude='.dsh/node_modules'
)
TS="$(date +%Y%m%d-%H%M%S)"

case "${1:-}" in
  snapshot)
    label="${2:-manual}"
    mkdir -p "$RESCUE_DIR"; chmod 700 "$RESCUE_DIR"
    OUT="$RESCUE_DIR/rescue-$TS-$label.tar.gz"
    tar czf "$OUT" -C "$HOME" "${EXCLUDE[@]}" "${INCLUDE_PATHS[@]}"
    chmod 600 "$OUT"
    echo "SNAPSHOT_OK $OUT $(du -h "$OUT" | cut -f1)"
    ;;
  list)
    ls -lt "$RESCUE_DIR"/*.tar.gz 2>/dev/null | head -20 || echo "no snapshots yet"
    ;;
  restore)
    FILE="${2:-}"
    [[ -z "$FILE" ]] && { echo "usage: restore <file> [--to DIR]"; exit 2; }
    [[ -f "$FILE" ]] || { echo "not found: $FILE"; exit 2; }
    TARGET="$HOME"
    if [[ "${3:-}" == "--to" ]]; then TARGET="${4:?}"; fi
    TMP="$(mktemp -d)"
    tar xzf "$FILE" -C "$TMP"
    echo "RESTORE_READY $FILE -> $TARGET (extracted to $TMP)"
    if [[ "$TARGET" != "$HOME" ]]; then
      echo "drill mode: extracted, not applied. Diff against live below."
      diff -rq "$TMP/.dsh" "$HOME/.dsh" 2>/dev/null | grep -v "Only in" || echo "NO_DIFF_IN_SHARED_FILES"
    else
      echo "WARNING: applying to $HOME is destructive; re-run with explicit path if intended."
    fi
    rm -rf "$TMP"; echo "RESTORE_CHECK_DONE"
    ;;
  canary)
    OUT="$(cd /tmp && dsh --profile headless "只回答数字 42" 2>/dev/null | tail -1 | tr -d '[:space:]')"
    if [[ "$OUT" == *"42"* ]]; then echo "CANARY_OK"; exit 0; else echo "CANARY_FAIL out='$OUT'"; exit 1; fi
    ;;
  *)
    echo "usage: snapshot [label] | list | restore <file> [--to DIR] | canary"; exit 2;;
esac
