# GitHub Issue 状态记录

状态核对日期：2026-10-29  
仓库：[`wyfchina/Simio_AIT_Model`](https://github.com/wyfchina/Simio_AIT_Model)  
判定原则：只依据已保存的验证文档、结果文件和用户确认的保存/重载记录；模型结构存在不等于验收通过。GitHub 评论会逐条写明证据与限制。

| Issue | 建议状态 | GitHub 状态 | 证据 | 剩余事项 |
|---:|---|---|---|---|
| #1 | 部分完成 | Open | [路线图](../AIT_issues/issues/01.md)、[协作复盘](collaboration-retrospective.md) | Issue 完成勾选、总报告、交付快照和全项目最终验收尚未统一回填 |
| #2 | 部分完成 | Open | [假设清单](assumptions.md) | 原始案例 PDF/工作簿未随项目归档，需补来源复核 |
| #3 | 部分完成 | Open | [任务表数据](../data/Tbl_Tasks.csv)、[#5 最终包核验](issue-5-validation.md) | `Tbl_Stations` 全字段中文 Description 的最终快照证据仍需确认 |
| #4 | 部分完成 | Open | [原型验证记录](issue-4-validation.md) | 原型 S1–S4 未完整运行；后续正式模型验证不能替代原型验收记录 |
| #5 | 已完成 | Closed | [#5 原生验证](issue-5-validation.md)、[V0.3 路由/模型核验](issue-6-validation.md) | 当前发布快照与历史正式包哈希差异见 [`models/README.md`](../models/README.md)，不再作为 Issue #5 的未完成项 |
| #6 | 部分完成 | Open | [Flow 运行验收](issue-6-validation.md) | 四组合运行已通过；最后一次保存后重载及屏幕布局目视检查未留独立证据 |
| #7 | 部分完成 | Open | [统计框架](issue-7-validation.md)、[#14 WIP Dashboard 验证](issue-14-wip-dashboard-validation-20261028.md) | Dashboard Edit 模式仍报告字段 Invalid column，需修复或改用已验证的原生报告 |
| #8 | 部分完成 | Open | [V1–V7 验证](validation_V0.3.md) | V1–V7 结果通过；仍缺原生 Simio Trace 界面截图 |
| #9 | 已完成 | Closed | [Pulse 与工作订单验收](issue-9-validation.md) | 20 次重复、飞机/工单守恒、traveled work 与补工均有结果 |
| #10 | 已完成 | Closed | [缓冲/容量实验](issue-10-validation.md)、[`results/expA/`](../results/expA/) | 结论限 V0.5；BASE 的 Flow 专用 WIP/FlowTime 标为不适用，不与后续 V0.6 基线混用 |
| #11 | 已完成 | Closed | [B0–B4 原生 Task 验收](issue-11-native-task-validation.md)、[`results/expB/`](../results/expB/) | 结论限 V0.6 用工策略实验口径 |
| #12 | 已完成 | Closed | [SA103 闭环记录](issue-12-closure-20261027.md)、[`results/expC/`](../results/expC/) | 32 个场景、160 次预验收重复和 D1 非对称负荷测试已有结果；候选模型哈希边界已注明 |
| #13 | 已完成 | Closed | [班次/人工成本验收](issue-13-validation-20261027.md)、[`results/expD/`](../results/expD/) | 20 个场景、200 次重复；成本响应与原生 Reports 已核对 |
| #14 | 部分完成 | Open | [WIP Dashboard 验证](issue-14-wip-dashboard-validation-20261028.md)、[V1.0 候选快照](../models/AIT_V1.0_Final.spfx) | `AIT_V1.0_Final.spfx` 已保存并登记；仍需关闭、重载、Dashboard/Experiment 核验和最终交接包复核 |

## 可查询方式

- 已关闭的验收项：`is:issue is:closed label:status:verified`
- 尚有证据缺口的项：`is:issue is:open label:status:partial`
- 提到仓库维护者的评论：`is:issue is:open mentions:@me`

每条 GitHub Issue 的最新评论均带 `@wyfchina` 提及、对应证据链接和剩余事项。此文件记录本轮状态基线；之后变更应同步更新 Issue 评论、状态和本文件。
