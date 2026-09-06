#!/usr/bin/env python3
"""Append-only local variation ledger.

Examples:
  ledger.py add --kind idea --source self-review --summary "try a smaller prompt"
  ledger.py add --kind mutation --source local --target ~/.agent/config --summary "..." --state expressed
  ledger.py list --kind idea --tail 20

The ledger preserves local occurrence/provenance. It does not prove that an idea is good,
a mutation is authorized, or an outcome is externally true.
"""
from __future__ import annotations

import argparse
import datetime as dt
import getpass
import json
import os
from pathlib import Path
import socket

DEFAULT_LEDGER = Path(os.environ.get("ENA_SELFMODEL_LEDGER", "~/ena-selfkit/mutation-ledger.jsonl")).expanduser()
DEFAULT_AUTHOR = os.environ.get("ENA_AGENT_ID") or f"{getpass.getuser()}@{socket.gethostname()}"
SESSION = os.environ.get("DSH_SESSION_ID") or os.environ.get("AGENT_SESSION_ID") or "UNKNOWN_SESSION"


def utc_now() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds")


def append_entry(path: Path, args: argparse.Namespace) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if not path.exists():
        path.touch(mode=0o600)
    else:
        os.chmod(path, 0o600)

    entry = {
        "ts": utc_now(),
        "author": args.author,
        "kind": args.kind,
        "source": args.source,
        "target": args.target,
        "summary": args.summary,
        "state": args.state,
        "session": SESSION,
    }
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False, sort_keys=True) + "\n")
    print("LEDGER_APPEND", entry["ts"], entry["kind"], entry["state"], entry["summary"][:80])


def iter_entries(path: Path):
    if not path.exists():
        return
    with path.open(encoding="utf-8") as f:
        for lineno, line in enumerate(f, start=1):
            line = line.strip()
            if not line:
                continue
            try:
                yield json.loads(line)
            except json.JSONDecodeError:
                print(f"LEDGER_INVALID_JSON line={lineno}")


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("--ledger", type=Path, default=DEFAULT_LEDGER)
    sub = p.add_subparsers(dest="cmd", required=True)

    a = sub.add_parser("add")
    a.add_argument("--kind", required=True, choices=["idea", "mutation", "observation", "decision"])
    a.add_argument("--source", required=True)
    a.add_argument("--target")
    a.add_argument("--summary", required=True)
    a.add_argument("--state", default="latent", choices=["latent", "expressed", "applied", "selected", "rejected", "dormant", "unknown"])
    a.add_argument("--author", default=DEFAULT_AUTHOR)

    l = sub.add_parser("list")
    l.add_argument("--kind")
    l.add_argument("--state")
    l.add_argument("--tail", type=int, default=10)

    args = p.parse_args()
    path = args.ledger.expanduser()

    if args.cmd == "add":
        append_entry(path, args)
        return

    rows = [
        d for d in iter_entries(path) or []
        if (not args.kind or d.get("kind") == args.kind)
        and (not args.state or d.get("state") == args.state)
    ]
    for d in rows[-args.tail:]:
        print(f"{d.get('ts')} {d.get('kind',''):11s} [{d.get('state','')}] {d.get('summary','')[:100]}")


if __name__ == "__main__":
    main()
