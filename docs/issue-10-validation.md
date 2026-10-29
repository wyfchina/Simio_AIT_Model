# Issue #10 验收记录

检查日期：2026-10-25  
活动模型：`/Project/Model`，Simio `20.297.56736.0`  
实验：`Exp_A_Buffer`  
运行方式：Simio MCP 原生 Experiment，6 个活动场景 × 10 次重复；第二轮增加 Processing 状态响应后重置并重跑，以下数据来自第二轮完整结果。

## 实验设置

所有场景固定 `Prop_NumPlanes=75`、`Prop_NumSA103=0`、`Prop_PulseDays=4`、`Prop_LaborPolicy=1`、`Prop_Shift=0`、`Prop_NumLines=1`、`Prop_Deterministic=False`、`Wkr_InitialWorkSchedule=Sch_S0`。`Scenario1` 是原有空白默认场景，已停用；只运行 BASE 与 A1–A5。

| 场景 | Policy | CellCap | Buffer | 重复数 |
|---|---:|---:|---:|---:|
| BASE | 1（Pulse） | 1 | 0 | 10 |
| A1 | 2（Flow） | 1 | 0 | 10 |
| A2 | 2（Flow） | 1 | 1 | 10 |
| A3 | 2（Flow） | 1 | Infinity | 10 |
| A4 | 2（Flow） | 2 | 0 | 10 |
| A5（加做） | 2（Flow） | 2 | 1 | 10 |

Experiment 使用 95% 置信水平，主要响应为 `Resp_Makespan_Days`。Simio MCP 未暴露独立的随机种子/CRN 开关；观测到 A1、A2、A3 的 10 个 Makespan 和 CT 均逐重复完全一致，说明这些等容量场景实际使用了配对一致的随机结果。跨容量场景仍采用相同 replication 序号进行配对分析，但 MCP 没有可独立核验的显式种子配置，因此不把 CRN 配置声明为已独立证明。

## 核心结果

CT、Makespan、WIP、最大 WIP 和平均 FlowTime 的单位均为日或架，响应是 10 次重复的均值。BASE 的最后四项 Flow 专用指标不适用，详见后文。

| 场景 | CT（日） | CT 单次样本 SD 的重复均值（日） | Makespan（日） | 平均 WIP（架） | 平均最大 WIP（架） | 平均 FlowTime（日） |
|---|---:|---:|---:|---:|---:|---:|
| BASE | 4.3987 | 4.1100 | 346.1703 | 不适用 | 不适用 | 不适用 |
| A1 | 9.4894 | 1.0710 | 731.6626 | 3.36 | 4.00 | 32.76 |
| A2 | 9.4894 | 1.0710 | 731.6626 | 4.29 | 5.00 | 41.83 |
| A3 | 9.4894 | 1.0710 | 731.6626 | 12.95 | 24.00 | 126.37 |
| A4 | 4.8608 | 3.7700 | 389.4457 | 6.59 | 8.00 | 34.21 |
| A5 | 4.8745 | 3.9200 | 390.4573 | 7.45 | 9.00 | 38.79 |

CT 与 Makespan 的 95% CI 半宽均满足“≤均值的 2%”：各场景相对半宽范围分别为 `0.048%–0.389%` 和 `0.055%–0.386%`，因此 10 次重复达到预设精度，不需增加到 20 次。

## 假设对照

- BASE 平均真实 Makespan 为 `346.1703` 日，与 #9 的 75 架基准均值 `346.3431` 日相差约 `0.05%`。名义 316 日是最后一架离开位置线的时点，不是最后工单完成时间；约 30 日的补工尾巴与 #9 的结果一致。
- A1–A3 的 CT `9.4894` 日、Makespan `731.6626` 日，均与解析估计约 9.5 日、约 730 日相符。A2 的 WIP 比 A1 高约 0.93 架，产出没有变化，符合缓冲主要增加在制品的预期。
- A3 的平均线内 WIP 为 `12.95`、平均最大 WIP 为 `24`，而 Makespan 和 CT 与 A1/A2 完全相同；无限缓冲没有提升产出。当前响应没有单独记录“仿真结束时工位 2 前队列长度”，因此平均最大 WIP 不能直接等同于预期所说的期末积压约 20 架。
- A4 的 Makespan `389.4457` 日，比预期区间下界 400 日低约 `2.64%`；差异未超过 15% 调查阈值。该估计区间是粗略解析范围，不构成硬性失败。A5 是加做情形，Makespan `390.4573` 日，较 A4 多约 `1.01` 日（`0.26%`）。
- 没有核心 CT/Makespan 预期偏差超过 15%。

## Makespan 配对检验

对六个场景的全部 15 组两两比较，按 replication 编号配对，使用双侧 95% 配对 t 区间（`n=10`，自由度 9，临界值 2.262）。正差定义为表中 A 减 B。A1/A2/A3 的逐重复结果完全相同，差值为零。

| 比较（A−B） | 平均差（日） | 配对 95% CI（日） | 未校正结论 |
|---|---:|---:|---|
| BASE−A1 / A2 / A3 | −385.49 | [−386.75, −384.23] | 有差异 |
| BASE−A4 | −43.28 | [−44.72, −41.83] | 有差异 |
| BASE−A5 | −44.29 | [−45.95, −42.62] | 有差异 |
| A1−A2 / A1−A3 / A2−A3 | 0.00 | [0.00, 0.00] | 观测完全一致 |
| A1 / A2 / A3−A4 | 342.22 | [341.58, 342.85] | 有差异 |
| A1 / A2 / A3−A5 | 341.21 | [340.10, 342.31] | 有差异 |
| A4−A5 | −1.01 | [−1.86, −0.17] | 未校正时有差异 |

这 15 项是探索性多重比较，表内区间未作家族错误率校正。按 Bonferroni 校正，A4 与 A5 的小差异不再显著；其余量级较大的方案差异仍显著。详细每组数值见 `results/expA/makespan_paired_comparisons.csv`。

## 工位状态与守恒

各工位 Processing 使用 `Srv_L1_C#.ResourceState.PercentTime(1)`，Blocked 使用状态 2，Starved 使用状态 0。A1–A5 的五工位三类状态比例按日历时间计算，每工位三项之和为 100%（浮点误差范围内）。图表数据见 `station_state_stack.csv` 和 `station_state_stacked.svg`。工人排班利用率单独保留在响应表中；它以排班可用人时为分母，不能和日历状态比例混为同一堆叠。

A1–A5 的每个重复均创建 75 架、销毁 75 架、结束 `St_WIP=0`，守恒差额为 0。BASE 也创建/销毁 75 架，但 `St_WIP=-75`、守恒差额为 75，因此不能通过这套 Flow 线内守恒响应。

### BASE 指标边界缺陷

`St_WIP` 只在 `Srv_L1_C1` 的 Entered 触发中增加，Sink 完工时统一减少。Pulse 实际使用 `Srv_P_Loc*` 位置站和 `Srv_P_Work_*` 虚拟工位，不经过 Flow 线的 C1 入站计数；因此 BASE 的 `St_WIP` 变为 `-75`，其平均/最大 WIP、线内 FlowTime、Little 定律误差及 FinalWIP/守恒响应全都失真。BASE 的 CT、Makespan、创建数、完工数仍有效。原始 CSV 保留 Simio 返回值以便追踪，BASE 不适用的 Flow 指标在本报告中标为“不适用”。后续若要比较 BASE 的 WIP，需要另建跨 Pulse/Flow 统一边界的系统 WIP 统计，不能复用当前 C1 入站口径。

## 图表与文件

- `makespan_smore.svg`：以 10 次重复 Makespan 绘制的箱线分布图（含最小/最大值、中位数、均值），是从实验重复数据生成的 SMORE 风格图，不是 Simio 界面原生 SMORE 截图。
- `station_state_stacked.svg`：A1–A5、五工位 Processing / Blocked / Starved 日历时间堆叠图。
- `responses_summary.csv`：26 个基础响应加 5 个 Processing 响应的场景统计、半宽和有效性。
- `responses_replications.csv`：每个响应逐场景、逐重复原始观测。
- `scenario_comparison.csv`：用于场景横向比较的精简表；BASE 的 Flow 专用字段留空，避免误读原始无效响应。
- `station_state_stack.csv`：状态图对应的场景均值。
- `makespan_paired_comparisons.csv`：15 组配对 t 检验差值与区间。

用户已保存正式 `.spfx`。只读检查确认磁盘包包含 `Exp_A_Buffer` 定义和结果文件，六个场景的 31 个响应系列均各有 10 次观测；MCP 活动模型读取到的配置及 Makespan、CT、WIP 结果与导出 CSV 相符。当前 Experiment 状态为 idle、结果可用；诊断 `0 errors`、无运行警告，模型不在 Run Mode。MCP 不暴露当前模型对应的磁盘路径或加载历史，因此可以确认保存包内容与活动模型一致，但不能独立证明关闭后重新打开这一操作。
