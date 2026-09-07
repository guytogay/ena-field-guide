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

No standalone HOW entry has been admitted yet.

That remains intentional. A populated repository is not the goal. A candidate entry must have:

- a recurring or materially real problem;
- concrete reusable action;
- evidence/reality contact beyond attractive theory;
- applicability boundary or counterexample;
- monitoring/failure conditions;
- practical value outside the originating experiment/session;
- enough independence from upstream ENA that the entry remains useful without duplicating the package.

One active PR is currently under admission review:

- PR `#6` — **self-maintenance kit: rescue + variation ledger + baseline**;
- live status: `ADMISSION_CANDIDATE / OWNER_TRIGGERED_DOGFOOD / SINGLE_REAL_HOST_DRY_RUN / PORTABLE_SMOKE_PASS / REAL_HOST_LIVE_RESTORE_NOT_YET_DRILLED`;
- maintainer-run synthetic regression exposed and fixed configured-canary environment drift, false success/failure exit semantics, same-second snapshot collision, and retention deleting a selected restore source;
- `kit/portable-smoke.sh` now exercises the reference implementation in a disposable synthetic HOME without asking the project owner to relay commands;
- live `--apply` is explicitly **overlay restore**, not exact filesystem rollback; post-snapshot files absent from the archive are not deleted;
- admission remains blocked because a real Agent/Host live recovery path has not yet been observed. Synthetic code-path success is not real-host recovery proof.

Do not merge PR #6 as an admitted/proven recovery recipe merely because its current code is improved, its synthetic smoke passes, or upstream ENA benefits from the same occurrence.

## Latest upstream admission review

### ENA Current v0.3.14

Upstream ENA is currently `v0.3.14 / CURRENT / FIELD_VALIDATION`. v0.3.13 added the executable Minimum Evolution Loop and bounded local operationalization; v0.3.14 surfaced the existing Local Projection persistence cue in the minimum adoption path. The evolutionary-memory mechanism-discrimination campaign is closed.

Field Guide disposition for the release itself: **no standalone release-derived entry**.

Why:

- release/adoption semantics and the Current package remain upstream ENA responsibilities;
- project-working/release lessons remain Human-AI Workbench responsibilities;
- the practical self-maintenance occurrence is already represented separately as PR #6 and must earn admission on its own evidence, not inherit release status.

```text
UPSTREAM PRODUCT FIX != DOWNSTREAM FIELD HOW
UPSTREAM RELEASE != FIELD-GUIDE ADMISSION
AVAILABLE_RESOURCE != ADMISSION_OBLIGATION
```

Issue #208 remains version-neutral and follows Current. Future successors can continue producing field evidence in the same stream without creating a Field Guide candidate merely because the version changes.

## Current upstream evidence review

### Developmental Inheritance / MDS

Useful inheritance was demonstrated in the Morrow synthetic fixture, but full archive, distilled rules and MDS all transferred the tested phenotype. MDS-specific superiority was not observed.

Disposition: **do not publish an MDS-is-best recipe**.

### Temporal Assimilation / Developmental Order v1

No stable arm-specific developmental-order effect or persistent developmental debt was observed. The acquisition fixture was underidentified.

Disposition: **do not publish a developmental-order / critical-period recipe from this experiment**.

### Metamemory Update Policy v1

The frozen four-arm primary is complete. All four runs reconstructed their assigned state correctly, no preregistered replication trigger fired, and the formal disposition is:

```text
MECHANISM_ACTIVE_BUT_POLICY_OPTIMUM_UNRESOLVED
FIELD_UNRESOLVED_FOR_DURABLE_SELF_MODIFICATION
NO_CURRENT_SEMANTIC_CHANGE
```

The experiment supports that update policy, context scope, and reversal inertia can produce different downstream error profiles over the same object-level history. It does **not** establish C1, C2, a threshold of three observations, or any other tested policy as generally optimal.

Field Guide disposition: **no source-trust / selective-permeability HOW yet**.

Reason: a synthetic mechanism result is not enough to tell a real operator when to update trust, how much inertia to use, what evidence should override an incumbent, or when a policy should be reversed in a real Host. Admission now requires real field cases that expose those trigger/action/monitor/stop boundaries.

```text
MECHANISM_DEMONSTRATED != OPERATING_POLICY_EARNED
POLICY_TRADEOFF_OBSERVED != UNIVERSAL_THRESHOLD_JUSTIFIED
```

### Existing Current operational procedures

ENA Current already exposes practical procedures such as control retirement, standing input, purpose-relative continuity, and the Minimum Evolution Loop.

Their existence does not justify duplicated Field Guide entries. A separate entry becomes worthwhile only when real-use evidence adds a clearer trigger/action/monitor/stop pattern that remains useful without loading the upstream package.

## Active evidence source

Watch upstream Current field stream:

`guytogay/evolution-native-agent-architecture#208`

Also watch real downstream operating candidates such as PR #6. The Field Guide maintainer should independently verify candidate evidence and not infer admission from upstream release status.

Good admission signals include:

- the same practical failure appears in more than one real context;
- operators repeatedly need the same bounded response;
- a single-Host mechanism passes the specific missing reality check needed for its claimed scope;
- an upstream procedure is correct but too package-specific to serve as a standalone operating card;
- real use exposes when the procedure should **not** be used;
- monitoring and revalidation conditions become observable.

## Admission queue

Active candidates:

1. **self-maintenance kit / PR #6** — one real DSH/LXC dry-run occurrence plus maintainer synthetic `PORTABLE_SMOKE_PASS`; current remaining evidence boundary is a real Agent/Host recovery use or controlled live recovery drill; overlay restore must not be confused with exact rollback;
2. **source trust / selective permeability** — Metamemory mechanism evidence exists; wait for real field cases that distinguish update speed, inertia, scope, override, and revalidation conditions;
3. **control retirement** — admit only if real changing-ecology use demonstrates a reusable trigger/action/monitor/reactivate pattern beyond the Current procedure;
4. **inheritance carrier choice** — reopen only if real use distinguishes distilled rules, richer developmental context or no inheritance in a decision-relevant way;
5. **new #208 field pattern** — any genuinely recurring operating problem may enter without belonging to a pre-existing research metaphor.

There is no obligation to keep a candidate for every upstream research track or release.

## Exact next action

Maintain PR #6 as the active concrete candidate while continuing to observe #208 and real Host/adopter use.

For PR #6, the portable/script-level work that can be self-executed is now covered by an executable regression. Do not ask the project owner to rerun those mechanical checks. The next decision-changing evidence is whether a **real Agent/Host** recovery path works and remains worth its operational cost; that evidence should arise from an appropriate real-use opportunity or a genuinely warranted controlled live drill, not from manufacturing more synthetic passes.

Do not ask the human to perform mechanical repository or evidence-relay work that available Agent tooling can complete itself. Human participation should be reserved for genuinely irreducible Host/physical/authorization boundaries or decision-bearing judgment.

For every proposed entry ask:

> If the upstream theory/package link disappeared, would this still tell an Agent/operator what to do, when not to do it, what to watch, and when to revalidate?

If no, leave it upstream.

If yes but evidence is weak, keep it as a candidate rather than doctrine.

If yes and evidence is sufficient, add the smallest useful HOW and cite upstream provenance instead of copying research history.

## Do not overgrow

- Do not create entries to match every ENA research track or release.
- Do not turn negative/narrowing results into positive recipes.
- Do not duplicate `releases/current/` procedures or adopter documentation.
- Do not import Human-AI Workbench collaboration/release method.
- Do not treat upstream Current status as automatic Field Guide admission.
- Do not treat synthetic portable regression as real-host recovery proof.
- Do not preserve speculative admission queue items merely because they once appeared in a coverage map.
- Prefer zero entries over premature doctrine.
