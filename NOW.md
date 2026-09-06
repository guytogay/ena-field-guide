# NOW

## Current role

ENA Field Guide is the downstream home for **practical, evidence-backed ENA HOW**.

It does not mirror ENA theory, Current packaging, or general Human-AI project-working method.

```text
ENA research / field evidence
-> reusable trigger/action/monitor/stop pattern earns admission
-> Field Guide HOW
```

## Current admission state

No standalone HOW entry has been fully admitted yet.

That remains intentional. A populated repository is not the goal. A candidate entry must have:

- a recurring or materially real problem;
- concrete reusable action;
- evidence/reality contact beyond attractive theory;
- applicability boundary or counterexample;
- monitoring/failure conditions;
- practical value outside the originating experiment/session;
- enough independence from upstream ENA that the entry remains useful without duplicating the package.

## Current candidate: agent self-maintenance kit

Status:

`ADMISSION_CANDIDATE / SINGLE_HOST_DRILL / OWNER_TRIGGERED_DOGFOOD / LIVE_RESTORE_NOT_YET_DRILLED`

The candidate combines three small functions:

```text
local snapshot / restore drill / canary
+ durable idea/mutation ledger
+ lightweight before/after smoke baseline
```

The full conversation narrows its provenance:

- the owner reported that the larger ENA project felt "骑虎难下";
- the owner questioned whether ENA controls such as the lease loop actually paid rent;
- the owner explicitly asked whether ENA lacked support for helping the Agent itself evolve;
- that question triggered the DSH Agent to inspect its LXC Host;
- the DSH Agent then proposed rescue + ledger + baseline organs and implemented them after owner authorization.

Therefore:

```text
OWNER_TRIGGERED_HOST_AUDIT != OWNER_DESIGNED_ORGANS
OWNER_TRIGGERED_DOGFOOD != SPONTANEOUS_AGENT_OPERATIONALIZATION
```

Reality contact on the originating DSH/LXC Host demonstrated:

- snapshot creation (28 MB, mode 0600);
- archive extraction to a drill directory with no diff in shared live files;
- canary success;
- 3 durable ledger records;
- original smoke baseline 3/3 PASS;
- a daily snapshot cron installed on that Host.

Maintainer review found that the original contributed `restore <file>` path did **not** actually apply the archive to live `$HOME`, despite the entry describing a live restore command. The branch implementation has now been corrected so live restore requires explicit `--apply` and creates a pre-restore snapshot; Host paths/canary/author/baseline storage have also been parameterized rather than hard-coded to `/home/dsh`.

But code existence is not recovery evidence. A controlled live restore drill has not yet been observed, so the entry remains a candidate.

```text
SNAPSHOT_CREATED != RECOVERY_PROVEN
DRY_RUN_EXTRACTION_MATCH != LIVE_RESTORE_DRILLED
RECOVERY != AUTHORIZATION
LOCAL_ROLLBACK != EXTERNAL_EFFECT_ROLLBACK
ONE_HOST_SUCCESS != UNIVERSAL_FITNESS
```

See:

- `entries/2026-09-06-agent-self-maintenance-kit.md`
- `kit/`

## Upstream evidence review

### Metamemory Update Policy v1

The frozen four-arm primary is complete. Formal disposition:

```text
MECHANISM_ACTIVE_BUT_POLICY_OPTIMUM_UNRESOLVED
FIELD_UNRESOLVED_FOR_DURABLE_SELF_MODIFICATION
NO_CURRENT_SEMANTIC_CHANGE
```

Field Guide disposition: **no source-trust / selective-permeability HOW yet**. Synthetic mechanism evidence does not establish a real operating threshold or override/revalidation policy.

### Current ENA reality contact

Upstream Issue `#208` remains the version-neutral field stream. Recent DSH evidence has been useful for two different reasons:

- salience probes on a high-reasoning model were non-discriminating and were reconciled with narrowing rather than promoted into a positive claim;
- owner-triggered Host inspection exposed the practical gap between evolution vocabulary and an executable evolution loop / local organs.

The upstream product contract belongs upstream. This Field Guide candidate is only the concrete Host practice; it must not mirror the full ENA evolution loop.

## Other admission queue items

1. **source trust / selective permeability** — wait for real field cases that distinguish update speed, inertia, scope, override, and revalidation conditions;
2. **control retirement** — admit only if changing-ecology use demonstrates a reusable trigger/action/monitor/reactivate pattern beyond the upstream procedure;
3. **inheritance carrier choice** — reopen only if real use distinguishes distilled rules, richer developmental context or no inheritance in a decision-relevant way;
4. **new #208 field pattern** — any genuinely recurring operating problem may enter without belonging to a pre-existing research metaphor.

There is no obligation to keep a candidate for every upstream research track or release.

## Exact next action

For the self-maintenance candidate:

1. run a controlled **live local restore drill** with the corrected `--apply` path on a disposable/recoverable test state;
2. run the corrected portable scripts' own smoke checks;
3. only then decide whether the recovery portion has earned admission or should remain a candidate.

For every proposed entry ask:

> If the upstream theory/package link disappeared, would this still tell an Agent/operator what to do, when not to do it, what to watch, and when to revalidate?

If no, leave it upstream. If yes but evidence is weak, keep it as a candidate rather than doctrine.

## Do not overgrow

- Do not create entries to match every ENA research track or release.
- Do not turn negative/narrowing results into positive recipes.
- Do not duplicate `releases/current/` procedures or adopter documentation.
- Do not import Human-AI Workbench collaboration/release method.
- Do not call a dry-run extraction a proven live restore.
- Prefer zero admitted entries over premature doctrine.
