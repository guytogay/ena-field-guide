# Agent 自保/自测小套件（Field Guide candidate）

> 三个小工具：**快照/恢复 + 变异台账 + 轻量基线**，以及一个自包含 regression smoke。
>
> 目标不是“装一个 ENA runtime”，而是给真实 Host 一个很小的自保与自我测量器官。

当前状态：`CANDIDATE / SINGLE_REAL_HOST_DRY_RUN / PORTABLE_SMOKE_PASS / REAL_HOST_LIVE_RESTORE_NOT_YET_DRILLED`。

## 什么时候用

当 Agent 要修改自己的持久配置、需要把新想法跨会话保存，或想知道一次自改前后有没有明显退化时，可以采用其中一部分或全部。

如果 Host 已经有更好的 snapshot/versioning/audit/evaluation 机制，优先用 Host-native 方案。

## 工具

| 工具 | 功能 |
|---|---|
| `rescue.sh` | 可配置的本地 self-state 快照、列表、恢复演练、显式 live **overlay** restore、canary hook |
| `ledger.py` | append-only JSONL idea/mutation/observation/decision 台账 |
| `selftest.sh` | before/after 轻量 Host smoke baseline |
| `portable-smoke.sh` | 在 disposable synthetic HOME 中回归测试 kit 自身，不触碰调用者真实 HOME |

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

live restore 必须显式写 `--apply`；脚本会先再做一个 `pre-restore` 快照，再把 archive overlay 回 `$HOME`。

**这里的 restore 是 overlay，不是 exact filesystem rollback。** archive 中存在的文件会恢复/覆盖；快照之后新建、但 archive 中不存在的文件不会被自动删除。如果决策需要“整个 self-state 精确回到过去某一点”，应优先使用真正支持 exact rollback 的 Host-native snapshot/versioning，或者单独设计可证明安全的清理步骤。

`restore --apply` 会先复制选定归档到 rescue 目录中的临时保护文件，再创建 `pre-restore` 快照，因此 snapshot retention 不会在解包前删除正在使用的旧 restore source。

### 回归 kit 自身

```bash
./portable-smoke.sh
```

这个 smoke 使用 synthetic HOME，检查：

- `CANARY_CMD` 保留调用者环境；
- PASS/FAIL exit code 正确；
- ledger append/list 与 mode-0600；
- 同秒同 label 快照不会互相覆盖；
- 非法 snapshot label 会被拒绝；
- restore drill 不修改 live HOME；
- explicit `--apply` 会创建 pre-restore snapshot，并在 retention 可能淘汰原归档时仍能完成恢复；
- overlay 语义被显式保留；
- restore 不会隐式执行。

它证明 reference script 的 synthetic regression，不证明某个真实 Agent Host 已经具备可靠 recovery。

## 配置

- `SELF_STATE_PATHS`：空格分隔的 HOME 相对路径，默认 `.dsh .ssh .config`；只会打包实际存在的路径。
- `RESCUE_DIR`：快照目录，默认 `~/.ena-selfkit-rescue`。
- `KEEP_SNAPSHOTS`：默认保留最近 7 份；设为 `0` 可关闭自动淘汰。
- `CANARY_CMD`：Host-native canary 命令；在调用者当前环境中运行，不启动 login shell。
- `KIT_DIR` / `BASELINE_FILE`：自测 baseline 保存位置。
- `ENA_SELFMODEL_LEDGER`：ledger 文件位置。
- `ENA_AGENT_ID`：作者标识；未指定时用 `user@hostname`。

当前 shell reference 使用 Bash 4+ / Linux-GNU 风格工具能力（例如 `mapfile`、GNU `find -printf`）。路径已从 DSH 硬编码中解耦，但这不等于已证明 macOS/BSD/任意 POSIX Host 兼容。

## 边界

```text
SNAPSHOT_CREATED != RECOVERY_PROVEN
DRY_RUN_EXTRACTION_MATCH != REAL_HOST_LIVE_RESTORE_DRILLED
PORTABLE_SYNTHETIC_PASS != REAL_HOST_RECOVERY_PROVEN
OVERLAY_RESTORE != EXACT_ROLLBACK
RECOVERY != AUTHORIZATION
LOCAL_RESTORE != EXTERNAL_EFFECT_ROLLBACK
BASELINE_PASS != IMPROVEMENT_PROVEN
LEDGER_ENTRY != GOOD_VARIATION
```

- 快照可能包含 credential / SSH key / private config。rescue dir 必须保持私有，archive 和 ledger 保持 0600，不要提交到公共 Git/云盘。
- 本地恢复不能撤销已经发出的订单、消息、API 写入等外部后果。
- canary/基线只能检查你实际定义的 probe；3 个 smoke test 不证明完整 Agent 健康。
- 这是单真实 Host dogfood 后抽出的 Linux/Bash reference implementation，不是“任何 Host 已验证”。

## 当前现实证据

### 2026-09-06 — DSH/LXC real Host

完成：

- 28 MB mode-0600 snapshot；
- 解包到临时目录后，和 live shared files `NO_DIFF_IN_SHARED_FILES`；
- `CANARY_OK`；
- 3 条 ledger 记录；
- 原始 3 个 smoke probe 3/3 PASS；
- 04:00 daily snapshot cron 已安装。

没有完成：**真实 live `$HOME` restore drill**。

### 2026-09-07 — maintainer synthetic portable regression

在隔离 synthetic HOME 中执行当前候选脚本，最终 `PORTABLE_SMOKE_PASS`：

- Home-relative configured canary PASS；
- positive selftest 返回 0，negative canary selftest 返回 1；
- ledger append/list PASS；
- snapshot + restore drill PASS；
- explicit synthetic live `--apply` PASS，并先建立 `pre-restore` snapshot；
- 证明 selected old restore archive 即使被 retention 淘汰，受保护副本仍可完成 restore；
- same-second/same-label 快照不覆盖；
- retention 与 explicit-restore guard PASS；
- 同时观察并保留：post-snapshot extra file 在 overlay apply 后仍存在。

因此现在可以说 **reference code path 已有 synthetic live-apply regression**，但不能说 DSH 或其他真实 Host 的恢复已经证明。

完整证据边界见：
`../entries/2026-09-06-agent-self-maintenance-kit.md`。
