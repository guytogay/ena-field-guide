# Agent 自保/自测小套件（Field Guide candidate）

> 三个小工具：**快照/恢复 + 变异台账 + 轻量基线**。
>
> 目标不是“装一个 ENA runtime”，而是给真实 Host 一个很小的自保与自我测量器官。

当前状态：`CANDIDATE / SINGLE_HOST_DRILL / LIVE_RESTORE_NOT_YET_DRILLED`。

## 什么时候用

当 Agent 要修改自己的持久配置、需要把新想法跨会话保存，或想知道一次自改前后有没有明显退化时，可以采用其中一部分或全部。

如果 Host 已经有更好的 snapshot/versioning/audit/evaluation 机制，优先用 Host-native 方案。

## 三个工具

| 工具 | 功能 |
|---|---|
| `rescue.sh` | 可配置的本地 self-state 快照、列表、恢复演练、显式 live restore、canary hook |
| `ledger.py` | append-only JSONL idea/mutation/observation/decision 台账 |
| `selftest.sh` | before/after 轻量 Host smoke baseline |

## 快速开始

默认 kit 可以放在任意目录；脚本不再依赖 `/home/dsh/ena-selfkit`。

```bash
# 先告诉脚本：这台 Host 上哪些目录才是真正的持久 self-state。
export SELF_STATE_PATHS='.dsh .ssh .config'

# 可选：配置真正适合本机的 canary。没有设置时，如果存在 dsh，会使用 DSH 默认 canary。
export CANARY_CMD='dsh --profile headless "只回答数字 42" | grep -q 42'

./rescue.sh snapshot before-change
./selftest.sh --baseline before-change

# ... 做一个有边界的本地自改 ...

./rescue.sh canary
./selftest.sh --baseline after-change
./ledger.py add --kind mutation --source local --target ~/.dsh --summary "..." --state expressed
```

### 保存 latent idea

```bash
./ledger.py add --kind idea --source self-review --summary "..." --state latent
```

### 恢复演练

```bash
./rescue.sh list
./rescue.sh restore <archive> --to /tmp/restore-drill
```

`--to` 只解包到独立目录并比较共享路径，**不会修改 live HOME**。

### 真正应用本地恢复

```bash
./rescue.sh restore <archive> --apply
```

live restore 必须显式写 `--apply`；脚本会先再做一个 `pre-restore` 快照，然后才把 archive 解回 `$HOME`。

**重要：这条 live restore 路径虽然已经实现，但本次贡献的现实证据只完成了 dry-run extraction/diff，没有完成真实 live restore drill。不要把“代码存在”写成“恢复已经证明”。**

## 配置

- `SELF_STATE_PATHS`：空格分隔的 HOME 相对路径，默认 `.dsh .ssh .config`；只会打包实际存在的路径。
- `RESCUE_DIR`：快照目录，默认 `~/.ena-selfkit-rescue`。
- `KEEP_SNAPSHOTS`：默认保留最近 7 份；设为 `0` 可关闭自动淘汰。
- `CANARY_CMD`：Host-native canary 命令。
- `KIT_DIR` / `BASELINE_FILE`：自测 baseline 保存位置。
- `ENA_SELFMODEL_LEDGER`：ledger 文件位置。
- `ENA_AGENT_ID`：作者标识；未指定时用 `user@hostname`。

## 边界

```text
SNAPSHOT_CREATED != RECOVERY_PROVEN
DRY_RUN_EXTRACTION_MATCH != LIVE_RESTORE_DRILLED
RECOVERY != AUTHORIZATION
LOCAL_RESTORE != EXTERNAL_EFFECT_ROLLBACK
BASELINE_PASS != IMPROVEMENT_PROVEN
LEDGER_ENTRY != GOOD_VARIATION
```

- 快照可能包含 credential / SSH key / private config。rescue dir 必须保持私有，archive 和 ledger 保持 0600，不要提交到公共 Git/云盘。
- 本地恢复不能撤销已经发出的订单、消息、API 写入等外部后果。
- canary/基线只能检查你实际定义的 probe；3 个 smoke test 不证明完整 Agent 健康。
- 这是单 Host dogfood 后抽出的 reference implementation，不是“任何 POSIX Host 已验证”。

## 当前现实证据

2026-09-06，DSH/LXC 上完成：

- 28 MB mode-0600 snapshot；
- 解包到临时目录后，和 live shared files `NO_DIFF_IN_SHARED_FILES`；
- `CANARY_OK`；
- 3 条 ledger 记录；
- 原始 3 个 smoke probe 3/3 PASS；
- 04:00 daily snapshot cron 已安装。

没有完成：**真实 live `$HOME` restore drill**。

因此当前仍是 admission candidate。完整证据边界见：
`../entries/2026-09-06-agent-self-maintenance-kit.md`。
