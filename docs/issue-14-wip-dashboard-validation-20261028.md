# Issue #14：`St_WIP` 时间序列展示验证记录

日期：2026-10-28  
验证接口：本机 Simio Desktop Interactive MCP（`http://localhost:51310`）  
活动模型：`/Project/Model`  
Simio 版本：20.297.56736.0

## 1. 本轮完成内容

- 在 `Per_WIP` 上确认 `State Statistic Name = Sts_WIP`。
- 确认周期配置为从 `RunStart` 起、每个周期 24 小时、最多 800 个周期、周期名前缀 `Day`，并启用原始统计记录。
- 使用独立实验 `Issue14_WIP_TimeSeries`，未改写旧实验 `Exp_A_Buffer`。
- 实验包含两个活动场景：
  - `A1`：完工驱动、单线、容量 1、缓冲 0、S0；
  - `A3`：完工驱动、单线、容量 1、无限缓冲、S0。
- 两个场景均已完成 10/10 次重复，实验状态为 `completed`，无运行错误。
- 在实验 Dashboard `MyDashboard1` 中配置了两张原生折线图：
  1. `制造WIP日均：A1与A3（尾段有效重复数递减）`：显示 `Sts_WIP` 每日时间加权平均值；
  2. `每日有效重复数`：显示同一筛选条件下每个日期实际参与统计的重复数。

## 2. Dashboard 绑定口径

`St_WIP` 表示制造系统内的当前飞机数（架）：Flow 在飞机进入 C1 时计入，Pulse 在飞机于物理第一工位实际开始加工时计入；飞机到真实完工 Sink 时减计。该口径包括 Pulse 补工区，不包括投放池、第一工位输入等待队列和工作订单。因此图展示的是制造 WIP，不是尚未投放的订单数或全厂所有等待实体数。

两张图均使用 Simio 原生 `Experiment Statistic Details` 数据源，筛选条件为：

```text
[DataSource] = 'Sts_WIP'
[DataItem] = 'StateValue'
[StatisticType] = 'Average'
[ScenarioName] = 'A1' 或 'A3'
[TimePeriod] <> ''
```

过滤表达式使用数据源的成员名，不使用界面显示标签（如 `Data Source`、`Data Item`、`Statistic`、`Scenario`、`Time Period`）。其中 `Statistic` 的内部成员名是 `StatisticType`。

第一张图的字段为：

- 横轴：`TimePeriod`，按升序排列；
- 纵轴：`Value` 的平均值；
- 系列维度：`ScenarioDisplayName`；
- 横轴标题：`仿真日（自RunStart起）`；
- 纵轴标题：`日内时间加权平均制造WIP（架）`。

第二张图以 A1 为代表，使用相同的日期维度，纵轴对 `Value` 计数，标题为 `每日有效重复数（A1与A3一致）`。MCP 导出的 A1/A3 每日有效重复数逐日一致，因此用一条线显示即可；它用于识别排空尾段的有效样本数量，避免把只剩少数重复的日均值误当成完整 10 次重复的结果。

## 3. MCP 原始结果复核

实验结果明细通过 MCP 分页完整读取：

- `A1`：36,640 条明细；
- `A3`：36,680 条明细；
- 每个场景的 `Sts_WIP / StateValue / Average` 日记录均为 7,310 条：前 728 个日周期各有 10 次重复，随后是因重复提前排空而逐步减少的尾段记录；
- 最后一个有记录的周期为 `Day737`；`Day728` 是最后一个仍有 10 次重复的完整共同周期；
- `Day729` 至 `Day737` 的有效重复数依次减少，原因是不同重复在完成全部 75 架后提前停止，不再产生后续日周期记录。

从 Simio 汇总结果第一页重新抽取的前 27 个日周期平均值与 Dashboard 所用摘要字段逐条比对：

- A1 每日均值最大绝对差：`4.44×10^-16`；
- A3 每日均值最大绝对差：`8.88×10^-16`；
- 对有置信半宽的记录，最大绝对差约 `5.55×10^-17`。

整体 `Sts_WIP` 平均值也与 MCP 汇总值一致：

| 场景 | 10 次重复的整体平均 WIP |
|---|---:|
| A1 | 3.360755 架 |
| A3 | 12.889240 架 |

按 10 次重复计算的整体平均 WIP 95% 置信半宽分别为 A1 `0.005702` 架、A3 `0.157734` 架。A3 的整体平均 WIP 约为 A1 的 3.84 倍。A1 与 A3 的 `Out_Makespan` 在相同重复编号上逐值一致，平均完工时间为 `731.4611` 日；因此当前 WIP 差异来自缓冲策略的在制品积累，不是批次结束时刻不同造成的。

## 4. 验收结论

- ✅ `St_WIP` 已连接到 24 小时 `TimePeriod`，并产生了逐日实验结果。
- ✅ A1/A3 的场景筛选、日期维度、平均 WIP 度量和中文标题已写入 `MyDashboard1`；MCP 回读确认过滤器使用内部成员名 `DataSource`、`DataItem`、`StatisticType`、`ScenarioName`、`TimePeriod`。
- ✅ 有效重复数辅助图已加入，用于标识尾段样本量变化。
- ✅ MCP 读取的模型静态诊断为 0 errors；模型当前不在运行状态。
- ⚠️ 用户提供的展示模式截图显示 WIP 折线包含 A1/A3 两个系列、右图显示每日有效重复数；但之后提供的 Edit 模式截图中两个图表都出现红色错误标记且画布空白。Filter Editor 明确报错：`The following data items do not exist: DataSource, DataItem, StatisticType`；底部校验列表还将 `DataSource`、`DataItem`、`StatisticType`、`ScenarioName` 等报告为 `Invalid column`。这证明当前编辑上下文不能解析这些 FilterString 字段，问题不只是字段显示名的空格差异。展示模式曾成功绘制，不代表当前编辑定义已通过验证；运行视图是否用了已装载/缓存结果仍未单独验证。
- ⚠️ 长时间范围下横轴日期标签较密；数据曲线和系列可见，后续若用于汇报，可再调整横轴标签间隔以提升可读性。

本轮新增的原始证据文件：

- `validation/issue14-wip-dashboard-final.json`
- `validation/issue14-wip-dashboard-final.xml`
- `validation/issue14-wip-detail-mcp-raw-pages.json`
- `validation/issue14-wip-csv-verification.json`
- `validation/issue14-wip-analysis.json`
- `validation/issue14-wip-final-local-audit.json`
- `validation/issue14-wip-count-chart-final.json`
- `validation/issue14-wip-dashboard-rendered-20261028.png`（用户提供的 Simio Dashboard 实际界面截图）
- `validation/issue14-wip-dashboard-edit-error-20261028.png`（用户提供的 Edit 模式错误截图）
- `results/issue14_wip_daily_A1_A3.csv`

模型 Dashboard 的定义已写入当前活动模型，但 MCP 没有保存磁盘文件的接口。完成目视确认后，请在 Simio 中保存当前模型；若要形成交付快照，再另存为目标版本并重载复核。
