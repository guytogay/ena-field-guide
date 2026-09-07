# Agent Self-Maintenance Kit — rescue + variation ledger + lightweight baseline

Date: `2026-09-06`
Status: `ADMISSION_CANDIDATE / OWNER_TRIGGERED_DOGFOOD / SINGLE_REAL_HOST_DRY_RUN / PORTABLE_SMOKE_PASS / REAL_HOST_LIVE_RESTORE_NOT_YET_DRILLED`

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
| `kit/rescue.sh` | configurable snapshot, snapshot list, restore drill, explicit live **overlay** restore, canary hook |
| `kit/ledger.py` | append-only JSONL idea/mutation/observation/decision ledger with author/session stamp |
| `kit/selftest.sh` | lightweight before/after Host smoke baseline |
| `kit/portable-smoke.sh` | disposable synthetic-HOME regression for the kit itself |

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
# It is an archive overlay, not an exact filesystem rollback.
kit/rescue.sh restore <archive> --apply

# Regression the reference implementation without touching real HOME.
kit/portable-smoke.sh
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
- use restore drill before relying on a restore path for material changes;
- treat `--apply` as overlay restore unless a stronger Host-native mechanism provides exact rollback.

**Monitor**

- canary/baseline result **and process exit status**;
- snapshot creation, uniqueness and retention;
- ledger continuity;
- whether the configured state paths still match the real Host;
- whether post-snapshot files remain after overlay restore and could still affect behavior.

**Stop / revalidate**

- canary/baseline failure: stop further mutation and diagnose/restore first;
- Host layout, model/runtime, credential storage or self-state boundary changes;
- exact rollback is required but only overlay extraction is available;
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
- the original three smoke probes printed 3/3 PASS;
- a daily 04:00 snapshot cron was installed on that Host.

Important narrowing:

- this demonstrated **snapshot creation + archive fidelity in a dry-run extraction**, not a live
  destructive restore of `$HOME`;
- the original contributed `restore` command did not actually apply the archive to live state;
  the reference implementation in this PR was corrected so live restore now requires explicit
  `--apply` and takes a pre-restore snapshot first;
- later maintainer regression found that the original `selftest.sh` success path returned exit code
  1 and its FAIL detector searched for the wrong escaped JSON pattern. Both defects are now fixed;
- therefore the original 3/3 printed PASS remains an occurrence observation, not proof that the old
  shell exit contract was correct;
- the original DSH implementation used DSH-specific paths/commands; the reference implementation
  is path-parameterized, but platform portability remains bounded to the current Linux/Bash/GNU-style
  implementation unless further evidence exists.

## Maintainer synthetic regression — 2026-09-07

A successor maintainer ran the current candidate in a disposable synthetic HOME rather than asking
the project owner to relay commands manually.

The first run exposed that configured `CANARY_CMD` used `bash -lc`, which could replace the caller's
HOME/environment. A later run exposed that `selftest.sh` could print all PASS while returning 1, and
that its FAIL detector could miss real FAIL rows. Review also identified two recovery hazards before
admission: same-second/same-label snapshot overwrite and retention potentially deleting the selected
restore source during the pre-restore snapshot.

Those defects were fixed on the PR branch, and a self-contained `kit/portable-smoke.sh` regression
was added. Final synthetic regression returned:

```text
PORTABLE_SMOKE_PASS
synthetic_live_apply=yes
exact_rollback=no_overlay_only
real_host_recovery_proven=no
```

The final smoke covers:

- caller-environment canary;
- positive selftest exit 0 and negative-canary exit 1;
- ledger append/list and private mode;
- same-second/same-label snapshot uniqueness;
- invalid snapshot-label rejection;
- restore drill isolation;
- explicit synthetic live `--apply`;
- pre-restore snapshot creation;
- selected old archive remaining usable even when retention removes its original path;
- explicit overlay semantics and survival of post-snapshot extra files;
- implicit-restore rejection.

This is decision-relevant evidence for the **reference code path**, but it is not a substitute for a
real DSH/Agent Host recovery drill.

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

Snapshots may contain credentials or private configuration. Keep the rescue directory private
(0700) and archives/ledger private (0600); do not push them into public repositories.

## Admission question

This candidate now has a concrete trigger/action/monitor/stop loop, one real Host dry-run occurrence,
and a maintainer-run synthetic live-apply regression that found and closed several implementation
defects.

The remaining admission boundary is narrower than before but still material: **a real Agent/Host live
recovery path has not yet been observed, and overlay restore must not be marketed as exact rollback.**

Maintainer admission should therefore remain **candidate**, not promote this as a generally proven
recovery recipe yet.
