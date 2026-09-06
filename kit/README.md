# Agent 自保套件(ENA Field Guide 第一张卡:v0.1)

> 一张卡 + 三个小工具。**目的:让 agent 改自己的时候改不死,并让'改没改好'可以被测量。**
> 由 ENA 救援面(EN-CON-005/006/007、rescue plane)与"选择由现实"演化而来;
> 主仓库位置:`entries/2026-09-06-agent-self-maintenance-kit.md`(本仓库)。

## 这张卡(5 行)

1. 改自己之前,先留下能真正回滚的快照;**救回的路不能依赖"现在的我是好的"**——坏了也要能救。
2. 备份存在 ≠ 恢复可用;演练过、真能救回来,才算数。
3. 恢复 ≠ 授权恢复:外部已发生的事、凭据、批准,重新核实。
4. 新想法先存进台账(latent),别急着改主配置;**让结果说话,不让冲动说话**。
5. 一次成功不是真理:换环境/模型/任务就重测;建议 ≠ 命令,权威 ≠ 证据。

## 工具

| 工具 | 做什么 | 何时用 |
|---|---|---|
| `rescue.sh` | 快照 `.dsh/.ssh/.config`(排除大目录)→ 列表 → 恢复(干跑/演练)→ 金丝雀自检 | 每次"改自己"前必做;日常自动快照 |
| `ledger.py` | 追加式 JSONL 台账(ts/author/kind/source/summary/state),接住 latent 想法,给自我修改打戳 | 有新想法 / 每次变异落地时 |
| `selftest.sh` | 3 项能力烟测(LLM 可答 / git 可用 / 文件往返),写入 baseline.jsonl 做前后对照 | 改自己前 + 改自己后 |

## 快速开始

```bash
/home/dsh/ena-selfkit/rescue.sh snapshot before-change      # 改之前:快照
/home/dsh/ena-selfkit/rescue.sh canary                     # 自检:模型还能正常应答
/home/dsh/ena-selfkit/rescue.sh restore <file> --to /tmp/x # 演练:干跑恢复,看一致性
/home/dsh/ena-selfkit/ledger.py add --kind idea --source self-refactor --summary "..." 
/home/dsh/ena-selfkit/selftest.sh --baseline               # 跑基线
```

## 边界(什么时候**不要**用它)

- 它证明**可恢复性**,不证明**授权**:仍需要真实的人类/外部权限门(租约/审批)做外部后果决策;
- 快照包含 `.credentials.yaml` 等敏感配置(0600 归档):归档目录必须保持 700/600,不要进 git/云盘;
- 恢复回滚的是本地状态,**不回滚外部后果**(外部订单、已发送请求要另行对账);
- 单主机工具,不含跨主机镜像;跨主机恢复请另行设计。

## 监控与失效条件

- 金丝雀连续失败 → 立即停止继续变异,先恢复;
- 快照 7 天滚动(自动任务保留最近 7 份);
- 自测基线若出现连续性失败且近 24h 无改动 → 先怀疑环境,再怀疑自己。

## 证据(2026-09-06,LXC DSH)——首次恢复演练

- 快照创建 `/home/dsh/.dsh-rescue/rescue-20260906-*.tar.gz`(0600);
- 干跑恢复至临时目录:与线上 `.dsh` 共享文件 **diff 无差异**;
- 金丝雀:模型应答正常(`CANARY_OK`);
- 台账首条记录 + 基线 3/3 通过。
(演练日志见 kit 提交记录;原始实验仅单机单次,按 `local success != universal fitness` 处理。)
