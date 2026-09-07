# Agent 自保/自测小套件

状态：`ADMITTED_BOUNDED_HOW / SINGLE_REAL_HOST_DRY_RUN / PORTABLE_SMOKE_PASS`

这是一套用于 durable local self-change 的小型参考实现：

- `rescue.sh`：快照、列表、恢复演练、显式 live overlay restore、canary；
- `ledger.py`：append-only idea/mutation/observation/decision 台账；
- `selftest.sh`：before/after 轻量 Host baseline；
- `portable-smoke.sh`：在 disposable synthetic HOME 中回归 kit 自身。

它不是通用 ENA runtime，也不是 exact rollback 系统。Host 已经有更好的 snapshot/versioning/audit/evaluation 机制时，优先使用 Host-native 方案。

## 最小使用流程

```text
snapshot
-> canary/baseline before
-> bounded self-change
-> canary/baseline after
-> durable ledger
-> restore drill before reliance
```

### 配置真实 self-state

```bash
export SELF_STATE_PATHS='.dsh .ssh .config'
export CANARY_CMD='dsh --profile headless "只回答数字 42" | grep -q 42'
```

### 修改前

```bash
./rescue.sh snapshot before-change
./selftest.sh --baseline before-change
```

### 修改后

```bash
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

`--to` 只解包到独立目录，不修改 live HOME。

### 显式应用 overlay restore

```bash
./rescue.sh restore <archive> --apply
```

`--apply` 会先建立一个 `pre-restore` 快照，再将 archive 中存在的文件 overlay 回 HOME。

**这不是 exact filesystem rollback。** 快照以后新建、但 archive 中不存在的文件不会自动删除。如果决策需要整个 self-state 精确回到过去某一点，应使用真正支持 exact rollback 的 Host-native snapshot/versioning，或另外设计并验证安全清理步骤。

## 回归 kit 自身

```bash
./portable-smoke.sh
```

当前 regression 覆盖：

- caller-environment canary；
- PASS/FAIL exit code；
- ledger append/list 与私有权限；
- 同秒同 label 快照唯一性；
- 非法 label 拒绝；
- restore drill 隔离；
- explicit synthetic `--apply`；
- pre-restore snapshot；
- retention 场景下 selected restore source 保护；
- overlay 语义；
- implicit restore 拒绝。

最终 synthetic regression：

```text
PORTABLE_SMOKE_PASS
synthetic_live_apply=yes
exact_rollback=no_overlay_only
real_host_recovery_proven=no
```

## 证据边界

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

真实 DSH/LXC occurrence 已观察到 snapshot 创建、dry-run archive fidelity、canary、ledger 和 baseline 使用；当前没有声称真实 Host live recovery 已被证明。

未来如果出现真实 live recovery evidence，那是新的 field occurrence，可据此扩展或修订这份 HOW；它不是当前 admission 尚未完成的 pending 条件。

## 实现范围

当前 shell reference 使用 Bash 4+ / Linux-GNU 风格工具能力。路径已参数化，但这不等于 macOS/BSD/任意 POSIX Host 兼容已证明。

快照可能包含 credential / SSH key / private config。rescue dir 应保持 0700，archive 和 ledger 保持 0600，不要提交到公共 Git 或不受控云盘。

完整证据与 admission 边界见：

`../entries/2026-09-06-agent-self-maintenance-kit.md`
