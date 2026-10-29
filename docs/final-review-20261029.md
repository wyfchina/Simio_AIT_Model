# V1.0 最终复核记录

日期：2026-10-29  
复核对象：`models/AIT_V1.0_Final.spfx` 及活动模型 `/Project/Model`  
Simio：20.297.56736.0

## 已通过

- GitHub `main` 上存在 V1.0 Git LFS 指针，SHA-256 与本地保存文件一致：`3D23C7AF1CE40ADB1CC4A13752444A1D5E05E9356368A513CF503378CF1C9586`。
- MCP `get_active_model` 返回 `/Project/Model`；静态诊断为 0 errors。
- `get_run_status` 返回不在 Run Mode、无运行警告、dispatcher idle。
- `Issue14_WIP_TimeSeries` 状态为 idle，A1/A3 均为 10/10 次重复，结果可用且 `lastError=null`。
- 结果包含 `Tly_CT`、`Tly_FlowTime`、`Sts_WIP`、`Out_Makespan`、`Out_CT_SD` 和班次/成本统计项；WIP 结果含 24 小时 `Day###` 时间周期。
- 活动模型包含 10 个实验、6 个 Experiment Dashboard 和 3 个 Model Dashboard；V1.0 压缩包包含对应 Dashboard XML、Experiment 结果和 Table Report 文件。

## 未通过或不能独立证明

- 活动 MCP 没有返回磁盘文件路径，不能独立证明当前 `/Project/Model` 就是刚保存的 V1.0 文件；需要用户在 Simio 中关闭并重载 `AIT_V1.0_Final.spfx` 后再做一次同样的核对。
- `MyDashboard1` 的运行视图曾显示 WIP 曲线，但 Edit 模式仍记录 `DataSource`、`DataItem`、`StatisticType` 等 `Invalid column`；因此不能把 Dashboard 编辑定义宣布为完全通过。
- Issue #8 仍缺 Simio Trace 界面截图。
- 当前仓库还没有 `v1.0.0` GitHub Release；V1.0 快照目前是已保存候选交付包。

## 结论

模型结构、统计结果、实验结果和 GitHub 快照已形成可交接基线；最终冻结交付仍取决于关闭/重载核验、Dashboard Edit 定义处置、Trace 截图和 Release 创建。Issue #14 保持开放，直到这些证据完成或由维护者明确接受限制。
