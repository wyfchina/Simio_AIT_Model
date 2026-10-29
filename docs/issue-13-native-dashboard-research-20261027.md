# Issue #13：原生实验 Dashboard 样例核查

核查日期：2026-10-27。活动模型：`/Project/Model`；Simio：`20.297.56736.0`。

## 样例来源

MCP 读取 `/Project/Model/ExperimentDashboards`，当前有一个原生实验 Dashboard：`MyDashboard1`。它不是普通模型 Dashboard，而是实验结果 Dashboard。其定义包含四个原生数据源：

- `Experiment Statistic Details`
- `Experiment Statistic Summaries`
- `Response Result Details`
- `Response Result Summaries`

样例图表 `Chart 1` 使用 `Experiment Statistic Summaries`，按 `StatisticCategory` 分组，并对 `DataItem` 做计数。这证明实验 Dashboard 可以直接读取实验统计结果，不需要把结果复制到普通输入表。

通过 Simio 程序集反射核对到 `Response Result Summaries` 的字段包括：`ScenarioName`、`ResponseName`、`Count`、`Average`、`Minimum`、`Maximum`、`HalfWidth`、`Median`、分位数及置信区间字段。`Experiment Statistic Summaries` 的字段包括：`ScenarioName`、`DataSource`、`StatisticCategory`、`StatisticType`、`DataItem`、`Average`、`Minimum`、`Maximum`、`HalfWidth` 和 `StandardDeviation`。

## 与当前模型 Dashboard 的差异

`Dash_ShiftTradeoff` 位于 `/Project/Model/Dashboards`，属于普通模型 Dashboard。清理 `Tbl_ShiftSummary` 后，它的 `Items` 为空；它只保留模型日志和普通输入表的数据源，因此不能显示 `Exp_D_Shift` 的跨场景 Response 结果。空白是数据源类型不匹配的结果，不是实验结果为空。

当前交付包的 `Exp_D_Shift` 实验视图仍保存了 37 个 Response 列，可以作为结果显示字段；Response 的底层名称和表达式保持英文，显示名称可以单独改为中文。

## 结论

Issue #13 的实验结果展示应采用 `ExperimentDashboards` 的原生数据源：

1. 结果明细或汇总表使用 `Response Result Details` / `Response Result Summaries`；
2. 统计量图表使用 `Experiment Statistic Details` / `Experiment Statistic Summaries`；
3. `Tbl_ShiftSummary` 不再恢复，也不向普通输入表写入仿真结果；
4. `Output Table` 适合记录交互运行期间逐行产生的状态输出，不能替代 `Exp_D_Shift` 的跨场景、跨重复 Response 汇总。

## 当前证据边界

- ✅ 已通过 MCP 读到原生实验 Dashboard 样例及四个原生结果数据源。
- ✅ 已确认 `Response Result Summaries` 具备方案、Response、均值和置信区间字段，足以承载 Issue #13 的结果表。
- ⚠️ 当前样例只展示了默认统计计数图表，尚未配置正式的 CT、Makespan、付薪人时和利用率图表。
- ⚠️ `MyDashboard1` 是当前活动模型中的样例；本轮没有把它保存为正式交付 Dashboard，也没有修改 `Dash_ShiftTradeoff`。

