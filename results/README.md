# 仿真结果版本与适用范围

本索引与 `expA`、`expB` 中的 CSV 一起分发。结果文件不含 Simio 模型本体；引用数值时应同时注明实验、模型版本阶段、控制口径和对应验证文档。不同版本的 BASE 结果不得拼接为同一时间序列或配对样本。

| 结果目录/文件 | 实验与模型阶段 | 版本基线 | 适用范围 | 验证记录 |
|---|---|---|---|---|
| `expA/*` | `Exp_A_Buffer`，V0.5 Pulse 基线 | `AIT_V0.5_PulseLine_QuotaInitFix.spfx` 阶段 | BASE、A1–A5；75 架、单线、S0。BASE 的 Flow 专用 WIP/FlowTime/Little/线内守恒指标无效，不得用于比较 | [`docs/issue-10-validation.md`](../docs/issue-10-validation.md) |
| `expB/*` | `Exp_B_Labor`，V0.6 Task 用工策略验收 | `AIT_V0.6_LaborFlex_C1PolicyPilot.spfx` 后续活动模型配置 | A1/A4/BASE × B0–B4；75 架、45/30/0 型号配额、单线、S0。结果是 V0.6 机制的策略对比 | [`docs/issue-11-native-task-validation.md`](../docs/issue-11-native-task-validation.md) |
| `issue14_wip_daily_A1_A3.csv` | `Issue14_WIP_TimeSeries`，活动模型 `/Project/Model` | 活动模型的磁盘保存版本尚未由 MCP 证明 | A1 与 A3；完工驱动、75 架、单线、容量 1、S0；按 24 小时周期汇总 `Sts_WIP`，CSV 每日列出重复数、平均值、标准差和 95% CI 半宽 | [`docs/issue-14-wip-dashboard-validation-20261028.md`](../docs/issue-14-wip-dashboard-validation-20261028.md) |

其他历史结果：

- [`docs/issue-7-validation.md`](../docs/issue-7-validation.md) 中的 `Issue7_FlowValidation` 属于 V0.3 `AIT_V0.3_FlowLine.spfx` 阶段，四个 Flow 场景各 30 次重复。
- [`docs/issue-9-validation.md`](../docs/issue-9-validation.md) 中的 `Issue9_PulseBaseline/Pulse75_S0` 属于 V0.5 `AIT_V0.5_PulseLine_QuotaInitFix.spfx` 阶段；75 架、45/30/0 配额、4 日脉动、S0、20 次重复。BASE 完工 Makespan 均值为 346.3431 日。
- V0.6 `Exp_B_Labor` 的 BASE B0 Makespan 均值为 316.342 日。该数与 V0.5 #9/#10 的约 346 日是不同模型阶段结果；差异分析和证据边界见 [`docs/issue-11-native-task-validation.md`](../docs/issue-11-native-task-validation.md)。

## 独立 CSV 的使用规则

将任何 CSV 单独复制或发布时，必须同时附上本索引或在数据包中写入等价的版本元数据。不能只凭文件名或数值推断模型版本。`responses_replications.csv` 是逐重复原始结果；摘要、图表和配对统计继承其所在目录的版本范围。
