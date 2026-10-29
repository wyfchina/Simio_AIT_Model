# Issue #7 统计框架验收记录

检查日期：2026-10-24  
目标模型：`/Project/Model`  
Simio 版本：20.297.56736.0

## 本轮已完成

- 新增模型状态：`St_WIP`、`St_MaxWIP`、`St_LastDoneTime`、`St_CompletedCount`、`St_MakespanDays`。
- 新增统计元素：`Sts_WIP`（StateStatistic）、`Tly_CT`、`Tly_FlowTime`（TallyStatistic）、`Out_Makespan`（OutputStatistic）。
- `Sts_WIP` 绑定 `St_WIP`，统计范围定义为进入两条生产线 C1 输入节点至进入 Sink 完工节点，排除线外投放池；停止条件为 `St_CompletedCount>=Prop_NumPlanes && St_WIP==0`。
- 新增 `Prc_C1入站WIP_L1` 和 `Prc_C1入站WIP_L2`，分别绑定 `Input@Srv_L1_C1.Entered`、`Input@Srv_L2_C1.Entered`，将 `St_WIP` 加 1，并在需要时更新 `St_MaxWIP`。
- 新增 `Prc_飞机完工统计`，绑定 `MySink1.Entered`：记录单机流程时间；首架完工不记录 CT；更新最近完工时刻和累计完工数；完工时将 WIP 减 1；达到计划数时登记 Makespan。
- `Tly_CT` 和 `Tly_FlowTime` 的观测表达式按仿真小时除以 24，报告单位为日；`Out_Makespan` 表达式为 `St_MakespanDays`。
- MCP 回读静态诊断：0 errors。三个新过程和三个事件绑定均可回读。

## 原生运行结果（2026-10-24）

使用当前 `Prop_NumPlanes=75`、336 小时运行窗口执行 FastForward：

- `MySource1` 创建并输出 75 架；`MySink1` 输入并完工 75 架。
- `Sts_WIP`：平均 54.1178，最大 91，最终值 0。
- `Out_Makespan`：2.6476 日。
- 静态诊断 0 errors，运行警告 0。
- 守恒检查通过：投放 75 = 完工 75 + 结束 WIP 0。

首次运行时 `Tly_CT` 产生 149 个观测，原因已定位为过程 XML 中同时存在 `TriggeringEventName` 和对象 `Entered` 属性绑定，导致 Add-On 过程重复触发。清空三个过程 XML 内的 `TriggeringEventName` 后复跑，`Tly_CT` 恢复为 74 个观测，符合 75 架飞机的理论值。初版流程时间表达式引用了无效的 `ModelEntity.Cell1EnterTime`，未产生 Tally 行；现改用 Sink 的 `ModelEntity.TimeInSystem` 后复跑，`Tly_FlowTime` 得到 75 个观测，最小 0.4939 日、最大 2.6476 日、平均 1.5056 日。同期 `Sts_WIP` 最终值 0、峰值 16、平均 11.4676；`Out_Makespan` 为 2.6476 日。

## 尚未证实

- 本轮 MCP 的 `run_model_plan`、`get_run_setup` 返回内部错误，未能启动原生运行。因此尚未取得 WIP 时间平均值、峰值、CT 均值/标准差、流程时间和 Makespan 的运行结果。
- 尚未在 Experiment `Issue5_Validation` 中新增 Issue #7 Responses。
- 尚未通过 MCP 创建或回读 Facility 的 Status Pie 与 WIP Time Plot。
- 机械师利用率、各工位 Blocked/Starved 比例、Little 定律误差和投放/完工/WIP 守恒仍需运行后核验。

## 运行后核验清单

1. 用 `Prop_Policy=2`、`Prop_NumLines=2`，分别运行四种 `Prop_CellCap`/`Prop_Buffer` 组合。
2. 核对 `Source.NumberCreated = Sink.NumberDestroyed + St_WIP`，结束时 `St_WIP=0`。
3. 核对 `Sts_WIP` 的平均值与 `Tly_FlowTime`、完工率的 Little 定律误差小于 2%。
4. 将 `Tly_CT` 平均值/标准差、`Out_Makespan`、平均/最大 WIP、利用率、阻塞率、饥饿率和平均流程时间加入 Experiment Responses。

## 版本边界

修改前快照：`snapshots/AIT_V0.2_Skeleton_Issue5DescriptionCleanup_20261024_PreIssue7_20261024_174101.spfx`  
源文件与快照 SHA256：`875220A6923D68E81C71F54F409B69EF165B37600F998CA676DA7770A2BAE305`

本记录反映 MCP live 模型的当前定义；用户仍需在 Simio 中保存另一个 Issue #7 候选 `.spfx`，再重载并运行复核。

## 本轮指标定义与验收结果：2026-10-24

本节取代上文“尚未证实”及“运行后核验清单”的状态。目标为 MCP 活动模型 `/Project/Model` 的 `Issue7_FlowValidation` 实验；四场景 `Cap1_Buf0`、`Cap1_Buf1`、`Cap1_BufInf`、`Cap2_Buf0` 均为 `Prop_Policy=2`、双线、75 架、30 次重复，共 120 次。

### 指标口径

- **CT**：相邻完工飞机之间的时间间隔，首架完工不产生 CT 观测。`Tly_CT` 以日为单位；每次重复有 74 个 CT 观测。响应分别导出该重复的 CT 均值和样本标准差。
- **Makespan**：记录 `St_CompletedCount` 达到 `Prop_NumPlanes` 时的模型状态 `St_MakespanDays`，单位为日。
- **线内 WIP**：从飞机进入两条线任一 C1 起，到进入 Sink 完工止；排除进入 C1 之前的投放池等待。`Sts_WIP` 提供时间平均值和最大值，末值通过 `St_WIP` 检查。
- **线内 FlowTime**：飞机进入 C1 至进入 Sink 的时长，单位为日；每次重复 75 个观测。Simio 原生 `Ent_Plane.TimeInSystem` 是从 Source 创建到 Sink，包含线外等待，不作为本处线内 FlowTime 或 Little 定律输入。
- **Worker 利用率**：每个 Worker 群体的 `Population.Capacity.ScheduledUtilization`，即忙碌量相对排班可用能力的利用率；十个工位各有响应，另提供线 1、线 2 和全线十工位等权算术平均。每群体均为 8 人且采用同一实验日程，故等权平均与按人数加权一致。
- **Blocked / Starved**：每工位 Server 的 `ResourceState.PercentTime(2)` / `ResourceState.PercentTime(0)`，分母为该工位仿真日历总时长；与 Simio 原生 `TimeBlocked.Percent` / `TimeStarved.Percent` 对照，样例数值相同。每工位分别导出响应。
- **Little 定律误差**：`100*Math.Abs(Sts_WIP.Average-Tly_FlowTime.Average*St_CompletedCount/St_MakespanDays)/Sts_WIP.Average`。WIP 与 FlowTime 都以 C1 入站为系统边界，吞吐率由同一批次完成数量除以该边界的运行时长计算；验收阈值小于 2%。
- **守恒**：每次重复核对 `Created − Destroyed − FinalWIP=0`，目标为 75 架创建、75 架完工、结束 WIP 0。

### 实验统计

| 场景 | CT均值（日） | CT样本标准差（日） | Makespan（日） | 平均WIP（架） | 最大WIP均值（架） | 平均线内FlowTime（日） | 全线Worker排班利用率均值 | Little误差均值 | 守恒 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| `Cap1_Buf0` | 0.0647 | 0.1260 | 5.2802 | 5.7323 | 8.00 | 0.3941 | 23.70% | 约 0% | 30/30通过 |
| `Cap1_Buf1` | 0.0647 | 0.1260 | 5.2802 | 7.2245 | 10.00 | 0.4959 | 23.70% | 约 0% | 30/30通过 |
| `Cap1_BufInf` | 0.0647 | 0.1260 | 5.2802 | 13.6368 | 25.43 | 0.9352 | 23.70% | 约 0% | 30/30通过 |
| `Cap2_Buf0` | 0.0296 | 0.0629 | 2.6871 | 11.1645 | 16.00 | 0.3986 | 43.46% | 约 0% | 30/30通过 |

四场景所有 Blocked/Starved 响应均返回 30 个观测（80/80 项有效），值域分别为 0–24.84% 和 13.73–96.52%；容量无限缓冲场景中没有 Blocked 时间，Simio 对零值状态可能不返回原生汇总行，但对应 Experiment Response 仍得到 30 个有效 0 值观测。Little 误差在各次重复均小于 `2×10^-13%`。静态诊断 0 errors；实验状态 `completed`、`lastError=null`。

**更新后的结论：**利用率、Blocked、Starved、Little 定律及实体守恒的定义和统计口径已经明确；44 个 Experiment Responses 已配置，四个场景均成功导出 30 次重复观测。#7 的 live 模型统计与实验验收完成。最近 live 修改尚未由 MCP 保存；用户保存 `.spfx` 后仍应重载并确认这些统计和图形随正式包保留。
