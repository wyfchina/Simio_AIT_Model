# Issue #5 公共骨架实施记录

检查日期：2026-10-23  
目标模型：`/Project/Model`（正式模型；不在 `/Project/Proto_V0_1_TaskTable` 测试原型中实施）  
Simio 版本：20.297.56736.0

## 本次基线

- 根目录 `Aerospace.spfx` 大小为 179,200 字节，SHA-256 为 `99011868917B1FC029FA6509EEACAF792F33B0E0D9DB5C47FF82187CCC889282`。
- 已创建字节级前置快照 [`Aerospace_PreIssue5_20261023.spfx`](../snapshots/Aerospace_PreIssue5_20261023.spfx)，与根文件 SHA-256 一致。
- 正式模型包含 5 个 Server（`MyServer1` 至 `MyServer5`）、`MySource1`、`MySink1`、`DefaultEntity`，以及 `Tbl_Tasks`、`Tbl_Cells`、`Tbl_Stations` 三张表。
- 正式模型当前没有 ObjectList、InputParameters 或 Experiment。五个 Server 均为 `Process Type=Task Sequence`；本次未修改这些对象。
- `/Project/Proto_V0_1_TaskTable` 是单独的 Issue #4 测试原型，本次只读取它以核实已有 `StandardWeek` 配置，没有修改原型。

## 实施状态

本次尚未对 Simio 模型做任何修改。Issue #5 要求的模型属性、飞机实体状态、投放过程、每条线 40 名机械师及其 ObjectList、四套工作日程、30 次重复的型号数量验证均未实施，不能标记为完成。

## 当前阻断

1. Simio MCP 服务本身正常：本机 `localhost:51310` 的 JSON-RPC 初始化成功，工具列表有 128 项，活动模型和正式模型都可读取。但工具列表没有保存/另存模型操作，也没有独立工作日程/DayPattern 的创建接口；正式模型的模型项集合也没有 Schedules 集合。`Schedule`、`DayPattern` 仅在可创建属性类型目录中出现，不能据此创建日历数据。
2. Computer Use 初始化与重试均失败，错误为：`Computer Use native pipe is unavailable: failed to connect native pipe: 系统找不到指定的文件。 (os error 2)`。因此当前无法通过 Simio 桌面界面创建工作日程或另存为 Issue #5 要求的 `AIT_V0.2_Skeleton.spfx`。

## 后续恢复条件

恢复 Codex Computer Use native pipe 后，重新确认当前 Simio 项目和活动模型，以本记录中的 SHA-256 对照磁盘基线，再在正式 `/Project/Model` 完成 Issue #5。完成后另存为 `AIT_V0.2_Skeleton.spfx`，逐项检查模型属性、`Ent_Plane` 状态、投放守恒、80 个机械师资源（两条线各 40 人）、ObjectList 成员、四套周日程及其周工时，并用 30 次原生重复确认每次飞机型号数量准确。新增模型对象和后续验证记录使用中文 Description 与中文文档。

## 用户另存后的核查：2026-10-23

- 根目录已出现 `AIT_V0.2_Skeleton.spfx`，大小 183,714 字节，SHA-256 为 `6CA5D18BF8C773A93508C43DE4EB9906085C1A63213D95D9CE1662344D323722`；文件中的 Simio 项目 ID 与 `Aerospace.spfx` 相同。文件包含正式模型 `Model` 和原型 `Proto_V0_1_TaskTable`。根目录 `Aerospace.spfx` 当前为 183,722 字节，SHA-256 为 `D1C9054EE37998E3EF714D81373CD21650EFDC16C5E223EF30EB006293FCB4B7`。
- 检查快照中的正式模型定义，未发现 `Prop_*`、`Ent_Plane`、`CurLoc`、机械师资源/列表、`Day_2Shift`、`Day_3Shift` 或 `Sch_S0` 至 `Sch_S3`。MCP 读取的当前 `/Project/Model` 也仍为 `DefaultEntity`、`MyServer1` 至 `MyServer5`、`MySource1`、`MySink1`，ObjectLists 为空。本次只读检查没有修改模型。
- MCP 的 `get_active_model` 仍返回 `/Project/Proto_V0_1_TaskTable`。该接口不返回项目文件路径，因而不能单凭它证明当前内存中的项目来自 `AIT_V0.2_Skeleton.spfx` 还是同项目 ID 的 `Aerospace.spfx`。Computer Use 重试仍报 native pipe 不可用，因此本次也无法从 Simio 界面确认标题栏路径。开始模型修改前还需确认该快照已在 Simio 中打开，并将正式 `Model` 设为目标。

用户随后确认已在 Simio 中打开 `AIT_V0.2_Skeleton.spfx`。MCP 仍将原型列为活动模型，但正式 `/Project/Model` 可按完整路径读取；后续接口调用应显式使用 `/Project/Model`，不能使用活动模型路径作为目标。

## 工作日程配置要求与磁盘核验

在 `Data > Schedules` 建立两个日模式和四个周计划。周期以周一 00:00 为周起点；容量为 1 表示单名机械师可用，容量为 0 表示不可用。日期均为本地模型时间。

### `Day_2Shift`

| 每日时段 | 容量 |
|---|---:|
| 00:00–06:00 | 0 |
| 06:00–10:00 | 1 |
| 10:00–10:30 | 0 |
| 10:30–18:00 | 1 |
| 18:00–18:30 | 0 |
| 18:30–22:00 | 1 |
| 22:00–24:00 | 0 |

每天可用工时为 15 小时，两个 8 小时班次分别安排 30 分钟停机休息。

### `Day_3Shift`

| 每日时段 | 容量 |
|---|---:|
| 00:00–02:00 | 1 |
| 02:00–02:50 | 0 |
| 02:50–10:00 | 1 |
| 10:00–10:50 | 0 |
| 10:50–18:00 | 1 |
| 18:00–18:50 | 0 |
| 18:50–24:00 | 1 |

每天可用工时为 21.5 小时。为与 Issue #5/#13 的周工时 107.5/150.5 小时一致，建议三个 8 小时班次各安排 50 分钟容量为 0 的停机，其中 30 分钟作为休息，另 20 分钟作为交接/班前准备。这 20 分钟是为匹配目标工时提出的建模假设，原 Issue 没有指定其业务依据；若不接受该假设，应先确认实际交接时段和周工时口径，再调整日模式。

### 周计划

| 周计划 | 周一至周五 | 周六 | 周日 | 验收可用工时 | 周末边界检查 |
|---|---|---|---|---:|---|
| `Sch_S0` | `Day_2Shift` | 0 | 0 | 75 小时 | 周五 22:00 至周一 06:00 为 0 |
| `Sch_S1` | `Day_2Shift` | `Day_2Shift` | `Day_2Shift` | 105 小时 | 每日 22:00 至次日 06:00 为 0 |
| `Sch_S2` | `Day_3Shift` | 0 | 0 | 107.5 小时 | 周五 24:00 至周一 00:00 为 0 |
| `Sch_S3` | `Day_3Shift` | `Day_3Shift` | `Day_3Shift` | 150.5 小时 | 仅保留日模式中三个 50 分钟停机段 |

`Sch_S0`、`Sch_S1`、`Sch_S2`、`Sch_S3` 是班组可用日历。后续机械师作为单人 Resource 时，应设 `Capacity Type=WorkSchedule`、`Initial Capacity=1`、`Off Shift Rule=Suspend Processing`，再由实验场景选择相应的周计划。

### 用户配置后的核验结果：2026-10-23

- 用户确认四个周计划已保存，并接受 `Day_3Shift` 每班 20 分钟交接/准备停机的建模假设。
- Simio MCP `get_active_model` 返回 `/Project/Model`，版本为 20.297.56736.0。MCP 的 `list_children` 不枚举 Schedule/DayPattern，但目标磁盘文件 `AIT_V0.2_Skeleton.spfx` 中正式模型 XML 含有全部六个目标名称：`Day_2Shift`、`Day_3Shift`、`Sch_S0` 至 `Sch_S3`。按其序列化周期引用，S0/S2 周一至周五分别绑定对应日模式，S1/S3 周一至周日绑定对应日模式；未显式引用的周末日默认为 0 容量。
- 从磁盘 XML 逐段核对 `Day_2Shift` 为 06:00–10:00、10:30–18:00、18:30–22:00 容量 1，其余容量 0，合计 15 小时/日；`Day_3Shift` 为 00:00–02:00、02:50–10:00、10:50–18:00、18:50–24:00 容量 1，三个 50 分钟停机段容量 0，合计 21.5 小时/日。
- 周工时复算：S0=5×15=75 小时；S1=7×15=105 小时；S2=5×21.5=107.5 小时；S3=7×21.5=150.5 小时。目标区间与 #5 预期一致。S0/S2 周六、周日无日模式引用，即 0 容量；S1/S3 每日均按对应日模式执行，跨日非工作时段容量为 0。
- 日模式的 XML 定义未填写中文 Description。这是建模规范缺项，应在 Simio 数据表界面补充日模式说明。
- 本次未进行模型运行或保存操作。磁盘文件 SHA-256 为 `1EFC37C6967DE565EE987F2A0C5283C0A7AA1F3A9B9D7F90C68651A1B3C1C8FC`；MCP 暴露的对象定义读取不显示日历，而从磁盘包核实是针对该已保存文件的只读检查。

### Issue #5 其余工作状态

- 用户澄清：模型属性定义可用英文；中文要求适用于 Codex 输出的检查材料等 Markdown 文件。MCP 对属性定义返回的中文字段名可用 JSON Unicode 转义作为 `set_property` 的属性键；因此后续模型属性均以英文说明配置。
- 正式模型已在 live Simio 会话中创建 10 个 Issue #5 控制属性：`Prop_Policy`、`Prop_NumPlanes`、`Prop_NumSA103`、`Prop_PulseDays`、`Prop_CellCap`、`Prop_Buffer`、`Prop_LaborPolicy`、`Prop_Shift`、`Prop_NumLines`、`Prop_Deterministic`。默认值依次为 1、75、0、4、1、0、1、0、1、False；各属性已填写英文 Description。`Prop_Buffer` 为 Real，支持 0、1 或 Infinity 的方案表达。
- 正式模型已创建飞机实体定义 `Ent_Plane`，但尚未增加飞机级状态，也没有实现投放过程。MCP 支持的 `create_model_item` 对 State 只暴露模型级 `/States` 集合；`Ent_Plane` 没有可访问的 States 子集合。探测过的临时模型级 `ProbeState` 已删除。不可用模型级变量替代每架飞机各自的 `PlaneType`、`CurLoc`、`PlaneID` 等状态。
- 正式模型已创建 80 个单人 Resource，命名为 `Res_M_L{1|2}_C{1..5}_{01..08}`，均设 `Capacity Type=WorkSchedule`、`Initial Capacity=1`、`Initial Work Schedule=Sch_S0`，并填写英文说明。已创建 12 个 ObjectList：两条线各有 5 个 8 人工位名单及 1 个 40 人全线名单。MCP 复核总 Resource 数为 80、各工位名单成员数均为 8、全线名单成员数均为 40；`get_diagnostics` 返回 0 个错误。
- 当前 80 个 Resource 的初始绑定均为 `Sch_S0`；`Prop_Shift` 尚未切换到 S1/S2/S3。直接将条件表达式写入 `Initial Work Schedule` 会被 Simio 判为无效计划表引用；已立即恢复测试资源为 `Sch_S0`，最终诊断为 0 错误。`SetWorkSchedule` 步骤 schema 可用，且单步骤临时流程可创建；尝试将 320 个赋值分支写入系统 `OnRunInitialized` 流程时，MCP 返回内部对象引用错误，系统流程保持原空状态。临时测试流程已删除。后续需在 Simio 界面把 Prop_Shift 条件分支挂到初始化流程，再运行验证四种班次选择。
- `AIT_V0.2_Skeleton.spfx` 的正式模型 XML 仍是用户保存的日程版文件，不含上述 live 会话新增项。已创建磁盘基线副本 [`AIT_V0.2_PreIssue5_MCPBuild_20261023.spfx`](../snapshots/AIT_V0.2_PreIssue5_MCPBuild_20261023.spfx)；当前 MCP 无模型保存接口。本轮实施状态只存在于 Simio live 会话中，尚未写入目标 `.spfx`，需要在完成后由 Simio 桌面保存并重载复核。
- 为补足 MCP 未暴露的实体 States 集合及系统初始化过程，按用户此前授权重试 Computer Use；初始化仍失败：`Computer Use native pipe is unavailable: failed to connect native pipe: 系统找不到指定的文件。 (os error 2)`。因此无法通过桌面界面继续该部分。
- 日程配置与工时验收通过；控制属性、`Ent_Plane` 实体定义、机械师资源及 ObjectList 已在 live 会话完成并经 MCP 结构核查；Simio 最终诊断 0 错误。飞机级状态、严格型号配比投放、30 次重复验证、Prop_Shift 班次切换、磁盘保存和重载验证尚未完成，因此 Issue #5 整体仍不能判定完成。

### 重启后的复核与继续状态：2026-10-23

- 用户已重启 Codex。重新通过 MCP 查询，Simio 活动模型现为 `/Project/Model`；Computer Use 能枚举到窗口 `AIT_V0.2_Skeleton - Simio RPS版本`。尝试激活捕获窗口时返回 `failed to activate captured window`，因此本次无法使用桌面界面继续编辑或确认模型磁盘路径。
- 重启后正式模型仍有 89 个对象（含 `Ent_Plane` 和 80 个 Resource）、12 个 ObjectList、系统 `OnRunInitialized` 空流程；`get_diagnostics` 为 0 错误。`Ent_Plane` 可读属性中没有用户状态项。Resource `Res_M_L1_C1_01` 的 `Initial Work Schedule` 仍为 `Sch_S0`，属性允许值为 `Sch_S0` 至 `Sch_S3` 和 `StandardWeek`，但尚未按 `Prop_Shift` 动态选择。
- MCP 状态类型目录只提供模型级 `/States`，`/Objects/Ent_Plane/States` 并非已知子集合。尝试目标实体子路径返回 `Unknown sub-collection kind`，未产生模型修改。随后对探测性 State 创建的自动审查明确拒绝，理由为该调用会创建模型级状态或探测不支持的实体级状态并留下非预期持久改动；遵从拒绝，未绕过或重试变通。
- 本次没有模型变更、运行或保存。目标磁盘 `AIT_V0.2_Skeleton.spfx` SHA-256 为 `CCE2DF0DC4F35580BE9935C5846DC91EE9AF6763E3602BA43DBAD6DEB7AA4C56`；该值不同于先前记录的用户保存日程版哈希，故当前以本次实测哈希作为记录，不对文件内部内容作未完成的推断。
- 本次复核结论：日程及工时记录可沿用此前针对保存包的只读核验；重启后 live 模型对象和零诊断得到复核。飞机级状态、投放逻辑、30 次原生重复验证、`Prop_Shift` 排程切换、Simio 保存与重载核验仍未完成，Issue #5 仍未通过。下一步需修复/重建 Computer Use 的目标窗口捕获（或用户在桌面端完成窗口焦点恢复后重新发起操作）；只有通过 Simio 支持的实体状态编辑界面与原生保存流程完成后，才能继续后续验收。

### Computer Use 窗口恢复尝试：2026-10-23

- 用户确认已手动完成窗口前置处理。重新初始化 `@oai/sky` 后，`list_apps` 唯一枚举到标题为 `AIT_V0.2_Skeleton - Simio RPS版本` 的 Simio 窗口；重新取得窗口对象并调用 `activate_window` 成功。界面截图确认项目标题、正式 `Model`、控制变量和当前工作日程视图；四个周计划 `Sch_S0` 至 `Sch_S3` 与日模式对应关系均显示在日程表中。
- 成功捕获后，后续一次 UI 操作调用仍间歇返回 `failed to activate captured window`；另一次界面刷新返回的 accessibility tree 为空，导致不能可靠点击导航进入实体状态编辑界面。本次未对模型进行任何写操作，也未运行或保存。
- 为保护用户当前保存状态，已建立本轮快照 [`AIT_V0.2_PreComputerUse_20261023.spfx`](../snapshots/AIT_V0.2_PreComputerUse_20261023.spfx)，与开始操作前目标文件 SHA-256 一致（`CCE2DF0DC4F35580BE9935C5846DC91EE9AF6763E3602BA43DBAD6DEB7AA4C56`）。
- 结论：Computer Use 已至少一次恢复成功捕获，但 UI 自动化调用仍不稳定，当前不足以继续编辑。未更改 Issue #5 验收结论；需要重新获取 Simio 窗口与截图状态后再逐步操作。

### 机械师建模修正：Worker 群体方案，2026-10-23

- 用户指出将 80 名机械师建成 80 个 Resource 设施对象会造成设施图形过密。该意见成立：Resource 适合表达容量约束，但不适合把每名机械师都作为可视设施对象铺在生产布局中。
- 正式模型中新增 10 个 Worker 群体：`Wkr_L1_C1` 至 `Wkr_L1_C5`、`Wkr_L2_C1` 至 `Wkr_L2_C5`。每个群体当前配置为 `Initial Number In System=8`、`Capacity Type=WorkSchedule`、`Initial Work Schedule=Sch_S0`，并放置在生产线下方的稀疏区域；每个对象均有中文说明。
- Worker 的标准类型支持移动资源被任务 Seize/Release，并支持工作日程；这与 Issue #4 的人数需求设计方向一致。正式模型诊断仍为 0 错误。
- 原有 80 个 Resource 和 12 个 ObjectList 暂时保留，尚未删除或替换。当前名单仍包含单体 Resource 名称；不能在没有原生运行证据的情况下直接把一个 8 人 Worker 群体名称替换进去，因为需要确认 `Mechanics=3` 时是否能按 3 名独立 Worker 实例同时分配，以及日志是否保留人员级占用证据。
- 因此本轮结论是“Worker 群体布局已建立，资源池迁移尚未验收”，不把 Issue #5 标记为完成。下一步应在一个工位上用 Worker 名单做最小原生任务序列测试，确认人数、同时占用、工作日程和 ResourceUsage 记录后，再批量迁移并清理旧 Resource。

### Worker 三人同时占用原生测试：2026-10-23

- 测试目标：在正式模型 `/Project/Model` 验证一个 `Mechanics=3` 的任务是否能同时占用同一工位 Worker 群体中的 3 名独立 Worker，并在运行日志中留下可核查证据。
- 测试配置：临时名单 `Lst_TestWorker` 仅含 `Wkr_L1_C1`；`MyServer1` 临时配置 1 条处理时间为 1 的任务，资源类型为 `Select From List`、需求数为 3、每资源单位数为 1、`Must Simultaneously Seize=True`。`MySource1` 临时设为只生成 1 架 `Ent_Plane`。运行设置为 2 小时并启用交互运行日志。
- 原生运行结果：Simio 运行无 Runtime Warning，但 `Constraint` 日志有 1 条记录，实体 `Ent_Plane.193` 在 `MyServer1` 的 `Processing` 站因 `ResourceAvailability` 被 `Lst_TestWorker` 阻塞；`Task` 日志 0 条，`ResourceUsage` 日志 0 条。运行状态显示已暂停/结束，不能据此推断任务完成。
- 判定：**三人同时占用 Worker 尚未证明，当前测试失败，不能据此满足 Issue #4 的人数验收，也不能删除 80 个 Resource 或 12 个 ObjectList。**更具体地说，测试名单中的一个 Worker 群体对象没有被任务系统作为 3 个可分配的独立 Worker 取得；目前证据只证明发生资源可用性阻塞。此结果不说明所有可能的 Worker 配置都不可行，但现有“每工位一个 8 人 Worker 群体 + 任务需求数 3”的映射尚不成立。
- 运行结束时 `get_diagnostics` 为 0 错误；这只表示模型属性没有静态错误，不代表任务运行成功。`Links` 集合返回 0 项，因此尚未证实 `MySource1` 到 `MyServer1` 存在可执行连接；不过 Constraint 日志表明该实体至少已到达 `MyServer1` 的 Processing 资源分配阶段。
- 清理：已调用 `reset_model` 并删除临时 `Lst_TestWorker`。原有 80 个 Resource、12 个 ObjectList 均保留。**临时运行同时改动了 `MyServer1` 的 Processing Tasks 和 `MySource1` 的 Maximum Arrivals；MCP 没有提供先前值的快照，故不能安全猜值恢复。**需在 Simio 中根据测试前保存版本/磁盘文件恢复这两项，再核对其余任务模板与测试前一致。未保存 `.spfx`。
- 后续判定前置条件：先恢复并确认上述两个对象的测试前配置；再建立一个不依赖未确认生产连线的最小测试路径，确保测试实体进入指定 Server；配置 Worker 名单/数量语义后重跑，并取得至少 3 条 Worker 个体占用记录及任务执行时间区间重叠的原生日志证据。只有该证据和 Issue #4 其余验收项均通过后，才考虑迁移名单并删除旧 Resource/ObjectList。

### Worker 三人任务再次原生运行确认：2026-10-23

- 用户修正了 `MyServer1` 的资源字段。运行前 MCP 核实任务设置为 `Resource Type=Specific`、`Resource Name=Wkr_L1_C1`、`Number Of Resources=3`、`Units Per Resource=1`、`Must Simultaneously Seize=True`；`Wkr_L1_C1` 有 8 名 Worker，`Initial Work Schedule=Sch_S0`。`MySource1` 生成 1 架 `Ent_Plane`，运行前诊断为 0 错误。
- 首次运行从周一 00:00 开始，`Sch_S0` 到 06:00 才进入工作时段。Constraint 日志记录 `Wkr_L1_C1` 的资源可用性等待区间为 00:00:02–06:00；此运行只说明请求遇到排班不可用，不能用来判定 Worker 数量逻辑失败。
- 为隔离排班因素，在未改变任务和 Worker 数量配置的情况下，将本次运行起点临时改为 2026-10-26 06:00、时长 2 小时，并临时启用 `Wkr_L1_C1` 的 Resource Usage 日志。原生 Fast Forward 运行无 Runtime Warning，Constraint 日志 0 条。
- `ResourceUsage` 日志记录同一实体 `Ent_Plane.113` 在 `MyServer1` 执行 Task 1 时同时占用三个独立实例：`Wkr_L1_C1[1]`、`Wkr_L1_C1[2]`、`Wkr_L1_C1[3]`。三条记录的开始时间均为 2026-10-26 06:00:02，结束时间均为 06:01:02，实际占用时长均为 1 分钟，资源所有者均为 `Ent_Plane.113`。因此已用原生日志证明任务同时取得 3 名 Worker。`Task` 日志仍为空；人数与同时占用结论依据三条 Worker 个体 ResourceUsage 记录及零 Constraint，而非 Task 日志。
- 本次结束后已停止模型，并将 `Wkr_L1_C1.Log Resource Usage` 恢复为 False；RunSetup 恢复为运行前的 2026-10-26 00:00 起点、2 周时长及交互运行数据设置。最终 `get_diagnostics` 为 0 错误。没有保存 `.spfx`。
- 根据本次已成功的运行验证，已按用户指示删除原有 80 个 `Res_M_L{1|2}_C{1..5}_{01..08}` Resource 和 12 个 ObjectList。删除后 MCP 复核 `Lists` 集合为 0 项、80 个指定 Resource 均不存在；10 个 Worker 群体保留，非目标 `Resource1` 未删除。删除后的模型诊断为 0 错误。该清理仅针对 live Simio 模型；磁盘文件尚未保存或重载确认。

### Issue #5 继续核验：2026-10-23

- 活动模型确认是 `/Project/Model`，模型诊断为 0 个静态错误。
- `Ent_Plane` 当前只有标准 ModelEntity 属性，没有飞机业务状态 `PlaneID`、`PlaneType`、`CurLoc`、`EnterLineTime`、工位进出时间或 `OpenWO`。因此飞机定位、型号和投放守恒逻辑尚未在实体定义中实现。
- `MySource1` 当前为 `Entity Type=Ent_Plane`、`Maximum Arrivals=1`、`Interarrival Time=0`，没有连接到自定义投放过程；`OnRunInitialized` XML 的 `Steps` 为空。
- `/Project/Model/Experiments` 为空，没有 30 次重复的 Experiment/Scenario 配置。当前运行日志中的三人 Worker 结果是专项原生验证，不是 #5 要求的型号配比重复验证。
- `MyServer1` 的三人 Worker 测试任务仍存在，资源字段已正确指向 `Wkr_L1_C1`；这项测试任务证明 Worker 数量语义，但不等同于完整的 `Tbl_Tasks` 驱动生产骨架。
- 结论：Worker 三人同时占用、旧 Resource/ObjectList 清理和日程结构检查已通过；飞机实体状态、投放过程、严格型号配比、30 次重复验证、班次属性切换以及保存/重载边界仍未完成，Issue #5 继续判定为未完成。

## 历史验收状态（已被下文正式包复核取代）：2026-10-24

以下内容是正式包统一前的一次审核快照，描述的是当时的 `AIT_V0.2` 文件状态；其中“仍引用 `Lst_TestWorker`、缺少场景定义”等结论不适用于当前 `AIT_V0.3_FlowLine.spfx`。保留此段仅用于追溯审核过程，当前状态以文末“正式包统一复核”为准。

本节取代此前“Issue #5 已完成”的结论。审核者从交付包独立核对后，Issue #5 应判定为“部分完成”；早期记录保留为实施过程历史。

- **飞机实体与初始化：通过。**交付模型包中的 `ModelEntity` 定义含 `PlaneID`、`PlaneType`、`CurLoc`、`EnterLineTime`、`Cell1EnterTime` 至 `Cell5ExitTime`、`OpenWO` 等飞机状态。`MySource1` 创建 `Ent_Plane`，最大到达数引用 `Prop_NumPlanes`，Created Entity 触发器绑定 `Prc_飞机创建初始化`。初始化流程将 `CurLoc` 设为 0，使用剩余配额概率分支和随机流 101 抽样，扣减配额并设置型号、计数、顺序校验值和唯一编号。`OnRunInitialized` 保留用户配置的 `RemainSA103 = Prop_NumSA103`。
- **型号配额与顺序：通过。**`Issue5_Validation` 的 `Scenario1`、`S1_75`、`S2_75`、`S3_75`、`S0_100` 均为 Completed，且各自 30/30 次完成。75 架场景每次为 SA101/SA102/SA103=`45/30/0`；100 架场景每次为 `45/30/25`。第二个按编号平方加权的顺序校验响应在每个场景 30 次重复中有 30 个不同值。
- **机械师：部分通过。**最终模型保留两条线 10 个 Worker 群体，每群体 8 人，共 80 名 Worker；旧的 80 个单人 Resource 与 12 个 ObjectList 已清理。此前原生 `ResourceUsage` 日志证明 `Mechanics=3` 同时占用 `Wkr_L1_C1[1..3]`，但该日志未随交付包保存，审核者无法从包内独立复核。交付包中的 `MyServer1` 仍有临时 Worker 三人测试任务并引用 `Lst_TestWorker`，需清理后重新保存。
- **日程：通过。**四套周计划由 `Wkr_InitialWorkSchedule` 属性提供给 Worker，实验场景分别选用 S0 至 S3。每人每周排班工时为 75、105、107.5、150.5 小时。S0/S2 为周一至周五计划，周末零容量；S1/S3 为七天计划，周末继续按日模式排班。`Prop_Shift` 是编号控制量，不会自行触发运行中的动态换班。
- **保存与重载：部分通过。**当前目标文件 SHA-256 为 `8C7FD29BF51B225D5FB3EDF53CCC041D5A01FB45338FE6148CA3373359D527CD`，大小 3,180,198 字节。模型属性、实体状态、Worker 和日程 XML 在包内存在；但包内没有 `Issue5_Validation` 的 Experiment/Scenario 定义，因此场景控制值与日程绑定不能独立重核。

### 待补项

1. 在正式设施中建立 TransferNode，并按 `Prop_Policy`、`Prop_NumLines` 配置到对应生产线的分流。
2. 删除 `MyServer1` 的 `Lst_TestWorker` 临时三人测试任务，恢复正式 `Tbl_Tasks` 驱动配置。
3. 为 `PlaneID`、`CurLoc`、`EnterLineTime`、各工位进出时间、`OpenWO` 及日模式补充中文 Description。
4. 将 `Issue5_Validation` 的 Experiment、Scenario、控制值和响应定义随交付包保存，并重新核验。

Issue #5 当前为部分完成；完成上述待补项后才能重新标记为完成。本次交付范围止于 #5，不代表 Issue #6 及后续内容已实施。

## 离线候选包修订：2026-10-24

在保留原交付文件不变的前提下，已生成候选包 `AIT_V0.2_Skeleton_Issue5DescriptionCleanup_20261024.spfx`。本候选包仅做了三项可明确定位的修订：

- 为 `PlaneID`、`CurLoc`、`EnterLineTime`、`Cell1..Cell5` 进出时间及 `OpenWO` 补充中文 Description。
- 为 `Day_2Shift`、`Day_3Shift` 补充中文 Description。
- 删除 `MyServer1` 中唯一的 `Worker三人测试` ProcessingTasks 行及其 `Lst_TestWorker` 引用。

候选包 SHA-256：`950D3CB46BC139AF6AFF18FA957421C00461C802539E196A8DA3E62F120C927F`。原交付文件 `AIT_V0.2_Skeleton.spfx` 未覆盖。该候选包尚未由 Simio 原生加载、运行和重新保存，因此不能直接作为最终交付包；需先在 Simio 中打开并检查诊断、任务模板和运行结果。

## 正式包统一复核：2026-10-24

本节是 #5 文档与交付包的当前基准，取代此前关于“最终包仍含 `Lst_TestWorker`、缺少实验定义、状态 Description 未补齐”以及候选包尚不能交付的结论。分阶段记录保留作实施历史，不再代表当前文件状态。

### 交付文件

- 正式文件：项目根目录 `AIT_V0.3_FlowLine.spfx`。
- 文件大小：3,222,124 字节；修改时间：2026-10-24 19:11:24（本机时间）。
- SHA-256：`CC5EF7072AF0F10CA0F8EF1B2EEC00E858129A73C9D39D67E434817F2FF595DA`。
- 本次通过只读检查 ZIP/XML 内容确认文件清单、模型配置和实验数据；未修改 `.spfx`。本次不构成 Simio 关闭后重新打开该文件的验证。

### 包内核验

- `Issue5_Validation` 实验定义随包保存，含 `Scenario1`、`S1_75`、`S2_75`、`S3_75`、`S0_100` 五个场景；每个场景 `ReplicationsCompleted=30`。结果文件 `Results/Model/Issue5_Validation Results.stats` 与响应结果 XML 均在包内。
- 包内含 `Resp_CT_Mean`、`Resp_CT_SD`、`Resp_Makespan`、`Resp_AvgWIP`、`Resp_MaxWIP`、`Resp_FlowTime_Mean` 等响应定义。完整 #7 统计验收不由本节代替。
- 正式模型 XML 中保留 `TN_Release` 路由配置；此前原生运行记录确认 `Prop_Policy=2` 下，`Prop_NumLines` 控制第二条线的可选路由。
- `Ent_Plane` 状态及 `Day_2Shift`、`Day_3Shift` 的中文 Description 已补齐。
- 正式模型中未发现 `Lst_TestWorker`、`MyServer1` 临时三人测试任务、旧的 80 个单人 Resource 命名对象或 12 个 ObjectList；10 个 Worker 群体保留，每群体 8 人。
- 既有原生运行记录证明 `Mechanics=3` 任务同时占用 `Wkr_L1_C1[1]`、`[2]`、`[3]`；但该专项运行日志没有进入正式包，因此本次不能声称该项可从交付包独立复核。

### 结论与边界

Issue #5 的模型配置、Flow 路由、临时测试清理、中文 Description 和型号配额实验结果已统一进入 `AIT_V0.3_FlowLine.spfx`。本轮仅做静态包核验，没有重新运行仿真或验证 Simio 关闭后重载；Worker 三人同时占用的独立运行证据仍未随包归档。#6/#7 的验收不由本次 #5 清理结论代替。

### 用户保存重载后的 MCP 验证：2026-10-24

- 用户确认已保存并重载正式包。随后本机 Simio MCP `get_active_model` 返回活动模型 `/Project/Model`；该 API 不返回项目文件名或磁盘路径，因此具体文件身份以用户的重载确认作为前提。
- `get_diagnostics` 返回 0 个错误；`get_run_status` 显示模型未处于运行模式、dispatcher idle、0 条运行警告。
- `Issue5_Validation` 显示 5 个场景均为 30/30 次完成，结果可用。逐个读取型号数量响应的 30 个 replication observations 后，各场景均满足：75 架场景为 SA101/SA102/SA103=`45/30/0`，`S0_100` 为 `45/30/25`；每项响应的最小值与最大值均等于目标值。
- `Resp_MixSeqCheck2` 在每个场景有 30 个 observations，且每场景 30 个唯一值，支持重复间抽样顺序变化的检查。
- 本次没有重跑仿真实验：重载模型中的 150 次已完成结果可由 MCP 读取并逐次核验，因此采用结果验证。没有修改或保存模型。
- 用户重载后再次保存的磁盘包复核确认：实验仍有 5 个场景和 5 组 30 次完成计数，响应结果与统计结果文件仍在包内；`TN_Release` 保留，未发现 `Lst_TestWorker`、临时三人任务、旧的 80 个 Resource 命名对象或 12 个 ObjectList。
