# Simio Aerospace 模型交接说明

## 目标

模型用于比较 Pulse/Flow 释放、工位容量与缓冲、Task 原生用工策略、SA103 配额与双线分流、班次和人工成本。正式候选快照为 `models/AIT_V1.0_Final.spfx`，SHA-256 为 `3D23C7AF1CE40ADB1CC4A13752444A1D5E05E9356368A513CF503378CF1C9586`。

## 运行与结构

- 活动模型路径：`/Project/Model`。
- Simio 版本：20.297.56736.0。
- 两条五工位生产线由 `TN_Release` 和 Connector 路由；`Prop_Policy` 区分 Pulse/Flow，`Prop_NumLines` 控制单线/双线。
- Pulse 订单由 `Srv_P_Loc1..5` 和 `Srv_P_Work_1..5` 解耦处理，第 5 站后使用补工区逻辑。
- Flow 工位使用 Task Sequence、`Tbl_Tasks` 和容量/缓冲控制属性。

## 关键输入约束

模型属性、任务字段、责任工位和日程假设以 [`assumptions.md`](assumptions.md) 与 `AIT_issues/issues/02.md`、`03.md` 为准。模型快照、实验和结果之间的对应关系以 [`model-version-map.csv`](model-version-map.csv) 为准；不得混用不同快照的 BASE 结果。

## 已验证实验

- `Exp_A_Buffer`：V0.5 的 BASE、A1–A5 缓冲/容量比较。
- `Exp_B_Labor`：V0.6 的 B0–B4 Task 用工策略。
- `Exp_C_SA103`：V0.7 的 SA103 配额和单线/双线分流。
- `Exp_D_Shift`：V0.8 的班次、成本和付薪人时。
- `Issue14_WIP_TimeSeries`：V1.0 候选包的 A1/A3 24 小时 WIP 时间序列，两个场景各 10 次重复，结果可用且无运行错误。

## 维护步骤

1. 先在 GitHub Issue 中记录目标、假设、对象、控制属性和验收标准。
2. 从 `main` 建立功能分支；在本机 Simio 中修改并保存新的 `.spfx` 快照。
3. 记录 SHA-256、Experiment、Scenario、重复数和验证证据；模型文件通过 Git LFS 提交。
4. 完成 Simio 静态诊断、原生运行或 Experiment，并在保存后关闭、重载、再次核验。
5. 通过 Pull Request 和 `repository-checks` 后合并，随后更新 Issue、Milestone、Project、版本映射和 CHANGELOG。

## 当前限制

- 当前 MCP 活动模型诊断为 0 errors、无运行警告，`Issue14_WIP_TimeSeries` 结果可用；MCP 无法独立证明活动模型对应哪个磁盘文件，也无法替代用户在 Simio 中完成的关闭/重载操作。
- WIP Dashboard 运行视图曾正确显示 A1/A3 曲线，但 Edit 模式仍将部分内部筛选字段报告为 `Invalid column`；正式复核时应以 Experiment Results/Reports 和已保存的 WIP CSV 为数值依据，直到编辑器定义被修复或改用已验证的原生报告。
- `AIT_V1.0_Final.spfx` 已上传并登记，但尚未创建最终 `v1.0.0` Release；Release 前必须完成上述限制项的处理或明确接受其边界。
