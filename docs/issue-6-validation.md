# Issue #6 运行验收记录

检查日期：2026-10-24  
目标模型：`/Project/Model`（正式模型）  
Simio 版本：20.297.56736.0

## 验收范围

用户确认 Issue #6 的进入位置/时间戳登记、工位说明及 Facility 状态颜色与图例已完成；时间戳状态已存在。本次通过 Simio Desktop Interactive MCP 对四种容量/缓冲组合进行原生交互运行验收。MCP 回读的 `Prc_飞机进入工作站` 包含 C1–C5 的 Server 判断、对应 `CurLoc` 与 `Cell1EnterTime` 至 `Cell5EnterTime` 赋值，以及关联 `Tbl_Cells` 数据行的 `SetRow` 步骤。

## 运行条件

- 每组运行时长均为 336 仿真小时（两周），起始模型时间为 2026-10-26 00:00。
- 每组从初始化状态运行，飞机投放量为 75；每组均在 336 小时内观察到 Sink `TimeInSystem` 75 个观测，Source 创建 75 架飞机。
- 每条生产线的五个工位均各处理 35 或 40 架飞机；两线合计每个工位处理 75 架。
- 每组完成后 `get_run_status` 均为停止推进状态，`lastError=null`、运行警告数为 0；`get_diagnostics` 均为 0 错误。
- 四组运行均沿用 `Prop_Policy=1`（Pulse）。因此这些数据只证明 Pulse 配置下模型可运行，**不构成 Issue #6 完工驱动（Flow）线的验收结果**。
- `Prop_NumLines` 初始为 3，但模型属性说明允许值为 1 或 2，且第二线连接器的 `SelectionWeight` 为 `Prop_NumLines==2`。为使验收确实覆盖模型中的两条线，本次将其改为 2；这是本次唯一额外修正。
- 随后的只读检查确认：`TN_Release` 存在，`Outbound Link Rule=By Link Weight`；全模型 `search_values` 对 `Prop_Policy` 只返回属性定义，没有发现任何逻辑引用。当前唯一检出的分流权重是 `Connector2.SelectionWeight=Prop_NumLines==2`，没有证据表明释放路由区分 Pulse 与 Flow。

## 四种组合结果

| `Prop_CellCap` | `Prop_Buffer` | 运行时长 | Sink 完成数 | 线 1 / 线 2 各工位退出数 | C1 平均排队数（线 1 / 线 2） | C1 峰值排队数（线 1 / 线 2） | 各工位平均容量利用数范围 | 错误 / 警告 | 结论 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| 1 | 0 | 336 h | 75/75 | 35 / 40 | 4.9112 / 6.4952 | 34 / 39 | 0.0126–0.3106 | 0 / 0 | Pulse 下运行完成；不计入 #6 验收 |
| 1 | 1 | 336 h | 75/75 | 35 / 40 | 4.6693 / 6.2025 | 34 / 39 | 0.0126–0.3106 | 0 / 0 | Pulse 下运行完成；不计入 #6 验收 |
| 1 | `Infinity` | 336 h | 75/75 | 35 / 40 | 3.7174 / 4.8527 | 34 / 39 | 0.0142–0.3106 | 0 / 0 | Pulse 下运行完成；不计入 #6 验收 |
| 2 | 0 | 336 h | 75/75 | 35 / 40 | 2.5417 / 3.3555 | 33 / 38 | 0.0127–0.3177 | 0 / 0 | Pulse 下运行完成；不计入 #6 验收 |

容量利用数来自 10 个 Server 的 `Capacity / Average UnitsUtilized` 统计；C1 排队数来自 `Processing / EntryQueue` 统计。`(1,1)` 组的 C2 输入缓冲统计显示线 1/线 2 平均等待数分别为 0.0679/0.0785、峰值均为 1，与单位置缓冲一致。每组 Source 与 Sink 数量相等，且所有工位的退出数按线合计均为 75，说明本次运行没有观察到未完成或丢失的飞机。

## 结束状态与保存边界

- 验收后已停止模型并退出 Run Mode。当前 live 模型属性为 `Prop_CellCap=2`、`Prop_Buffer=0`、`Prop_NumLines=2`；诊断仍为 0 错误。
- MCP 工具列表未提供项目保存/另存命令，因此本记录只证明当前 Simio live session 的运行结果，不证明这些参数修正或统计已写入磁盘 `.spfx`。需要在 Simio 中保存模型，才能将修正后的 `Prop_NumLines=2` 持久化到交付文件。
- Facility 颜色和图例按用户确认作为已配置项记录；本次通过 MCP 未采集截图，未独立完成屏幕目视核验。

## 结论

上面四组历史数据使用 `Prop_Policy=1`，不计入 Flow 验收。本次补做 `Prop_Policy=2` 的路由配置和四种组合原生运行，证据见下节。Issue #6 的容量/缓冲组合已通过 MCP 原生运行检查；Facility 动画目视检查和正式 `AIT_V0.3_FlowLine.spfx` 保存后重载核验仍未完成，不能据此宣布 Issue #6 全部完成。

## Flow 释放与分流复验

复验日期：2026-10-24  
模型：`/Project/Model`，Simio `20.297.56736.0`  
运行：交互模型的 FastForward；每组 336 小时（2026-10-26 00:00 至 2026-11-09 00:00），Source 目标到达量 75 架。每组开始前均 Reset。

### 路由配置

- `TN_Release.Outbound Link Rule=By Link Weight`，`Outbound Link Preference=Available`。
- 连接线 1 的 `Connector1.Selection Weight=Prop_Policy==2`。
- 连接线 2 的 `Connector2.Selection Weight=Prop_Policy==2 && Prop_NumLines==2`。
- 因此 Flow 模式下，单线只启用线 1；双线时两个出口均可选，且 `Available` 会优先从当前可接收实体的出口中选择。`Prop_Policy=1` 的脉动节拍/释放逻辑仍属于后续 Issue #9，本次没有实现或验收。

### 双线四种组合

| `Prop_Policy` | `Prop_CellCap` | `Prop_Buffer` | Source 创建 | Source 输出池峰值 | C1 退出数（线 1 / 线 2） | C1 最大在制（线 1 / 线 2） | Sink 完成 | 错误 / 警告 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 2 | 1 | 0 | 75 | 73 | 35 / 40 | 1 / 1 | 75 | 0 / 0 |
| 2 | 1 | 1 | 75 | 73 | 35 / 40 | 1 / 1 | 75 | 0 / 0 |
| 2 | 1 | `Infinity` | 75 | 73 | 35 / 40 | 1 / 1 | 75 | 0 / 0 |
| 2 | 2 | 0 | 75 | 71 | 35 / 40 | 2 / 2 | 75 | 0 / 0 |

四组均在 336 小时内完成 75 架，线 1/线 2 的 C1 数量合计为 75。容量 2 组的 C1 `Maximum NumberInStation=2`，实际统计证实容量可并行容纳两架。各组静态诊断均为 0 错误。`Processing.EntryQueue.Maximum NumberWaiting` 在缓冲 0 组分别返回 1/1，在容量 2、缓冲 0 组返回 2/2；缓冲 1 和 `Infinity` 两组该统计项未返回，故不把缺失项解释为数值 0，也不以该项单独证明缓冲容量。

### 单线分流烟雾运行

另以 `Prop_Policy=2, Prop_NumLines=1, Prop_CellCap=1, Prop_Buffer=0` 运行 336 小时：Source 创建 75、Sink 完成 75、线 1 C1 退出 75；线 2 无运行统计记录。运行警告 0，静态诊断错误 0。该结果验证 `Prop_NumLines=1` 时线 2 权重关闭。

### 保存和剩余核验

- 用户已将 Flow 修改保存到 `AIT_V0.2_Skeleton_Issue5DescriptionCleanup_20261024.spfx`。保存后文件时间为 2026-10-24 16:58，SHA256 为 `875220A6923D68E81C71F54F409B69EF165B37600F998CA676DA7770A2BAE305`；修改前快照 `snapshots/AIT_V0.2_Skeleton_Issue5DescriptionCleanup_20261024_PreFlow_20261024.spfx` 仍为 `2B25BA50B38A37CF6D0D47C21BCD116674BE35AABB783B04C98A7F6FEA4FEDC8`。
- 已解压读取候选包 `Models/Model/8b99310d-526e-4b9e-8f81-6dff5a63885f.xml`，确认 `Connector1` 的 SelectionWeight 为 `Prop_Policy==2`、端点为 `TN_Release → Input@Srv_L1_C1`；`Connector2` 为 `Prop_Policy==2 && Prop_NumLines==2`、端点为 `TN_Release → Input@Srv_L2_C1`。包内控制值为 `Prop_Policy=2, Prop_NumLines=2, Prop_CellCap=2, Prop_Buffer=0`。MCP 当前活动模型回读相同，诊断 0 错误，且已退出 Run Mode。
- 本次没有关闭并重新打开 Simio 项目，因此确认了磁盘包内容与当前 live 模型一致，但没有单独做重载试验。正式 `AIT_V0.3_FlowLine.spfx` 版本快照和 Facility 目视检查仍待完成。

## 本轮 MCP 最终复验：2026-10-24

本节取代上文关于图形对象未能读取、Flow 四组尚未重跑的状态。检查目标是活动模型 `/Project/Model`；用户此前已确认保存并重载正式模型。MCP 不返回当前项目磁盘路径，因此这里的对象和运行证据针对当前 live 模型，不能单独证明最近修改已保存进 `.spfx`。

### 图形对象核验

`list_drawing_objects(modelName="Model")` 返回 72 个 Facility 绘图对象：42 个 Queue 动画图形、10 个 `StatusPie`、1 个 `StatusPlot`、15 个 `Label` 和 4 个 `Ellipse`。十张状态饼图的数据源逐一对应 `Srv_L1_C1` 至 `Srv_L1_C5`、`Srv_L2_C1` 至 `Srv_L2_C5` 的 `ResourceState`。四个椭圆图例分别标为 `Processing`、`Blocked`、`Starved`、`Off Shift`；工位标题覆盖两条线的 C1–C5。

WIP 时间图 `StatusPlot:0` 有一条 `WIP` 系列，横轴为 `Run.TimeNow`，纵轴为 `St_WIP`；标题为 `Production Line WIP (Aircraft)`。MCP 可以核对对象、位置、绑定数据源和标签文本；本轮未采集 Simio 窗口截图，因此不把布局的屏幕目视检查记为已完成。

### Flow 四组合重跑

实验 `Issue7_FlowValidation` 使用 `Prop_Policy=2`、`Prop_NumLines=2`、`Prop_NumPlanes=75`，四个活动场景各 30 次重复，完成 120 次。开始前清除了先前取消运行的 24/30 部分结果；本轮实验最终状态 `completed`，无错误。四组均有 30 个有效重复，静态诊断为 0 errors。

| 容量 `Prop_CellCap` | 缓冲 `Prop_Buffer` | 平均 Makespan（日） | 平均 WIP（架） | 平均最大 WIP（架） | C1至Sink平均流程时间（日） | Little 定律相对误差（%） | 创建/完工/结束WIP | 守恒差额 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | 0 | 5.2802 | 5.7323 | 8.00 | 0.3941 | 约 0 | 75/75/0 | 0 |
| 1 | 1 | 5.2802 | 7.2245 | 10.00 | 0.4959 | 约 0 | 75/75/0 | 0 |
| 1 | `Infinity` | 5.2802 | 13.6368 | 25.43 | 0.9352 | 约 0 | 75/75/0 | 0 |
| 2 | 0 | 2.6871 | 11.1645 | 16.00 | 0.3986 | 约 0 | 75/75/0 | 0 |

四组 Little 定律误差每个重复均小于 `2×10^-13%`；各响应均有 30 个观测。每组 75 架全部从 C1 进入并完成，结束 WIP 和守恒差额均为 0。Flow 实验接受结果并完成，但 StatusPie/StatusPlot 的屏幕显示效果及最近 live 变更写入正式磁盘包仍需保存后复核。

**更新后的结论：**Issue #6 的图形对象定义与 Flow 四种容量/缓冲组合已经通过 MCP 结构及 120 次重复运行核验。尚未闭环的交付边界只有本轮变更后的磁盘保存/关闭重载确认，以及未执行的屏幕布局目视检查。
