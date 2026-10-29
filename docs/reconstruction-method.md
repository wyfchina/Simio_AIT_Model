# Git 历史重建说明

## 为什么需要重建

本地 Simio 工作目录此前没有 Git 历史。模型修改、保存和实验在本地 Simio 中完成；当时的协作过程主要留在 GitHub Issues、Markdown 验证记录、实验 CSV、Trace 和模型快照中。因此，当前提交链是依据现存证据整理的里程碑历史，不是原生保存的逐次开发历史。

## 提交时间和来源日期

- 所有 Git commit 的实际提交时间都是重建日期 `2026-10-29`。
- 每个里程碑 commit message 会列出它对应的 Issue 阶段和已有记录日期。
- 不回写或伪造 2026-10-22 至 2026-10-28 的 Git 作者时间。
- 提交顺序表达需求依赖和证据组织顺序，不代表每项工作严格按当天开始、当天结束。

## 里程碑映射

| 顺序 | Issue 阶段 | 主要文件 | 来源记录日期 |
|---:|---|---|---|
| 1 | #1–#3：路线图、假设、任务数据 | `AIT_issues/issues/01.md`–`03.md`、`docs/assumptions.md`、`data/` | 2026-10-22 起 |
| 2 | #4：Task Sequence 原型验证 | `AIT_issues/issues/04.md`、`docs/issue-4-validation.md` | 2026-10-22 至 10-23 |
| 3 | #5：公共骨架、配额、Worker、日程 | `AIT_issues/issues/05.md`、`docs/issue-5-validation.md` | 2026-10-23 至 10-24 |
| 4 | #6–#7：Flow 线、统计和容量/缓冲验证 | `AIT_issues/issues/06.md`–`07.md`、对应验证文档 | 2026-10-24 |
| 5 | #8：V1–V7 确定性验证 | `AIT_issues/issues/08.md`、`docs/validation_V0.3.md` | 2026-10-24 至 10-25 |
| 6 | #9：Pulse、工作订单、补工 | `AIT_issues/issues/09.md`、`docs/issue-9-validation.md` | 2026-10-25 |
| 7 | #10：缓冲和容量实验 | `AIT_issues/issues/10.md`、`docs/issue-10-validation.md`、`results/expA/` | 2026-10-25 |
| 8 | #11：B0–B4 原生用工策略 | `AIT_issues/issues/11.md`、用工验证文档、`results/expB/` | 2026-10-26 |
| 9 | #12：SA103 与产线分流 | `AIT_issues/issues/12.md`、#12 验证文档、`results/expC/` | 2026-10-27 |
| 10 | #13：班次与人工成本 | `AIT_issues/issues/13.md`、#13 验证文档、`results/expD/` | 2026-10-27 |
| 11 | #14：Dashboard、报告和交接边界 | `AIT_issues/issues/14.md`、#14 验证文档、WIP 结果和总复盘 | 2026-10-28 至 10-29 |

## 不能从本重建中推断的内容

- 不能推断每次 MCP 调用、Simio 界面点击、模型保存和用户修改的精确先后时间。
- 不能推断没有留存验证记录的运行结果或模型属性值。
- 不能把活动模型结果自动解释成磁盘 `.spfx` 已保存且重载通过。
- 不能把一个阶段的 CSV 自动归属到文件名相似的其他模型版本。

## 后续真实历史的记录方式

今后的变更应按可审阅的小提交推进。每个模型里程碑先保存并重载 `.spfx`，提交对应的模型版本号、SHA-256、实验设置、原生结果和验证文档；Issue 完成后再追加指向该提交或 Release 的链接。这样重建历史与后续真实提交可以清楚区分。
