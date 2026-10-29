# Issue #12 完成记录

## 目的与范围

本轮回答 100 架混合机队（SA101=45、SA102=30、SA103=25）在单线与双线条件下的产能问题。SA103 使用 SA101 的加工时间列。验收指标为：T1 平均相邻真实完工间隔 CT 不超过 3.5 日历日；T2 第 100 架真实完工不超过 316 日历日。两项指标分别判定。

## 模型改动

- 新增 `Prop_DispatchPolicy`：1=D1，双线 C1 按当前候选工位负荷选择；2=D2，SA101/SA102 固定到 L1、SA103 固定到 L2。`Prop_NumLines=1` 时始终选择 L1。
- 新增 NodeList `Lst_LineEntry`，包含 `Input@Srv_L1_C1`、`Input@Srv_L2_C1`。
- `TN_Release` 改为 `Select From List`，使用 `Smallest Value`、`Candidate.Node.AssociatedStationLoad` 和 `Select Available Only`。候选条件同时读取产线数、分流策略和 `ModelEntity.PlaneType`。
- `Tbl_Stations` 从 5 行扩展为 10 行，分别对应 `Srv_L1_C1..C5`、`Srv_L2_C1..C5`，并补齐 Line、ServerRef、MechList、CellID 字段说明。
- 历史实验中新增控制项的旧值 `0` 统一改为 `1`，避免旧场景保存无效的分流策略值。
- 新建 `Exp_C_SA103`，包含单线 24 个方案和双线 8 个方案；每个方案配置 5 次预验收重复。响应包括 CT、Makespan、T1/T2、WIP、流程时间、完成守恒、型号计数、产线完工量、每架人工小时和 Worker 利用率。

## 原生验证

活动模型为 `/Project/Model`，Simio `20.297.56736.0`。修改后静态诊断为 `0 errors`。三种路由烟测均完成 100 架：单线 L1=100/L2=0；D1 本次均衡为 L1=50/L2=50；D2 为 L1=75/L2=25。三种烟测的型号计数均为 45/30/25，最终 WIP=0，飞机守恒差额=0。

全矩阵预验收于 2026-10-27 09:12:05 完成：32 个有效方案、每方案 5 次、共 160 次。Simio 实验状态为 `completed`，无 `lastError`。逐重复数据在 `results/expC/issue12_expC_replications.csv`，汇总在 `results/expC/issue12_expC_summary.csv`，原始 MCP 返回（含 12 个 Worker 群体利用率响应）在 `validation/issue12-expC-raw-responses.json`，矩阵与 Wilson 95% 区间见 `results/expC/issue12_expC_validation.md`。

5 次重复显示：单线 S3 在 A4/A5 下本轮 5/5 同时满足 T1/T2；双线 D1+A4 在 S0/S1 下本轮 5/5 同时达标；D2+A4 在 S1 下本轮 5/5 达标，但 S0 未达标；D2+A1 两班均未达标。该样本只支持预验收和配置比较，不能替代大样本长期达标概率估计；Wilson 区间见结果表。

## 证据边界

MCP 已证明活动模型结构、原生运行结果和诊断。用户尚未另存本轮更改后的正式 `.spfx`，因此磁盘交付包边界仍待保存/重载复核；不能据此声称磁盘文件已包含新状态。
