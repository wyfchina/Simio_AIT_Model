# Issue #11 原生 Task 用工策略验收

本记录对应活动模型 `/Project/Model`，Simio Desktop Interactive MCP，版本 `20.297.56736.0`。记录使用中文，模型属性名称使用英文。磁盘基线为 `AIT_V0.6_LaborFlex_C1PolicyPilot.spfx`；本轮修改先作用于活动模型，最终磁盘包须在用户保存并重载后复核。

## 已实现的资源机制

15 个正式作业 Server 共用原生 Task Sequence：线1五站、线2五站、Pulse五个虚拟作业站。工艺任务仍读取 `Tbl_Tasks`；责任工位仍为 `OwnerCell`，飞机位置仍为 `CurLoc`。设施对象与已有布局保留。

固定资源关系表为 `Tbl_Tasks_Labor` 和 `Tbl_Tasks_Labor_L2`。每张表有 415 行，即83个任务各有五条策略资源要求；各行 `MechList` 都是已定义名单的原生 `ListName(Object)` 引用。`PolicyCode` 为1至5，`RequiredWorkers` 为 **Expression数值列**：

```text
Math.If(Prop_LaborPolicy==本行策略编号,Tbl_Tasks.Mechanics,0)
```

Task 的 `Number Of Resources` 读取该数值列，`Units Per Resource=1`，`Must Simultaneously Seize=True`，`Selection Goal=Preferred Order`，`Off Shift Rule=Suspend Processing`。原生 Task 负责占用和释放。策略切换只需在运行前改变 `Prop_LaborPolicy`，不再修改表格、Server内部列引用或外层选表属性。

| 属性值 | 策略 | 名单和人数 |
|---:|---|---|
| 1 | B0 专属 | 每站8人，`Lst_Home_C1..C5` |
| 2 | B1 全池 | 本线40人，`Lst_All_L1`；线2使用`Lst_All_L2` |
| 3 | B2 相邻 | 每站8人；`Lst_Adj_C1..C5`，本站在前、相邻在后 |
| 4 | B3 机动 | 每站6人，机动10人；`Lst_Float_C1..C5`，本站在前 |
| 5 | B4 重配 | C1至C5为8/10/8/9/5人，使用本站专属名单 |

线2使用已经定义的 `Lst_Home_L2_C1..C5`、`Lst_Adj_L2_C1..C5` 和 `Lst_Float_L2_C1..C5`。任何策略每条线均为40人。

`Prop_WorkersC1..C5`、`Prop_WorkersFloat` 为六个 Expression 属性。Worker 的 Integer 类型 `Initial Number In System` 引用这些属性，仿真初始化时计算人数。原生运行已证明该引用方式可以读取计算结果；Worker群体无需增员Source。所有群体，包括机动组，使用 `Wkr_InitialWorkSchedule`。

旧的12个 `Src_Init_Wkr_*`、`Prc_LaborPolicyAcquire_C1` 和 `Prc_LaborPolicyRelease_C1` 已清除，Task回调也已解除。Pulse原有 `Prc_Pulse_TaskFinishedStats` 保留。用户建立的五张B0–B4参照表保留，但正式模板不再引用它们；`Prop_TasksLabor_L1/L2` 已注明为历史属性。

## 原生机制验收

C1独立试验中，五种策略均完成两架飞机、每架19个C1任务；每次38个任务资源分配、98条Worker占用记录。逐任务检查不同Worker数量、同一占用起点和全部释放；包含同时占用3名Worker的任务。

| 策略 | 实际资源名单 | 实际使用的Worker群体及占用次数 |
|---|---|---|
| B0 | Lst_Home_C1 | C1：98 |
| B1 | Lst_All_L1 | C1：74；C2：24 |
| B2 | Lst_Adj_C1 | C1：74；C2：24 |
| B3 | Lst_Float_C1 | C1：60；Float：38 |
| B4 | Lst_Home_C1 | C1：98；初始化人数同时核对为8/10/8/9/5 |

证据：`validation/issue11-native-zero-proof.json`，以及五份 `issue11-native-zero-B*.json` 的原生 ResourceUsage、ResourceInfo 和统计数据。临时测试对象已移除。

整线已完成A1/A4/BASE分别切换B0–B4的15种确定性组合，并补充A4双线的B1/B3/B4，共18种组合。A1每例2架、166个任务；A4每例4架、332个任务；BASE每例3架、249个任务和15个工作订单。全部满足实际人数、有效名单、同时占用、释放、飞机完工和工作订单守恒；警告为0。线1与线2分别核对40人。证据为 `validation/issue11-native-matrix-*-summary.json` 和对应原始JSON。

## 统计与随机流

Pulse制造WIP在物理第一站实际开始处理时加1，在真实完工Sink减1；Flow仍在C1入站加1。两种模式的流程时间均由 `Cell1EnterTime` 起算，含Pulse补工区，排除投放池。WIP归零且全部飞机完成后，现有统计停止条件结束批次。`Src_Pulse` 的投放间隔明确写成 `Prop_PulseDays*24` Hours。

正式任务时间读取 `Prop_Deterministic`：True读取对应型号均值；False读取对应三角分布。`Tbl_Tasks.TaskStream` 保存1至83的稳定任务偏移；工时随机流号为：

```text
1000+100*ModelEntity.PlaneID+Tbl_Tasks.TaskStream
```

Pulse工作订单复制所属飞机的PlaneID。每架每任务只执行一次该采样，随机流与执行顺序分离；型号顺序使用已有独立流101。同次重复的各策略同时核对双型号顺序摘要，以验证共同输入。该流号构造适用于当前最多100架、83任务的模型范围。

本轮增加人数属性时，既有18个场景曾得到默认0值；已把这些新增控制项修正为相应人数公式，其余历史控制值保持不变。既有实验的历史结果未冒充为本轮模型结果。

## 正式实验与交付边界

`Exp_B_Labor` 包含 `{A1,A4,BASE}×{B0..B4}`，75架、45/30/0型号配额、单线、S0、缓冲0，A1容量1、A4容量2、BASE每4个日历日脉动。正式场景使用 `Prop_Deterministic=False`；先每场景10次重复，再依据CT/Makespan的95%置信区间精度确定是否追加。

Responses包括CT均值与标准差、Makespan、平均/最大WIP、平均流程时间、各Worker群体计划利用率、飞机/订单/任务守恒、每线40人、型号计数和双顺序摘要，以及Little定律误差。BASE另含逾期任务比例、近似逾期人时和离线未完工比例。

利用率是Worker群体忙时除以排班容量时，分母随批次真实排空结束；跨站支援时群体利用率不能解释成责任工位任务专属利用率。既有 `St_LateLaborHoursApprox` 是人数乘以超期日历小时的上界代理，包含非工作时间，不能称为精确实际带走人时。

## 正式实验结果

`Exp_B_Labor` 已完成15个场景、每场景10次重复，共150次；实验状态为 completed，运行错误为空。所有CT和Makespan响应的95%置信区间半宽均小于均值的2%，最大相对半宽约0.477%，因此10次重复已达到本轮精度门槛，不追加重复。

| 场景 | B0 Makespan/CT | B1 | B2 | B3 | B4 |
|---|---:|---:|---:|---:|---:|
| A1 Makespan（日） | 731.461 / 9.488 | 731.461 / 9.488 | 731.461 / 9.488 | 731.461 / 9.488 | 731.461 / 9.488 |
| A4 Makespan（日） | 390.766 / 4.879 | 379.543 / 4.740 | 380.118 / 4.748 | 380.191 / 4.748 | 380.742 / 4.748 |
| BASE Makespan（日） | 316.342 / 3.995 | 316.000 / 3.991 | 316.000 / 3.991 | 316.000 / 3.989 | 316.000 / 3.991 |

A1 五种策略结果完全一致，符合容量为1时没有同线人力争用收益的前提。A4 中 B1 达到全池上界；B2 获得其 Makespan 改善的94.9%，B3为94.2%，B4为89.3%。BASE 的名义完工时间均约316天；灵活策略主要改善带走工作和离线未完工比例，而不是名义Makespan：B0/B1/B2/B3/B4 的近似逾期人时约为 716,986 / 311,799 / 318,801 / 347,242 / 375,833 人时，离线未完工比例约为 87.9% / 17.1% / 15.6% / 22.3% / 23.1%。这些人时是已说明的保守代理，不是精确行走人时。

基于目标权衡，建议把 **B2** 作为落地方案：A4 获得全池上界约94.9%的Makespan改善，BASE离线未完工比例最低（15.6%），且不需要机动组。若只追求A4最短Makespan，选B1；若必须保留机动池，B3是可行折中，但其BASE逾期人时高于B1/B2。B4无需跨站借调，性能接近上界但BASE尾部指标弱于B2。

每条线的飞机、任务和Worker资源守恒检查全部通过；Little定律相对误差均小于2%，双型号顺序摘要在同一重复的15个场景之间一致，公共随机数条件成立。活动模型当前已停止，诊断为0 errors、0 warnings。

结果文件：`results/expB/responses_summary.csv`、`results/expB/responses_replications.csv`、`results/expB/gains.csv`；完整原生证据为 `validation/issue11-native-final-experiment-results.json` 和 `validation/issue11-native-final-checks.json`。

本轮修改仍在活动模型中，未由MCP覆盖用户磁盘文件。交付前请将当前活动模型另存为新的Issue #11版本，关闭后重新打开，再核对 `/Project/Model`、`Exp_B_Labor`、诊断和停止状态。
