# Agent Self-Maintenance Kit — rescue + variation ledger + lightweight baseline

Date: `2026-09-06`
Status: `ADMISSION_CANDIDATE / SINGLE_HOST_DRILL / OWNER_TRIGGERED_DOGFOOD / LIVE_RESTORE_NOT_YET_DRILLED`

## Why this candidate exists

The recurring practical problem is simple: an Agent that durably modifies its own configuration
can damage the same environment it would need in order to repair itself; useful ideas can also die
with a session, and self-change is hard to evaluate without a before/after reference.

The full conversation matters for provenance. This kit did **not** emerge spontaneously from merely
loading ENA. The owner first questioned whether ENA was becoming too much machinery, then explicitly
asked whether it lacked support for helping the Agent itself evolve. That question caused the DSH
Agent to inspect its LXC Host, identify missing local organs, propose this three-part kit, and build
it after owner authorization.

So this is real dogfood and real Host contact, but it is **owner-triggered**, not proof that semantic
adoption alone makes Agents operationalize the right HOW.

Upstream inspiration is ENA recovery/evolution semantics; this entry must still stand on its own if
that upstream repository disappears.

## The HOW

For durable local self-change, use the smallest applicable subset of this loop:

```text
1. snapshot before change
2. run a cheap canary / smoke baseline
3. make the bounded change
4. run canary / baseline again
5. append the idea/change/outcome to a durable local ledger
6. if the result is bad or uncertain, drill or perform local restore as appropriate
```

For an idea that should survive without immediate mutation:

```text
ledger.py add --kind idea --source <source> --summary "..." --state latent
```

This is deliberately not a universal Agent runtime. A Host may already have better native
snapshotting, versioning, audit or evaluation machinery; use that instead.

## Included reference implementation

| File | Function |
|---|---|
| `kit/rescue.sh` | configurable snapshot, snapshot list, restore drill, explicit live restore, canary hook |
| `kit/ledger.py` | append-only JSONL idea/mutation/observation/decision ledger with author/session stamp |
| `kit/selftest.sh` | lightweight before/after Host smoke baseline |

### Example

```bash
# Configure what actually represents durable self-state on this Host.
export SELF_STATE_PATHS='.dsh .ssh .config'
export CANARY_CMD='dsh --profile headless "只回答数字 42" | grep -q 42'

kit/rescue.sh snapshot before-change
kit/selftest.sh --baseline before-change

# ... bounded local change ...

kit/rescue.sh canary
kit/selftest.sh --baseline after-change
kit/ledger.py add --kind mutation --source local --target ~/.dsh --summary "..." --state expressed

# Restore drill: extract elsewhere and compare; never modifies live HOME.
kit/rescue.sh restore ~/.ena-selfkit-rescue/rescue-*.tar.gz --to /tmp/restore-drill

# Live restore is intentionally explicit and creates a pre-restore snapshot first.
kit/rescue.sh restore <archive> --apply
```

## Trigger → action → monitor → stop

**Trigger**

- durable self-configuration is about to change;
- a self-improvement idea should survive the current session;
- a previous self-change needs before/after comparison;
- recovery capability needs a drill.

**Action**

- snapshot only the decision-relevant local self-state;
- run a Host-relevant canary/baseline;
- keep untested ideas latent rather than editing the active self immediately;
- use restore drill before relying on a restore path for material changes.

**Monitor**

- canary/baseline result;
- snapshot creation and retention;
- ledger continuity;
- whether the configured state paths still match the real Host.

**Stop / revalidate**

- canary/baseline failure: stop further mutation and diagnose/restore first;
- Host layout, model/runtime, credential storage or self-state boundary changes;
- external effects are involved: local restore does not undo remote orders, messages or writes;
- authorization is required: recoverability does not mint authority;
- a Host-native mechanism already provides equal or better protection at lower cost.

## Evidence from 2026-09-06 DSH/LXC occurrence

Demonstrated on one DSH LXC Host:

- a 28 MB mode-0600 snapshot was created;
- archive extraction to a temporary drill location matched live shared configuration files
  (`NO_DIFF_IN_SHARED_FILES`);
- post-install canary returned `CANARY_OK`;
- 3 ledger records were appended;
- the original three smoke probes passed 3/3;
- a daily 04:00 snapshot cron was installed on that Host.

Important narrowing:

- this demonstrated **snapshot creation + archive fidelity in a dry-run extraction**, not a live
  destructive restore of `$HOME`;
- the original contributed `restore` command did not actually apply the archive to live state;
  the reference implementation in this PR was corrected so live restore now requires explicit
  `--apply` and takes a pre-restore snapshot first;
- therefore `LIVE_RESTORE_NOT_YET_DRILLED` remains part of the admission status until a real
  controlled restore drill is observed;
- the original DSH implementation used DSH-specific paths/commands; the reference implementation
  has been parameterized, but portability beyond the observed Host remains unproven.

## Evidence boundaries

```text
SNAPSHOT_CREATED != RECOVERY_PROVEN
DRY_RUN_EXTRACTION_MATCH != LIVE_RESTORE_DRILLED
RECOVERY_CAPABILITY != AUTHORIZATION
LOCAL_ROLLBACK != EXTERNAL_EFFECT_ROLLBACK
ONE_HOST_SUCCESS != UNIVERSAL_FITNESS
OWNER_TRIGGERED_DOGFOOD != SPONTANEOUS_AGENT_OPERATIONALIZATION
```

Snapshots may contain credentials or private configuration. Keep the rescue directory private
(0700) and archives/ledger private (0600); do not push them into public repositories.

## Admission question

This candidate now has a concrete trigger/action/monitor/stop loop and one real Host drill, but the
most important recovery claim still lacks a controlled live restore drill. Maintainer admission
should therefore remain **candidate**, not promote this as a generally proven recovery recipe yet.
