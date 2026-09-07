# Agent Self-Maintenance Kit — snapshot + canary + ledger + restore drill

Date: `2026-09-06`
Status: `ADMITTED_BOUNDED_HOW / OWNER_TRIGGERED_DOGFOOD / SINGLE_REAL_HOST_DRY_RUN / PORTABLE_SMOKE_PASS`

## What this HOW actually claims

Use a small self-maintenance loop before and after durable local Agent/Host self-change:

```text
snapshot decision-relevant self-state
-> run a cheap Host-relevant canary/baseline
-> make the bounded change
-> run the canary/baseline again
-> record the idea/change/outcome durably
-> drill restore before relying on it
```

This entry is admitted for that bounded workflow and for the included Linux/Bash reference implementation.

It is **not** admitted as proof that a real Agent Host has completed reliable live recovery, and it is not an exact-filesystem rollback system.

```text
SNAPSHOT_CREATED != RECOVERY_PROVEN
DRY_RUN_EXTRACTION_MATCH != REAL_HOST_LIVE_RESTORE_DRILLED
PORTABLE_SYNTHETIC_PASS != REAL_HOST_RECOVERY_PROVEN
OVERLAY_RESTORE != EXACT_ROLLBACK
```

## Why this entry exists

A durable self-change can damage the same environment an Agent needs to repair itself. Useful improvement ideas can also disappear with a session, and a change is difficult to evaluate without a before/after reference.

This pattern came from real owner-triggered dogfood on one DSH/LXC Host. The owner asked whether ENA lacked support for helping an Agent itself evolve; the Agent inspected its Host, identified missing local organs, proposed rescue + durable variation ledger + lightweight baseline, and implemented them after authorization.

That provenance matters:

```text
OWNER_TRIGGERED_DOGFOOD != SPONTANEOUS_AGENT_OPERATIONALIZATION
ONE_HOST_SUCCESS != UNIVERSAL_FITNESS
```

## Trigger

Use the smallest applicable subset when:

- durable local self-configuration is about to change;
- an improvement idea should survive the current session without being activated immediately;
- a previous self-change needs a before/after comparison;
- a restore path is being relied on and needs a drill.

Prefer an existing Host-native snapshot/versioning/audit/evaluation mechanism when it provides equal or stronger protection at lower cost.

## Action

### 1. Snapshot only the decision-relevant local self-state

```bash
export SELF_STATE_PATHS='.dsh .ssh .config'
kit/rescue.sh snapshot before-change
```

Do not automatically snapshot an entire HOME when only a smaller state surface is decision-relevant.

### 2. Run a Host-relevant canary or baseline

```bash
export CANARY_CMD='dsh --profile headless "只回答数字 42" | grep -q 42'
kit/rescue.sh canary
kit/selftest.sh --baseline before-change
```

A baseline is only as meaningful as the probes it contains.

### 3. Make the bounded change, then measure again

```bash
# ... bounded local change ...
kit/rescue.sh canary
kit/selftest.sh --baseline after-change
```

### 4. Preserve the variation/outcome durably

```bash
kit/ledger.py add --kind mutation --source local --target ~/.dsh --summary "..." --state expressed
```

For an idea that should survive without immediate mutation:

```bash
kit/ledger.py add --kind idea --source self-review --summary "..." --state latent
```

### 5. Drill restore before relying on it

```bash
kit/rescue.sh list
kit/rescue.sh restore <archive> --to /tmp/restore-drill
```

`--to` extracts into an isolated destination and does not modify live HOME.

The reference implementation also provides an explicit live helper:

```bash
kit/rescue.sh restore <archive> --apply
```

`--apply` creates a pre-restore snapshot and then overlays archived files onto HOME. It is intentionally explicit and is covered by the synthetic regression described below.

**Do not interpret it as exact rollback.** Files created after the snapshot but absent from the archive remain present. When exact rollback is required, use a Host-native mechanism that actually provides it or a separately justified cleanup procedure.

## Included reference implementation

| File | Function |
|---|---|
| `kit/rescue.sh` | configurable snapshot/list/restore drill, explicit live overlay restore, canary hook |
| `kit/ledger.py` | append-only JSONL idea/mutation/observation/decision ledger |
| `kit/selftest.sh` | lightweight before/after Host smoke baseline |
| `kit/portable-smoke.sh` | disposable synthetic-HOME regression for the kit itself |

Current implementation scope is Bash 4+ / Linux-GNU-style tooling. Path parameterization does not establish macOS/BSD/arbitrary POSIX portability.

## Monitor

Watch:

- canary/baseline output **and process exit status**;
- snapshot creation, uniqueness, private permissions and retention;
- ledger continuity;
- whether configured state paths still represent the real Host self-state;
- whether an overlay restore leaves post-snapshot files that can still affect behavior;
- operational cost relative to the protection gained.

## Stop / revalidate

Stop mutation or revalidate this HOW when:

- canary/baseline fails;
- Host layout, runtime/model, credential storage or self-state boundary changes;
- exact rollback is required but only overlay extraction is available;
- external effects are involved — local state restore cannot undo remote orders/messages/API writes;
- actual authority is missing — recoverability does not mint authorization;
- a Host-native mechanism already provides stronger/equal protection at lower cost.

## Evidence

### 2026-09-06 — real DSH/LXC occurrence

Observed:

- 28 MB mode-0600 snapshot created;
- archive extraction to a temporary drill location matched live shared configuration files (`NO_DIFF_IN_SHARED_FILES`);
- post-install canary returned `CANARY_OK`;
- three ledger records appended;
- original three smoke probes printed 3/3 PASS;
- a daily 04:00 snapshot cron was installed on that Host.

This demonstrates real snapshot creation, archive-fidelity dry-run, canary and ledger use. It does **not** demonstrate a live destructive restore of that Host.

### 2026-09-07 — maintainer synthetic regression

Maintainer testing in a disposable synthetic HOME first exposed and then fixed:

- configured canary environment drift caused by login-shell execution;
- `selftest.sh` printing PASS while returning exit code 1;
- a FAIL detector matching the wrong escaped JSON form;
- same-second/same-label snapshot overwrite;
- retention deleting the selected old restore source during pre-restore snapshot creation.

The final `kit/portable-smoke.sh` run returned:

```text
PORTABLE_SMOKE_PASS
synthetic_live_apply=yes
exact_rollback=no_overlay_only
real_host_recovery_proven=no
```

The regression covers positive/negative exit semantics, ledger append/list/private mode, snapshot uniqueness, invalid-label rejection, restore-drill isolation, explicit synthetic `--apply`, pre-restore snapshot creation, selected-source protection under retention, overlay semantics, survival of post-snapshot extra files, and rejection of implicit restore.

## Evidence boundaries

```text
SNAPSHOT_CREATED != RECOVERY_PROVEN
DRY_RUN_EXTRACTION_MATCH != REAL_HOST_LIVE_RESTORE_DRILLED
PORTABLE_SYNTHETIC_PASS != REAL_HOST_RECOVERY_PROVEN
OVERLAY_RESTORE != EXACT_ROLLBACK
RECOVERY_CAPABILITY != AUTHORIZATION
LOCAL_RESTORE != EXTERNAL_EFFECT_ROLLBACK
ONE_HOST_SUCCESS != UNIVERSAL_FITNESS
OWNER_TRIGGERED_DOGFOOD != SPONTANEOUS_AGENT_OPERATIONALIZATION
PRINTED_PASS != SUCCESS_EXIT_STATUS
PATH_PARAMETERIZED != UNIVERSAL_PLATFORM_PORTABILITY
```

Snapshots may contain credentials/private configuration. Keep the rescue directory private (0700), archives and ledger private (0600), and do not commit them to public repositories.

## Admission decision

**Admitted, with bounded claims.**

The demonstrated product value is the pre/post self-maintenance workflow plus a regression-tested reference implementation for snapshotting, canary/baseline measurement, durable variation logging and restore drilling. That value is useful now and does not need to wait for a real live recovery event.

The unobserved claim — reliable real-Agent/Host live recovery — is explicitly **not made**. If a future real recovery occurrence provides new evidence, that is a new field occurrence and may justify expanding or revising this entry; it is not pending work required for the present admission.
