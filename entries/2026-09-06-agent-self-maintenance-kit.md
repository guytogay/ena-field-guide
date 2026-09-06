# Agent Self-Maintenance Kit — a rescue + measurement HOW for self-modifying Agents

Date: `2026-09-06`
Status: `ADMISSION_CANDIDATE_WITH_DRILL / SINGLE_HOST_OCCURRENCE / MAINTAINER_DISPOSITION_REQUIRED`
Provenance upstream: ENA rescue plane (ENA-CON-005/006/007, `recover != complete history`, `backup exists != recovery proven`); referenced, not copied (see `guytogay/evolution-native-agent-architecture`).

## The recurring problem

An Agent that modifies its own durable configuration (instructions, skills, credentials, profiles)
can break the thing that would otherwise repair it. This was the **original user need** that
generated ENA: *"the agent kept editing itself into a dead state"* (repeatedly observed by the
owner across prior sessions). ENA states the semantics; this HOW provides the operating minimum.

## The HOW (trigger → action → monitor → stop)

**When** an Agent is about to durably modify its own configuration (or when a new self-improvement
idea appears):

```text
1. snapshot   -> rescue.sh snapshot <label>       (config archive, 0600, excludes runtime dirs)
2. canary     -> rescue.sh canary                 (proof the agent still answers before the change)
3. change                                          (do the work)
4. canary     -> rescue.sh canary                 (proof the agent still answers after the change)
5. ledger     -> ledger.py add --kind mutation ...(author-stamped append-only record)
6. baseline   -> selftest.sh --baseline           (before/after capability smoke record)
```

**Every new idea** (including one not yet acted on) enters the ledger as `state: latent` —
an idea that never touches a durable surface is not lost to the session.

**Recovery** (when canary fails or the change looks wrong):

```text
rescue.sh list
rescue.sh restore <file> --to /tmp/drill   # dry-run first: diff against live
rescue.sh restore <file>                   # apply only after dry-run and authorization
```

**Monitor:** daily auto-snapshot (cron) + canary result + baseline continuity.

**Stop / revalidate when:**

- canary fails → stop changing, restore first, then investigate;
- the host's real authority gate (lease/approval) is required for the change → this kit is
  **not** a substitute: snapshot proves recoverability, it does not prove authorization;
- the change targets external consequences (sent requests, external state) → recovery here is
  local-only; use ENA effect-lifecycle/WAIT semantics instead of this kit;
- single-host assumption or snapshot target changes → revalidate the kit, don't assume.

## What it includes (in `kit/`)

| File | Purpose |
|---|---|
| `rescue.sh` | snapshot / list / restore (dry-run capable) / canary |
| `ledger.py` | append-only JSONL idea + mutation ledger with author stamp |
| `selftest.sh` | 3 probe capability smoke tests + baseline.jsonl |

## Evidence (drill executed 2026-09-06, DSH on LXC)

- snapshot created: `rescue-20260906-180230-before-selfkit.tar.gz` (28 MB, mode 0600);
- restore dry-run to temp dir: **NO_DIFF_IN_SHARED_FILES** vs live config;
- canary after kit install: `CANARY_OK`;
- ledger: 3 entries (decision/observation/idea) appended; selftest baseline: **3/3 PASS**;
- daily snapshot cron installed (04:00).

## Limits (stated per `local success != universal fitness`)

- one host (LXC), one model, one drill — a single occurrence, not a universal recipe;
- snapshots include credentials (`.credentials.yaml`, SSH keys): archive dir must stay 700/0600
  and must not enter public storage;
- no cross-host mirroring; no external-effect rollback; no authorization semantics.
