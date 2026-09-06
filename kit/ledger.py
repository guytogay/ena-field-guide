#!/usr/bin/env python3
"""ledger.py — 追加式变异台账:接住 latent idea,给自我修改打"作者戳"。
用法: ledger.py add --kind idea|mutation|observation|decision --source S [--target T] --summary "..."
      ledger.py list [--kind K]
数据: ~/ena-selfkit/mutation-ledger.jsonl (每个条目一行 JSON;追加式,不改写历史)"""
import json, sys, argparse, datetime, os

LEDGER = os.path.expanduser("~/ena-selfkit/mutation-ledger.jsonl")

def add(args):
    entry = {
        "ts": datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds"),
        "author": args.author,
        "kind": args.kind,
        "source": args.source,
        "target": args.target or None,
        "summary": args.summary,
        "state": args.state,
        "session": os.environ.get("DSH_SESSION_ID", "headless"),
    }
    with open(LEDGER, "a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")
    print("LEDGER_APPEND", entry["ts"], entry["kind"], entry["summary"][:60])

def main():
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="cmd", required=True)
    a = sub.add_parser("add")
    a.add_argument("--kind", required=True, choices=["idea","mutation","observation","decision"])
    a.add_argument("--source", required=True)
    a.add_argument("--target", default=None)
    a.add_argument("--summary", required=True)
    a.add_argument("--state", default="latent", choices=["latent","expressed","applied","selected","rejected"])
    a.add_argument("--author", default="dsh-lxc")
    a.set_defaults(fn=add)
    l = sub.add_parser("list")
    l.add_argument("--kind", default=None)
    l.add_argument("--tail", type=int, default=10)
    l.set_defaults(fn=lambda args: None)
    args = p.parse_args()
    if args.cmd == "add":
        add(args)
    else:
        rows = []
        if os.path.exists(LEDGER):
            with open(LEDGER, encoding="utf-8") as f:
                for line in f:
                    line = line.strip()
                    if not line: continue
                    try: d = json.loads(line)
                    except Exception: continue
                    if args.kind and d.get("kind") != args.kind: continue
                    rows.append(d)
        for d in rows[-args.tail:]:
            print(f"{d['ts']} {d['kind']:10s} [{d['state']}] {d['summary'][:100]}")

if __name__ == "__main__":
    main()
