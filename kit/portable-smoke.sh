#!/usr/bin/env bash
# portable-smoke.sh — self-contained regression smoke for the Field Guide candidate kit.
# It uses a disposable synthetic HOME and does not touch the caller's real self-state.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
T="$(mktemp -d "${TMPDIR:-/tmp}/ena-selfkit-smoke.XXXXXX")"
trap 'rm -rf -- "$T"' EXIT

H="$T/home"
R="$T/rescue"
D="$T/drill"
B="$T/baseline.jsonl"
L="$T/ledger.jsonl"
mkdir -p "$H/.dsh" "$H/.ssh" "$H/.config" "$R"
printf 'original-config\n' > "$H/.config/test.txt"
printf 'original-dsh\n' > "$H/.dsh/state.txt"
printf 'key-material-test\n' > "$H/.ssh/testkey"
chmod 700 "$H/.ssh"
chmod 600 "$H/.ssh/testkey"

export HOME="$H"
export RESCUE_DIR="$R"
export SELF_STATE_PATHS='.dsh .ssh .config'
export KEEP_SNAPSHOTS=10
export CANARY_CMD='test -f "$HOME/.config/test.txt"'
export BASELINE_FILE="$B"
export ENA_SELFMODEL_LEDGER="$L"
export ENA_AGENT_ID='portable-smoke@test'

# Configured canary must see the caller's environment, including synthetic HOME.
"$SCRIPT_DIR/rescue.sh" canary | grep -q '^CANARY_OK$'
"$SCRIPT_DIR/selftest.sh" --baseline before

# A failing probe must make selftest fail, not merely print FAIL.
set +e
CANARY_CMD=false "$SCRIPT_DIR/selftest.sh" > "$T/negative-selftest.out" 2>&1
NEG_RC=$?
set -e
[[ "$NEG_RC" -eq 1 ]]
grep -q '^\[FAIL\] canary$' "$T/negative-selftest.out"

# Ledger append/list and permissions.
"$SCRIPT_DIR/ledger.py" add --kind idea --source smoke --summary 'portable smoke candidate'
"$SCRIPT_DIR/ledger.py" add --kind observation --source smoke --summary 'portable smoke observation' --state selected
[[ "$(stat -c '%a' "$L")" == '600' ]]
[[ "$(wc -l < "$L")" -eq 2 ]]
"$SCRIPT_DIR/ledger.py" list --tail 2 | grep -q 'portable smoke observation'

# Same-second, same-label snapshots must not overwrite one another.
BEFORE_SAME=$(find "$R" -maxdepth 1 -type f -name 'rescue-*-same.tar.gz' | wc -l)
"$SCRIPT_DIR/rescue.sh" snapshot same >/dev/null
"$SCRIPT_DIR/rescue.sh" snapshot same >/dev/null
AFTER_SAME=$(find "$R" -maxdepth 1 -type f -name 'rescue-*-same.tar.gz' | wc -l)
[[ $((AFTER_SAME-BEFORE_SAME)) -eq 2 ]]

# Invalid labels must not create path-like snapshot names.
set +e
"$SCRIPT_DIR/rescue.sh" snapshot '../bad' > "$T/bad-label.out" 2>&1
BAD_RC=$?
set -e
[[ "$BAD_RC" -eq 2 ]]
grep -q 'SNAPSHOT_FAIL label' "$T/bad-label.out"

# Capture an original state and verify drill behavior after mutation.
ORIGINAL_OUT=$("$SCRIPT_DIR/rescue.sh" snapshot original)
ORIGINAL=$(printf '%s\n' "$ORIGINAL_OUT" | awk '/SNAPSHOT_OK/{print $2}')
[[ -f "$ORIGINAL" ]]
printf 'mutated-config\n' > "$H/.config/test.txt"
printf 'new-file\n' > "$H/.config/new.txt"
DRILL_OUT=$("$SCRIPT_DIR/rescue.sh" restore "$ORIGINAL" --to "$D")
grep -q 'RESTORE_DRILL_DIFF_FOUND' <<<"$DRILL_OUT"
grep -q '^original-config$' "$D/.config/test.txt"
grep -q '^mutated-config$' "$H/.config/test.txt"

# Force the selected original archive to be the oldest retained snapshot. The
# pre-restore snapshot would prune it unless restore_apply protects its source first.
export KEEP_SNAPSHOTS=2
"$SCRIPT_DIR/rescue.sh" snapshot newer >/dev/null
# Retention may already remove unrelated older smoke snapshots; original + newer remain
# because original/newer are the latest pair for this phase.
[[ -f "$ORIGINAL" ]]
APPLY_OUT=$("$SCRIPT_DIR/rescue.sh" restore "$ORIGINAL" --apply)
grep -q 'RESTORE_APPLIED' <<<"$APPLY_OUT"
grep -q 'RESTORE_MODE overlay' <<<"$APPLY_OUT"
grep -q '^original-config$' "$H/.config/test.txt"
grep -q '^original-dsh$' "$H/.dsh/state.txt"
# Overlay restore intentionally does not delete files absent from the archive.
[[ -f "$H/.config/new.txt" ]]
# The old selected archive may be pruned by pre-restore retention; restore must still succeed.
[[ ! -f "$ORIGINAL" ]]
[[ "$(find "$R" -maxdepth 1 -type f -name 'rescue-*.tar.gz' | wc -l)" -eq 2 ]]

"$SCRIPT_DIR/rescue.sh" canary | grep -q '^CANARY_OK$'
"$SCRIPT_DIR/selftest.sh" --baseline after
[[ "$(wc -l < "$B")" -eq 6 ]]

# Restore is never implicit.
set +e
ARCH="$(find "$R" -maxdepth 1 -type f -name 'rescue-*.tar.gz' | head -1)"
"$SCRIPT_DIR/rescue.sh" restore "$ARCH" > "$T/implicit.out" 2>&1
IMPLICIT_RC=$?
set -e
[[ "$IMPLICIT_RC" -eq 2 ]]
grep -q 'restore is never implicit' "$T/implicit.out"

printf 'PORTABLE_SMOKE_PASS\n'
printf 'synthetic_live_apply=yes\n'
printf 'exact_rollback=no_overlay_only\n'
printf 'real_host_recovery_proven=no\n'
