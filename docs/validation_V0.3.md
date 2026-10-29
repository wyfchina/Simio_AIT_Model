# Issue #8 验证记录

检查日期：2026-10-24  
活动模型：`/Project/Model`  
Simio MCP：`http://localhost:51310`，活动模型已成功初始化并读取。

## 静态基准

- `Tbl_Tasks` 共 83 行，按工位为 19/20/19/20/5；任务校验脚本通过。
- 按 `Seq` 并行组取最大值、组间求和，关键路径为：
  - SA101：79.9333、102.5333、67.85、75.8801、6.4 h，合计 332.5967 h（四舍五入 332.6 h）。
  - SA102：65.45、100.7、70.3467、67.6667、6.4 h，合计 310.5634 h（四舍五入 310.6 h）。
- 最大并行机械师需求各工位为 7/7/7/8/5，均不超过每组 8 人。

## MCP 运行核验

### V1：通过（SA101；首轮单位错误已修正）

首轮临时运行使用 `Prop_Deterministic=True`、`Prop_NumPlanes=1`、`Prop_NumLines=1`、`Prop_Policy=2`、S0 日程，并以配额初始值 1/0 强制 SA101。五站均处理并放行 1 架，飞机到达 Sink；但各 Server 的 `TimeProcessing` 约为工作关键路径值的 1/60，Sink `TimeInSystem` 为 6.0433 h，证明首轮任务时间单位错误。用户随后将 `T101_Mean`、`T102_Mean` 列改为 `Time / Hours`；后续 Trace 复验已通过，见下文。

该运行同时暴露并修复了一个统计边界缺陷：单架飞机时 CT 样本数不足，样本标准差公式会除以零。`Prc_飞机完工统计` 的 `St_CTSDDays` 赋值现为：

`Math.If(St_CTIntervalCount>1,Math.Sqrt((St_CTSumSquaresDays-(St_CTSumDays*St_CTSumDays/St_CTIntervalCount))/(St_CTIntervalCount-1)),0)`

修复后静态诊断为 0，V1 运行错误消失。

时间换算修复尝试通过 MCP 更新十个 Server 的固定 `ProcessingTasks` 元组，但 `set_repeat_group_data` 对每个工位均拒绝操作，错误为 `RepeatGroup 'ProcessingTasks' does not allow tuple removal`；针对对象的 `set_property` 也不接受元组字段路径。

#### 单位调整后的初次统计复验

MCP 回读 `T101_Mean`、`T102_Mean` 的 `UnitType=Time`、`DefaultUnits=Hours`。Task Sequence 表达式仍按 `PlaneType` 直接引用 Mean 字段。再次单机运行后，五个工位的 `Total TimeProcessing` 与 `Average TimeInStation` 分别为 173.4333、213.0333、152.35、168.8801、14.9 h；各站进入/退出均为 1 架，Sink 完成 1 架。`Out_Makespan=30.1082` 日，`MySink1.TimeInSystem=722.5967` h，运行错误和警告均为 0。

MCP 回读两个 Mean 列单位为 `Time / Hours`。该次运行的各站 `Average TimeInStation` 与 `Total TimeProcessing` 相同，五站之和等于 Sink `TimeInSystem=722.5967 h`。这些是含工作日历暂停的日历驻留跨度，不能直接与 332.5967 h 的有效工作关键路径比较。仅凭这些 Server 汇总值不能判定任务是否并行；此前“实际工时等于各任务 Mean 总和、同 Seq 未并行”的推断已撤回。

#### 本次 Trace 复验

在已保存模型的 live 会话中临时设置为 `Prop_Deterministic=True`、`Prop_NumPlanes=1`、`Prop_NumLines=1`、SA101 配额 45/SA102 配额 0、`Prop_NumSA103=0`、`Wkr_InitialWorkSchedule=Sch_S0`。Trace 为 `Everything`，单架飞机 PlaneType=1；模型未保存。

- 五个工位分别记录到 19/20/19/20/5 项任务的开始与完成事件；每项任务的 Processing Delay 数值与 `Tbl_Tasks` 的 SA101 Mean 值一致。
- C1–C5 按 Seq 组取最长任务后得到有效工作时间 `79.9333 / 102.5333 / 67.85 / 75.8801 / 6.4 h`，合计 `332.5967 h`，与静态基准一致，V1 通过。
- 五个工位的每个 Seq 组内，各任务 Processing Delay 在同一仿真时刻开始；下一 Seq 在前一组最后一项任务完成的同一时刻开始。Trace 中可见同一组多项任务并发延迟，以及 `Suspending delay` / `Resuming delay` 日历暂停事件，V3 通过。
- 本次 run setup 从周一 `2026-10-26 00:00` 起算，工作人员到 `06:00` 才上班，最后完工时刻为 `2026-11-25 08:35:48`（仿真时间 728.5967 h，FlowTime/Makespan 30.3582 日）。按 Issue #8 指定的工作起点周一 `06:00` 计算，日历历时为 `722.5967 h = 30 日 2 小时 35 分 48 秒`，即约 `30.1082` 日；有效工作关键路径仍为 332.5967 h。两者差值来自 S0 排班下的非工作时段暂停。
- Trace 文件：[`AIT_V0.3_FlowLine_Model_trace.csv`](../AIT_V0.3_FlowLine_Model_trace.csv)，253,163 行，46,607,077 字节。Task/TaskState 导出日志仍无数据，本次 V3 证据来自原生 Trace。

### V2：通过（单架 SA102）

临时设置为确定性、单架、单线，配额初值 `RemainSA101=0`、`RemainSA102=30`、`RemainSA103=0`，工作日程 S0。Trace 确认只创建 1 架飞机，型号状态为 `PlaneType=2`，并在 C1–C5 分别执行了 19/20/19/20/5 项任务。

将 Trace 中每项 `[Delay] ProcessingTime` 的请求时长与对应工位 `Tbl_Tasks.T102_Mean` 全量比对，83 项全部匹配；按 `Seq` 分组取最大任务时长后得到：

| 工位 | 关键路径工作时间（h） | 基准（h） | 结果 |
|---|---:|---:|---|
| C1 | 65.4500 | 65.5 | 通过 |
| C2 | 100.7000 | 100.7 | 通过 |
| C3 | 70.3467 | 70.3 | 通过 |
| C4 | 67.6667 | 67.7 | 通过 |
| C5 | 6.4000 | 6.4 | 通过 |

各工位均在 ±0.1 h 内。Trace 中的 `TimeInStation` 是含非工作时段的日历驻留值，不作为工作时间判据。证据：[`V2_SA102_20261024_trace.csv`](../snapshots/V2_SA102_20261024_trace.csv)。

### V4：通过（复现 Issue #4 的 S3 测试项）

这里的“S3”是 Issue #4 表格中的第三个测试项“下班暂停”，不是命名周计划 `Sch_S3`。按该测试项要求，在正式模型中临时把 `C1-01` 的 SA101/SA102 均值设为 10 h，运行 1 架飞机，起点为周一 `2026-10-26 20:00`，Worker 日程使用两班五天计划 `Sch_S0`。Trace 显示任务在周一 20:00 开始、22:00 暂停（剩余 8 h）、周二 06:00 恢复、10:00 暂停（剩余 4 h）、10:30 恢复，并于周二 **14:30** 完成，符合判据。

此前使用命名日程 `Sch_S3` 得到周二 06:50 完成，不能据此判定暂停机制失败：`Sch_S3` 是三班七天计划，夜班跨午夜排到 02:00；22:00 仍属工作时段。该次结果符合 `Sch_S3` 日历，但并非 Issue #4 的两班 S3 测试条件。正式 Server 为 Fixed 容量，暂停行为由 Worker 日程触发。本次临时均值、运行参数均已恢复，模型未保存。证据：[`V4_Sch_S0_20261024_trace.csv`](../snapshots/V4_Sch_S0_20261024_trace.csv)。

### V5：通过近似基准核验（75 架、情形①、确定性）

本轮重新设置 `Prop_Deterministic=True`、`Prop_NumPlanes=75`、`Prop_NumLines=1`、`Prop_Policy=2`、`Prop_CellCap=1`、`Prop_Buffer=0`、`Wkr_InitialWorkSchedule=Sch_S0`，从周一 `2026-10-26 06:00` 运行。Simio 原生统计得到 `Tly_CT` 74 个完工间隔，平均 **9.4882 日历日**（标准差 1.0965 日，最小 8.2076、最大 11.4688），接近约 9.5 日历日目标；工位 2 Worker 群体（8 人编制）的 `Percent ScheduledUtilization=38.6287%`，在 39.8% ±3 个百分点范围内。

用 S0 每周 75 个排班小时折算日历平均值：`9.4882 × 24 × 75 / 168 = 101.6593`，约 **101.66 有效工作小时**，与解析基准 **101.8 h** 相差 0.14 h（约 0.14%）。该换算是对平均日历 CT 按周排班率的近似折算；模型未输出逐架 CT 完工时刻/逐间隔排班工时，Task、TallyObservation 等日志也没有逐条记录，因此不能声称这是逐样本累计得到的精确工作小时。按 Issue #8 的近似 CT 判据和利用率容差，V5 数值核验通过；精确工作小时响应仍未单独采集。

### V6：通过（75 架运行的守恒检查）

本轮 V5 同一次运行结束时，统计显示 `Population.NumberCreated=75`、`Population.NumberDestroyed=75`、`Population.NumberInSystem=0`；Runtime 显示 `St_WIP=0`、`St_CompletedCount=75`、`SeizedResources=0`。因此投放数=完工数，结束 WIP 为 0，机械师没有剩余已分配资源。

### V3：通过

见上方单架 SA101 Trace 复验。五站所有 Seq 组均按预期并行启动，并在前一组全部结束后启动下一组。

### V7：通过（只读核验）

未重置既有 `Issue5_Validation` 实验。5 个活动场景均为 30/30 次：四个 75 架场景逐次得到 SA101/SA102/SA103 = 45/30/0；100 架场景逐次得到 45/30/25。每个响应均为 30 个有效观测，最小值、最大值和平均值均与配额一致。

## 恢复状态

Trace 和运行临时设置已恢复到已保存模型基线：`Prop_Deterministic=False`、`Prop_NumPlanes=75`、`Prop_NumLines=2`、`Prop_Policy=2`、`Prop_NumSA103=0`、`Prop_CellCap=2`、`Prop_Buffer=0`、`Prop_LaborPolicy=1`、`Prop_Shift=0`、`Wkr_InitialWorkSchedule=Sch_S0`；`RemainSA101/102` 初始值为 45/30。`Tbl_Tasks.C1-01.T101_Mean/T102_Mean` 均恢复为 2.2 h。Trace 已关闭；原 `AIT_V0.3_FlowLine_Model_trace.csv` 已恢复，V4 新证据另存为 `snapshots/V4_Sch_S0_20261024_trace.csv`。运行设置恢复为 2026-10-26 00:00 至 2033-04-04，`RunEndType=EndingTime`。模型已退出 Run Mode，静态诊断 0 errors，运行警告 0。

## 交付结论

截至 2026-10-25，V1–V7 的验证结果均通过：V1、V2、V3、V4、V6、V7 按各自判据通过；V5 按 Issue #8 的近似 CT 判据及利用率容差通过。V5 的 101.66 小时由平均日历 CT 按 S0 每周 75/168 的排班比例折算，符合用户确认的验收口径，不作为逐个 CT 区间直接累计值。

用户确认 `St_CTSDDays` 的单样本边界修复已保存，并已将模型另存为 `AIT_V0.4_Validated.spfx`。已在项目交付目录确认该文件存在（6,975,974 字节，最后修改时间 2026-10-25 06:02）；本记录不据此声称已独立关闭并重载该快照复核其内部内容。

Issue #8 当前仅剩原生 Simio Trace 界面截图待补。项目已有 V1、V2、V4 Trace CSV 和 V1/V3 的运行记录，但 CSV 不能替代要求的 Simio Trace 界面截图。2026-10-25 尝试通过 Computer Use 激活 Simio 并截图时，审批服务 `https://wagong.m1eepo.de/responses` 返回 `503 Service Unavailable`，操作未执行；Simio MCP 仍能连接，活动模型为 `/Project/Model`，但 MCP Trace 状态为关闭且没有可用 Trace CSV，无法从 MCP 直接截取原生界面。请求 ID：`3447da42-6b68-4aea-bff3-a0d484510b4d`、`a895adfe-5743-402f-b363-b9a6c4f3e843`、`494b20ef-7536-449f-a4bd-9fa4ca31f644`。

因此，除 Trace 截图这一项外，Issue #8 的验证与快照交付项已完成。待审批服务恢复后补齐 V1–V4 截图并核对截图与本记录中的时间、工位和任务事件，即可完成 #8 的最终证据闭环。
