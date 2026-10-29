# Issue #11 推进记录

日期：2026-10-25  
活动模型：`/Project/Model`  目标文件：`AIT_V0.6_LaborFlex.spfx`

## 已确认

- 磁盘上已有用户保存的新版本 `AIT_V0.6_LaborFlex.spfx`。
- 活动模型包含两条线共 10 个 Worker 群体，每群体 `Initial Number In System=8`；当前已读到的 C1 Task Sequence 使用 `Select From List`，固定列表为 `Lst_All_L1`，并按 `Tbl_Tasks.Mechanics` 申请人数。
- `Prop_LaborPolicy` 默认值为 1，说明尚未映射 B0–B4。
- `Tbl_Cells` 有 `HomeMechList`、`FlexMechList` 字符串字段，但当前工作站任务没有引用这些字段；其已有值也不是当前可用 ObjectList 的动态绑定。
- 原 `Lists` 集合为空。现已建立线 1 的 B0、B1、B2 候选列表：

| 用途 | ObjectList | 成员顺序 |
|---|---|---|
| B0 | `Lst_Home_C1`…`Lst_Home_C5` | 各自工位 Worker 群体 |
| B1 | `Lst_All_L1` | `Wkr_L1_C1`…`Wkr_L1_C5` |
| B2 | `Lst_Adj_C1`…`Lst_Adj_C5` | 本工位优先，其次相邻工位 |

列表只包含各 Worker 群体对象；Task 的需求数量仍应由 `Tbl_Tasks.Mechanics` 决定，后续需通过原生运行验证选择的是足够数量的 Worker 个体。

## 当前阻塞

MCP 的 `get_repeat_group_data` 显示 `Processing Tasks` 元组固定且 `canAdd=false`、`canRemove=false`，因此不能用 MCP 替换元组或把 `Resource List Name` 改成按任务列引用。当前固定列表接线可以运行，但在完成独立 `TaskResources` 关系表和原生列映射前，改变 `Prop_LaborPolicy` 不会改变实际用工策略，不能作为 B0–B4 验收。

## 后续实施路径

需要先在 Simio 原生界面或可编辑的模型定义中，将单线物理站 `Srv_L1_C1`…`Srv_L1_C5` 和脉动虚拟作业站 `Srv_P_Work_1`…`Srv_P_Work_5` 的任务资源类型改为 `Select From List`，每个工位绑定稳定的活动列表引用，并保留资源数量表达式 `Tbl_Tasks.Mechanics`。之后须证明实验每次重复中各策略实际选择了预期 Worker 集合。

策略映射建议：B0=`Prop_LaborPolicy=1`、B1=2、B2=3、B3=4、B4=5。B3 还需要每工位 6 人专属组及 10 人机动组；B4 需要 8/10/8/9/5 的静态群体容量。当前 Worker 群体人数均为 8，故这些两种策略还需加入按实验策略生效的群体规模配置（总人数仍为 40）或使用单人 Worker 群体建模。以上结构尚未实现。

## 当前模型状态

本轮新增了 B0/B1/B2 候选列表；没有创建 `Exp_B_Labor`，也没有运行任何 #11 实验。试验性 `Prop_MechList_C1` 因无效列表类型触发诊断后已删除；最终 MCP 静态诊断为 0 errors。候选 `.spfx` 尚未由 MCP 保存，需用户另存后才会进入磁盘交付包。
 
## C1 验证记录（2026-10-26）

- MCP 连接到 `/Project/Model`，Simio 版本 `20.297.56736.0`；验证前清理了暂停的旧运行，并将 `Prop_Policy` 恢复为 1、`Prop_NumLines` 恢复为 2、线 1 五个 Worker 群体的 `Log Resource Usage` 恢复为 `False`。
- 依照 Simio `ServersUsingTaskSequenceWithDataTables_FlowLine` 的关系表设计，资源明细应放在独立 `TaskResources` 表中：`TaskID` 外键指向处理任务主键，`ResourceListName` 使用 `ListName` 类型。MCP 临时建立 `Tbl_TaskResources_C1_Test`，写入 `ResourceListName=Lst_Home_C1` 成功，随后已删除；因此 `ListName` 列可以存储有效 ObjectList 名称。
- MCP 不能把该临时列的外键目标写成 `Tbl_Tasks.TaskID`，也没有暴露可写的固定 `Processing Tasks` 元组字段映射接口；不能把这次临时表测试当作正式动态策略接线。
- 对当前已有的 C1 配置做了单架、确定性、`Prop_Policy=2`、`Prop_NumLines=1` 的 Flow 运行。仿真运行至 `722.5967` 小时，1 架飞机创建并销毁，运行警告为 0；`Srv_L1_C1` 的 19 个任务均有 `ResourceUsage` 记录，`Mechanics=2/3/4/5` 的任务分别实际取得 2/3/4/5 个 Worker，日志中的资源列表为 `Lst_All_L1`，资源来自 `Wkr_L1_C1` 群体。该结果证明当前固定列表和人数表达式的资源占用正确，不证明按任务动态绑定 `Tbl_Tasks_Labor.MechList`。
- 验证结束后已停止并重置模型，临时测试表已删除，诊断为 0 errors；模型当前不应被视为已保存了本轮运行结果。

## 动态绑定候选包（2026-10-26）

- MCP 不能编辑固定的 `Processing Tasks` 元组，也不能为 MCP 创建的 `ListName` 列设置 `ListType="Object"` 元数据；直接在活动模型中继续写入会产生设计错误，因此已清理回 0 errors。
- 已基于磁盘快照生成独立候选包：`AIT_V0.6_LaborFlex_C1Dynamic.spfx`。候选包只改 C1，用关系表方式新增 `Tbl_Tasks_Labor`：`TaskID` 外键指向 `Tbl_Tasks.TaskID`，`MechList` 是 `ListName` 且 `ListType="Object"`，共 19 条 C1 任务资源行。
- C1 的资源元组映射为：`ResourceType=Tbl_Tasks_Labor.ResourceType`、`ResourceListName=Tbl_Tasks_Labor.MechList`、`SelectionGoal=Tbl_Tasks_Labor.SelectionGoal`、`SelectionExpression=Tbl_Tasks_Labor.SelectionExpression`、`NumberOfResources=Tbl_Tasks_Labor.NumberOfResources`，并设置 `ProcessingTaskResourcesReferencedTableName=Tbl_Tasks_Labor`。
- 候选包已通过 ZIP/XML 结构检查，但尚未在 Simio Desktop 中打开、诊断和原生运行；必须打开该候选包后再由 MCP 重载验证。当前活动模型仍是 `/Project/Model`，临时表已删除，诊断为 0 errors。

## 本轮动态绑定验证（2026-10-26）

- 用户已保存并在 Simio 中打开完整候选包 `AIT_V0.6_LaborFlex_AllDynamic.spfx`；活动 MCP 模型仍显示 `/Project/Model`，模型包含候选包新增的 `Tbl_Tasks_Labor_L2` 和 `Lst_Home_L2_C1..C5`。
- 重载后 MCP 诊断为 0 errors。线 1、线 2共 10 个实体工位，以及 `Srv_P_Work_1..5`，均保留 `Tbl_Tasks.OwnerCell==k` 任务过滤；线 1与补工站引用 `Tbl_Tasks_Labor`，线 2引用 `Tbl_Tasks_Labor_L2`，并分别把资源列表、资源类型、人数等字段映射到关系表列。
- 两张关系表各有 83 行。线 1 `MechList` 值为 `Lst_Home_C1..C5`；线 2 `MechList` 值为 `Lst_Home_L2_C1..C5`。后者的 `TaskID` 外键目标为 `Tbl_Tasks.TaskID`；线 2列表成员指向对应 `Wkr_L2_Ck` 群体。
- 重载后单架确定性 Flow 验证：临时将 `C1-01` 资源列表改为 `Lst_All_L1`，其余 C1 任务仍为 `Lst_Home_C1`。`ResourceUsage` 对 C1 同一运行记录了两种列表；模型警告为 0。该结果证明当前 Task Sequence 按任务读取 `Tbl_Tasks_Labor.MechList`。
- 线 2原生验证：临时将 Flow 路由权重改为强制选线 2，1 架确定性飞机运行时 `Srv_L2_C1` 的 19 个任务均有资源使用记录，列表均为 `Lst_Home_L2_C1`，所选资源来自 `Wkr_L2_C1`，运行警告为 0。该结果证明线 2引用关系表和列表生效。
- 两次测试后均恢复了关系表试验行、路由权重、`Prop_Policy=1`、`Prop_NumLines=2`、`Prop_NumPlanes=1`、确定性设置及 Worker 日志开关；当前模型在设计态，未运行，诊断仍为 0 errors。
- `Prop_LaborPolicy` 仍只是保留值（当前为 1），并未切换 B0–B4；完整包目前用的是 B0 专属列表。尚未建立 `Exp_B_Labor`，也未实现 B1 全池、B2 相邻借调、B3 机动组、B4 静态重配的策略切换和实验比较。因此动态列表读取已验证，Issue #11 尚未闭环。

## Prop_LaborPolicy 切换验收（2026-10-26）

- 静态引用检查：模型中 `Prop_LaborPolicy` 只出现在属性定义，无列表、表格、Process、Server 或 Experiment 引用；`Exp_B_Labor` 不存在。
- 在相同工况下依次测试 `Prop_LaborPolicy=1..5`：`Prop_Policy=2`（Flow）、`Prop_NumLines=1`、`Prop_NumPlanes=1`、`Prop_Deterministic=True`。每个值都运行一架飞机并检查 C1 的 `ResourceUsage`。
- 五次运行每次均有 49 条 C1 资源占用记录，涉及 19 个 C1 TaskID；所有记录的 `ResourceList` 均为 `Lst_Home_C1`，Worker 群体均为 `Wkr_L1_C1`。各次运行警告数为 0。
- 结论：`Prop_LaborPolicy` 的 1–5 数值变更没有改变实际资源列表或 Worker 群体，B0–B4 策略切换验收失败（尚未实现）。
- 验收后恢复 `Prop_LaborPolicy=1`、`Prop_Policy=1`、`Prop_NumLines=2`、`Prop_NumPlanes=1`、`Prop_Deterministic=True` 和 Worker 日志开关；活动模型回到设计态，诊断为 0 errors。

## Skip Requirement Condition 试点验收（2026-10-26）

- 用户在 `Srv_L1_C1` 的固定 `Processing Tasks` 元组中，将 `TaskResourceRequirementsSkipRequirementCondition` 绑定到 `Tbl_Tasks_Labor.SkipRequirementCondition`；MCP 重新读取确认绑定已保存。`Tbl_Tasks_Labor` 新增了 `Expression` 类型列 `SkipRequirementCondition`，原有 83 行的默认值为 `0.0`。
- 为验证属性条件能否在多条同任务资源行之间实现互斥，仅对 C1 的 19 个任务临时追加 B1（`Lst_All_L1`）和 B2（`Lst_Adj_C1`）候选行。B0/B1/B2 行的跳过表达式分别为 `Prop_LaborPolicy!=1`、`Prop_LaborPolicy!=2`、`Prop_LaborPolicy!=3`；静态诊断为 0 errors。
- 单架确定性 Flow 运行，`Prop_LaborPolicy=1`，运行到 722.5967 小时，警告为 0。C1 共记录 98 条资源占用：`Lst_Home_C1` 49 条、`Lst_All_L1` 32 条、`Lst_Adj_C1` 17 条，涉及 19 个任务。三个名单均被实际使用，未形成互斥策略选择；B0/B1/B2 切换机制试点失败。
- 试验后删除了 38 条临时候选行，`Tbl_Tasks_Labor` 恢复为原 83 行；C1-01 的资源名单恢复为 `Lst_Home_C1`，跳过条件恢复为 `0.0`。恢复后的诊断为 0 errors，模型处于设计态；测试参数恢复为 `Prop_LaborPolicy=1`、`Prop_Policy=1`、`Prop_NumLines=2`、`Prop_NumPlanes=1`、`Prop_Deterministic=True`，Worker 日志关闭。
- 当前只确认了固定任务元组可读取跳过条件列，尚未找到让重复任务外键资源行按策略互斥生效的配置方式。B0–B4 仍未接通；不可将此次字段绑定或试点当作策略实现完成。

## C1 用工策略流程原型（2026-10-26）

- 本轮活动模型：`/Project/Model`，Simio `20.297.56736.0`。连接可用；活动模型诊断为 0 errors，未处于运行状态。
- 建立磁盘回退副本：`snapshots/AIT_V0.6_LaborFlex_AllDynamic_PreIssue11ListExpr_20261026.spfx`。副本与源文件 `AIT_V0.6_LaborFlex_AllDynamic.spfx` 的 SHA-256 均为 `EA437955719824E4AFF2212F2F363EA540F005FCADE1EEA38A7F44660EBDC590`。
- 验证 `ListName` 表列不能直接保存 `Math.If(Prop_LaborPolicy,...列表引用...)`：对 `Tbl_Tasks_Labor` 的 `C1-01.MechList` 临时写入该表达式后，Simio 诊断报错“表达式未解析为列表引用”。随后已恢复 `Lst_Home_C1`，`SkipRequirementCondition=0.0`，诊断恢复为 0 errors；没有改动其他任务行。
- 新建独立候选包：`AIT_V0.6_LaborFlex_C1PolicyPilot.spfx`，SHA-256 为 `B7AEC8563643926C0A5D7AEC3CDD4C4CC2CE90FF7461CA2B24EE9E7319B6C8B7`。源包未被覆盖。
- 候选包对 `Srv_L1_C1` 的 `Processing Tasks` 增加 `TaskReadyAddOnProcess=Prc_LaborPolicyAcquire_C1` 和 `FinishedTaskAddOnProcess=Prc_LaborPolicyRelease_C1`。C1 的 19 条 `Tbl_Tasks_Labor` 行将 `SkipRequirementCondition` 设为 `Prop_LaborPolicy<=3`：策略 1–3 由任务就绪过程按固定名单取得 `Tbl_Tasks.Mechanics` 人数；策略 4–5 暂不跳过原生资源要求，使用既有 B0 名单作为安全回退。
- B0/B1/B2 的名单依次是 `Lst_Home_C1`、`Lst_All_L1`、`Lst_Adj_C1`。B2 名单顺序已确认是 `Wkr_L1_C1` 优先、`Wkr_L1_C2` 次之。任务完成过程使用 `SeizedResourcesFilterType=Task` 和 `Token.Task()`，仅释放当前任务通过 `Lst_All_L1` 持有的资源。
- 已检查候选包 ZIP/XML 结构：两个过程文件均存在且格式良好；Srv 绑定和 19 条跳过条件与设计一致。**候选包尚未在 Simio Desktop 中加载或运行**，因此 Worker 实际分配、Task 上下文释放、并行任务相互隔离和诊断结果仍待原生验收。当前活动 `/Project/Model` 未应用候选包修改。
- 本原型只覆盖 C1 的 B0/B1/B2 机制试验，不代表 B0–B4 已全部实现。B3 机动组、B4 静态重配、L2、其他工位及脉动补工站仍未接入；候选包需先在 Simio 中加载并完成诊断和单架确定性日志验证，再决定是否推广。

## 已废弃候选方案记录（2026-10-26）

> 以下内容仅保留为方案沿革，已被用户指出的 `Selection Condition` 语义问题和后续 C1 流程原型取代，不应照此实施。特别是，不把 `SelectionCondition` 当作逐个候选 Worker 的筛选条件，也不把表达式写入 `ListName` 字段；本轮验证已确认后者不能解析为名单引用。当前有效原型以本节前的“C1 用工策略流程原型”为准。

重复 `TaskID` 资源行加 `Skip Requirement Condition` 已证明不能实现互斥选择，因此采用“固定全池名单 + 候选 Worker 条件筛选”的单资源要求结构。

### Task Sequence 配置

- 线 1 的所有任务及 `Srv_P_Work_1..5`：`Resource Type=Select From List`，`Resource List Name=Lst_All_L1`。
- 线 2 的所有任务及对应补工站：`Resource List Name=Lst_All_L2`。
- 每个任务只保留一条资源要求；`Number Of Resources=Tbl_Tasks.Mechanics`，`Units Per Resource=1`，`Must Simultaneously Seize=True`，`Selection Goal=Preferred Order`，`Value Expression=Candidate.Object.Capacity.Remaining`。
- `Tbl_Tasks_Labor` 与 `Tbl_Tasks_Labor_L2` 增加 `SelectionCondition`（Expression）列，并把固定任务元组的 **Selection Condition** 绑定到该列。`Skip Requirement Condition` 保持空白或 `0.0`，不再承担策略切换。

### 选择条件表达式

表达式使用当前任务的 `Tbl_Tasks.OwnerCell` 和候选对象的 `Candidate.Object.Name()`。以下为线 1 模板；线 2 将名称前缀替换为 `Wkr_L2_`，并使用 `Lst_All_L2`。

```text
(Prop_LaborPolicy==1 && Candidate.Object.Name()==Math.If(Tbl_Tasks.OwnerCell==1,"Wkr_L1_C1",Math.If(Tbl_Tasks.OwnerCell==2,"Wkr_L1_C2",Math.If(Tbl_Tasks.OwnerCell==3,"Wkr_L1_C3",Math.If(Tbl_Tasks.OwnerCell==4,"Wkr_L1_C4","Wkr_L1_C5")))))
|| Prop_LaborPolicy==2
|| (Prop_LaborPolicy==3 && Math.Abs(Tbl_Tasks.OwnerCell-1)<=1 && Candidate.Object.Name()!="Wkr_L1_C5")
```

实际 B2 条件应按五个工位分别写成邻接名单，避免把 C5 的边界情况混入通用表达式：

```text
C1: Candidate.Object.Name()=="Wkr_L1_C1" || Candidate.Object.Name()=="Wkr_L1_C2"
C2: Candidate.Object.Name()=="Wkr_L1_C1" || Candidate.Object.Name()=="Wkr_L1_C2" || Candidate.Object.Name()=="Wkr_L1_C3"
C3: Candidate.Object.Name()=="Wkr_L1_C2" || Candidate.Object.Name()=="Wkr_L1_C3" || Candidate.Object.Name()=="Wkr_L1_C4"
C4: Candidate.Object.Name()=="Wkr_L1_C3" || Candidate.Object.Name()=="Wkr_L1_C4" || Candidate.Object.Name()=="Wkr_L1_C5"
C5: Candidate.Object.Name()=="Wkr_L1_C4" || Candidate.Object.Name()=="Wkr_L1_C5"
```

每个工位的最终条件是：B0 条件、本工位对应的 B2 条件、B1 的 `Prop_LaborPolicy==2`，以及 B3/B4 条件按下表组合。不能用一条不区分 `OwnerCell` 的通用 B2 表达式替代五个工位条件。

例如，线 1 工位 C1 的 `SelectionCondition` 完整表达式为：

```text
(Prop_LaborPolicy==1 && Candidate.Object.Name()=="Wkr_L1_C1")
|| (Prop_LaborPolicy==2)
|| (Prop_LaborPolicy==3 && (Candidate.Object.Name()=="Wkr_L1_C1" || Candidate.Object.Name()=="Wkr_L1_C2"))
|| (Prop_LaborPolicy==4 && (Candidate.Object.Name()=="Wkr_L1_C1" || Candidate.Object.Name()=="Wkr_L1_Float"))
|| (Prop_LaborPolicy==5 && Candidate.Object.Name()=="Wkr_L1_C1")
```

C2–C5 只需替换各分支中的工位名单；B1 分支始终为 True。线 2 使用相同结构，将 `Wkr_L1_` 替换为 `Wkr_L2_`，并绑定 `Lst_All_L2`。这条表达式应写入该工位任务行对应的 `SelectionCondition` 单元格，而不是写入 `SkipRequirementCondition` 或 `SelectionGoal`。

| 策略 | `Prop_LaborPolicy` | 候选条件 |
|---|---:|---|
| B0 | 1 | 仅本工位 Worker 群组 |
| B1 | 2 | 线内全池，条件恒为 True |
| B2 | 3 | 本工位及相邻工位 Worker 群组 |
| B3 | 4 | 本工位 Worker 群组 + 本线机动组 |
| B4 | 5 | 本工位 Worker 群组；人数按静态重配公式变化 |

### Worker 人数

每个 Worker 群组仍是一个 Worker 对象，`Initial Number In System` 使用属性表达式；不创建单人 Resource，也不复制 80 个资源。线 1 和线 2分别建立一个机动群组 `Wkr_L1_Float`、`Wkr_L2_Float`，每组最多 10 人，并加入对应的全池 ObjectList。

```text
Wkr_L1_C1: Math.If(Prop_LaborPolicy==4,6,Math.If(Prop_LaborPolicy==5,8,8))
Wkr_L1_C2: Math.If(Prop_LaborPolicy==4,6,Math.If(Prop_LaborPolicy==5,10,8))
Wkr_L1_C3: Math.If(Prop_LaborPolicy==4,6,Math.If(Prop_LaborPolicy==5,8,8))
Wkr_L1_C4: Math.If(Prop_LaborPolicy==4,6,Math.If(Prop_LaborPolicy==5,9,8))
Wkr_L1_C5: Math.If(Prop_LaborPolicy==4,6,Math.If(Prop_LaborPolicy==5,5,8))
Wkr_L1_Float: Math.If(Prop_LaborPolicy==4,10,0)
```

线 2 使用同样的人数公式。B0、B1、B2 的总人数为 40；B3 为 5×6+10=40；B4 为 8+10+8+9+5=40。B3 的候选条件必须包含对应 `Wkr_L*_Float`，B4 不包含机动组。

### 验收顺序

1. 先只改 `Srv_L1_C1`：固定全池名单、绑定 `SelectionCondition`，验证 `Prop_LaborPolicy=1/2/3` 的资源日志分别只出现预期 Worker 群组。
2. 再增加机动群组并验证 B3；检查每组实际初始人数为 6/10。
3. 验证 B4 的 8/10/8/9/5 人数及总人数守恒。
4. 推广到线 1 其他工位、线 2 和 `Srv_P_Work_*`，最后建立 `{A1,A4,BASE}×{B0..B4}` 的 `Exp_B_Labor`。

在第 1 步的日志互斥验收通过前，不推广到全模型，也不宣称 `Prop_LaborPolicy` 已接通。

## L1 整线 B0–B2 原生验收（2026-10-26）

- 活动模型：`/Project/Model`；用户已保存当前候选文件 `AIT_V0.6_LaborFlex_C1PolicyPilot.spfx`。
- 为保留固定 `Processing Tasks` 元组的现有绑定，将共享取人过程改为按 `Token.ContextObject` 识别 `Srv_L1_C1` 至 `Srv_L1_C5`，再按 `Prop_LaborPolicy` 选择本站 B0 名单、`Lst_All_L1` 或本站 B2 相邻名单。五个 Server 共用原生释放过程；该过程按 `Token.Task` 过滤，并在 `Lst_All_L1` 范围内释放当前任务资源。
- `Tbl_Tasks_Labor` 的 83 行 `NumberOfResources` 均设为 `Math.If(Prop_LaborPolicy<=3,0,Tbl_Tasks.Mechanics)`，使 B0–B2 由取人过程按 `Tbl_Tasks.Mechanics` 取得 Worker，避免任务序列重复申请。C2–C5 任务行的 `MechList` 保持其原专属名单，属性条件 B0–B2 下由该表达式抑制任务序列内置人数请求。
- `Prop_Policy=2`（Flow）、`Prop_NumLines=1`、`Prop_NumPlanes=1`、`Prop_Deterministic=True` 下依次完成 B0、B1、B2 原生运行。三次运行各有 204 条 `ResourceUsage` 记录，覆盖全部 83 个 TaskID；五站任务数均为 `19/20/19/20/5`。逐任务实际不同 Worker 数与 `Tbl_Tasks.Mechanics` 完全一致，未结束的资源占用记录为 0，运行警告均为 0。
- 日志名单核对：B0 的 C1–C5 分别为 `Lst_Home_C1`…`Lst_Home_C5`；B1 五站均为 `Lst_All_L1`；B2 五站分别为 `Lst_Adj_C1`…`Lst_Adj_C5`。
- 验收后 `Prop_LaborPolicy` 恢复为 1，L1 五个 Worker 群组的 `Log Resource Usage` 恢复为 False；模型已停止，静态诊断为 0 errors。

### Issue #11 尚未闭环

- 本轮只验证 L1、单架、Flow、B0–B2 的策略机制；L2 与 `Srv_P_Work_1..5` 尚未接入并验证策略。
- B3 机动组尚不存在（搜索不到 `Wkr_L1_Float`/`Wkr_L2_Float`）；B4 的 8/10/8/9/5 静态配员也未实现。
- 尚未建立 `Exp_B_Labor`。Issue #11 要求的 `{A1,A4,BASE} × {B0..B4}` 15 场景、公共随机数、CT/Makespan/WIP/利用率及 BASE 补工相关响应均未完成。
- 尚未计算相对 B1 上界的收益比例，也未统计跨工位调用次数或依据结果完成策略推荐。因此本轮证明的是 L1 Flow 上 B0–B2 可切换和按任务正确占用 Worker，不是 Issue #11 全部完成。

## B3/B4 配员与 A4 试跑（2026-10-26）

- 活动模型仍为 `/Project/Model`。检查时模型诊断 0 errors，仿真已停止。B3/B4 的 L1 TaskReady 过程会先按名单取人，而 `Tbl_Tasks_Labor.NumberOfResources` 在策略 4/5 又返回 `Tbl_Tasks.Mechanics`，Task Sequence 会重复申请同一任务所需人数；原始 B3 试跑因此在 C1 等待到运行终点，飞机未完工。约束日志显示重复的资源可用性等待。
- 为隔离验证 L1 自定义取人过程，临时将 `Tbl_Tasks_Labor` 83 行的 `NumberOfResources` 设为 0。B3、B4 测试后已将 83 行全部恢复为原表达式 `Math.If(Prop_LaborPolicy<=3,0,Tbl_Tasks.Mechanics)`；不能把临时置零当成正式修复，因为 `Srv_P_Work_1..5` 也引用这张表但还没有 TaskReady 取人过程。
- B3 单架、单线确定性 Flow：83 个任务 ID、204 条 ResourceUsage 记录、未结束占用 0；完工数 1、最终 WIP 0、警告 0。占用名单均为对应 `Lst_Float_C1..C5`。单架没有争用，故未调用 Float 个体。
- B4 单架、单线确定性 Flow：同样完成 83 个任务、204 条资源记录，未结束占用 0；完工数 1、最终 WIP 0、警告 0。ResourceUsage 只出现 `Lst_Home_C1..C5`。ResourceInfo 按“群组对象行 + 个体行”计数，得到本站个体人数 `8/10/8/9/5`，Float 为 0。
- B3 A4 型两架确定性 Flow（`Prop_CellCap=2`、`Prop_NumPlanes=2`、单线）：初次结果暴露 `Src_Init_Wkr_L1_Float.EntityType` 错指向 `Wkr_L2_Float`，导致 L1 Float 未生成、L2 Float 多生成 10 人。已在活动模型将其改为 `Wkr_L1_Float`。修正后两架均完工，最终 WIP 0、警告 0、408 条 ResourceUsage 全部结束；ResourceInfo 显示 L1 五个专属群组各 6 人、L1 Float 10 人，且 ResourceUsage 有 265 条由 L1 Float 承担。此结果证明修正后的机动名单在容量 2 的两架测试中实际参与工作。
- 本轮结束时已恢复测试控制值为 `Prop_Policy=1`、`Prop_CellCap=1`、`Prop_NumLines=2`、`Prop_NumPlanes=1`、`Prop_Deterministic=True`、`Prop_LaborPolicy=1`，关闭 L1 Worker 的 `Log Resource Usage`。`Src_Init_Wkr_L1_Float` 的实体类型修正保留在 live 模型中；用户尚未确认保存到磁盘。
- 仍未完成：L1 的正式 B3/B4 不可在保留当前任务人数表达式时运行，必须先统一“自定义取人负责全部策略、原生人数请求置零”的架构，并为所有使用 `Tbl_Tasks_Labor` 的 Pulse 工位接入取人/释放过程；L2 与五个 Pulse 工位也未验证策略切换。15 场景 `Exp_B_Labor`、CRN 设置、绩效响应、BASE traveled 人时/离线未完工/真实完工时间、上界收益比例及推荐均尚未完成。

## L2 名单准备与恢复状态（2026-10-26）

- 检查了 5 个 `Srv_L2_C1..C5` 与 5 个 `Srv_P_Work_1..5` 的固定 `Processing Tasks`。L2 仍只绑定 `Tbl_Tasks_Labor_L2` 的 Task Sequence 资源字段，没有 TaskReady 取人过程或 Finished 释放过程；Pulse 工位共用 `Tbl_Tasks_Labor`，当前只保留 `Prc_Pulse_TaskFinishedStats` 完工统计回调，没有用工策略取人过程。
- 为后续接线建立并校验了线 2 名单：`Lst_All_L2`、`Lst_Adj_L2_C1..C5`、`Lst_Float_L2_C1..C5`。全池含五个线 2 专属 Worker 群组及 `Wkr_L2_Float`；相邻名单按本站优先、左右相邻次序；机动名单按本站优先、线 2 Float 次序。MCP 诊断为 0 errors。
- 随后再次尝试将 L1 共享取人流程克隆为 L2 版本；本地 MCP helper 在传递长 XML 时触发 Python `StandardOutputEncoding is only supported when standard output is redirected`，模型未创建新过程。搜索确认 `Prc_LaborPolicyAcquire_L2` 不存在，诊断仍为 0 errors。该接线未完成。
- 曾试验复制 L1 取人/释放流程为 L2 版本；释放流程因重复资源释放元组及名单引用错误触发诊断。两个试验流程均已删除，最终诊断恢复为 0 errors，且没有绑定到任何 Server。L2 的正式任务元组仍未变更。
- 当前活动模型保留两项可用修改：`Src_Init_Wkr_L1_Float.EntityType=Wkr_L1_Float` 的错配修正，以及上述 L2 名单。它们尚未由用户保存到磁盘。
- 本轮最终状态：模型已停止并退出 Run Mode；`Prop_Policy=1`、`Prop_CellCap=1`、`Prop_NumLines=2`、`Prop_NumPlanes=1`、`Prop_Deterministic=True`、`Prop_LaborPolicy=1`；L1 Worker 资源日志关闭；`Tbl_Tasks_Labor` 83 行人数公式已恢复为 `Math.If(Prop_LaborPolicy<=3,0,Tbl_Tasks.Mechanics)`；静态诊断 0 errors。
- Issue #11 尚不能闭环。尤其 BASE 下的需求资源归属必须继续按 `OwnerCell` 核验，不能仅因 `Srv_P_Work_k` 名称为 k 就默认资源归属为 k；否则无法正确统计和分配已 traveled 的工作订单。

## Task 关系表切换方案试点（2026-10-26）

- 重新评估了“同一任务五条资源行 + `SkipRequirementCondition`”方案。该结构与此前 C1 试验相同；此前日志证明多条资源行会同时参与，不能作为策略互斥机制，故不再采用。
- 试验了更简洁的 Task 方案：由模型 `Table` 属性引用一张固定的 `Tbl_Tasks_Labor_B0_L1`，再由 Experiment 场景控制该属性切换 B0–B4 关系表。Simio Server 接受 `Table` 类型属性作为 `Task Resources Referenced Table Name` 的引用，说明该方向在原生模型中可行。
- MCP 创建的临时 B0 表无法完整复制现有表的 `ListName` Object 元数据；写入 `Lst_Home_C1` 后报“无效的列表类型”。MCP 也不能原位修改固定 `Processing Tasks` 元组中的 Add-On 过程绑定。临时表、临时属性和 C1 表引用均已撤销，最终诊断恢复为 0 errors。
- 正式实施应在 Simio 原生界面复制/建立五张具有正确 `ListName(Object)` 元数据和 `TaskID -> Tbl_Tasks.TaskID` 外键的关系表，再建立 `Prop_TasksLabor_L1`、`Prop_TasksLabor_L2` 两个 Table 属性；各 Server 的 Task Resources Referenced Table Name 绑定对应属性，Experiment 场景分别把属性设为 B0–B4 表。这样 Task Sequence 是唯一取人/释放入口，不需要 Source 或取人 Process。

## 用户建立的五张策略表：MechList 填写核验（2026-10-26）

- 本轮用户要求：在已建立的五张策略表上填写各任务对应的 `MechList`。通过本机 Simio MCP 操作活动模型 `/Project/Model`；检查与修改时模型均处于设计态，没有启动仿真。
- 确认五张表为 `Tbl_Tasks_Labor_B0_L1` 至 `Tbl_Tasks_Labor_B4_L1`，每张 83 行，`MechList` 均为现有 `ListName` 列。没有新增同名列或使用未定义的 `Ck` 名称。
- 按 `TaskID` 查主任务表 `Tbl_Tasks.OwnerCell` 确定责任工位，填写如下实际列表。每表工位任务行数为 19/20/19/20/5。

| 表 | 工位1 | 工位2 | 工位3 | 工位4 | 工位5 |
|---|---|---|---|---|---|
| Tbl_Tasks_Labor_B0_L1 | Lst_Home_C1 | Lst_Home_C2 | Lst_Home_C3 | Lst_Home_C4 | Lst_Home_C5 |
| Tbl_Tasks_Labor_B1_L1 | Lst_All_L1 | Lst_All_L1 | Lst_All_L1 | Lst_All_L1 | Lst_All_L1 |
| Tbl_Tasks_Labor_B2_L1 | Lst_Adj_C1 | Lst_Adj_C2 | Lst_Adj_C3 | Lst_Adj_C4 | Lst_Adj_C5 |
| Tbl_Tasks_Labor_B3_L1 | Lst_Float_C1 | Lst_Float_C2 | Lst_Float_C3 | Lst_Float_C4 | Lst_Float_C5 |
| Tbl_Tasks_Labor_B4_L1 | Lst_Home_C1 | Lst_Home_C2 | Lst_Home_C3 | Lst_Home_C4 | Lst_Home_C5 |

- B0、B4 原值已正确，实际变更 0 格；B1、B2、B3 各变更 83 格，共 249 格。已读回核对全部 415 行的名单，以及其余列和行数保持一致。名单定义本轮未改动。
- 修改前保存五张表及列表的 live JSON 快照，同时复制磁盘 `AIT_V0.6_LaborFlex_C1PolicyPilot.spfx` 并记录 SHA256；位置为 `snapshots/Issue11_MechList_PreFill_20261026_152523/`。磁盘副本不代表尚未保存的 live 变更。
- 证据：`validation/issue11-mechlist-before.json`、`validation/issue11-mechlist-after.json`、`validation/issue11-mechlist-discovery.json`；执行脚本为 `validation/issue11_fill_mechlists.py`。
- 修改前后诊断均为 38 条，全部为已有的 `TableProperty1` 和 `Prop_TasksLabor_L2` 必填表引用为空，本轮没有新增错误，也没有修改这些属性或实验场景。
- 检查另发现 `Lst_All_L1` 含重复的五个专属 Worker 群组引用及一个 Float 引用，共 11 项；本轮只按用户要求填写名单列，没有清理该列表，后续全池策略运行前需核对。五张表的 `SelectionGoal` 行值仍为 `SmallestDistance`，本轮没有改为本站优先所需的选择规则。
- 本轮完成的是线 1 五张表的名单填写；尚未验证 Table 属性切换是否同步切换 Task 的列引用，未验证 B3/B4 人数配置或运行策略，也未建立线 2 五张策略表。本轮结果不构成 Issue #11 闭环。live 修改尚需用户在 Simio 中保存。

## 后续配置错误已修订（2026-10-26）

- 已将 `Prop_TasksLabor_L1`、`Prop_TasksLabor_L2` 的默认值分别补为 `Tbl_Tasks_Labor_B0_L1`、`Tbl_Tasks_Labor_L2`，18个既有场景的空值随默认值修复；其他控制值、Active及重复次数逐项核对保持原值。静态诊断由38条降为0条。
- 已重建并迁移 `Lst_All_L1` 的引用，最终仅含五个线1专属群组和一个机动群组，各出现一次，原重复名单及清理过程的追加项均已清除。保留机动群组以兼容旧释放范围；B1场景机动人数必须为0。没有增加取人过程或增员Source。
- 五张线1策略表全部415行和字段默认的 `SelectionGoal` 改为 `PreferredOrder`，名单与其他数据列保持原值，并补充相关字段的中文说明。
- 使用既有单架确定性Pulse参数完成原生试跑：飞机完工1架，订单生成5、完成5，警告0。已停止并返回设计态，最终诊断0。这个样本不构成策略表切换或B3/B4验收；Pulse下Flow专用 `St_WIP=-1` 是已记录的统计口径边界，未将其视为有效Pulse WIP。
- 完整范围、证据和未完成内容见 `docs/issue-11-configuration-fixes-20261026.md`。本轮live修改尚需用户保存，Issue #11仍未闭环。

## 保存后的 B0–B4 原生运行验收：均未通过（2026-10-26）

- 用户已保存磁盘包（15:48，SHA256 `764c164bd7d9c720d462c7a231ae7cca12775ced05b63c7c15bb287f2e0dfe3e`）。已备份后对线1进行五次确定性Flow试验：2架、容量2、缓冲0，每次同时选择相应用工策略和策略表。
- 五次均在0小时、`Srv_L1_C1.ProcessingTasks[1].TaskResourceRequirementsResourceType` 报相同原生运行错误。外层资源关系表为 `Prop_TasksLabor_L1`，内层仍引用 `Tbl_Tasks_Labor.ResourceType`；切换外层表并不会自动切换子字段的行引用。五项均未通过，不能声称已完成B0–B4切换。
- 表属性表达式补全仅有HasValue，没有具体表的列，不能直接假定 `Prop_TasksLabor_L1.MechList` 能解决此问题。原先的“只切换Table属性”方案已由本轮运行证明不完整，必须先解决原生Task资源字段绑定。
- 同时确认旧取放Process仍绑定在线1任务，12个增员Source仍存在；线2和Pulse的资源表尚未切换到策略表。当前失败样本不构成名单、人数、释放或每线40人的有效验收。
- 五次错误及原生日志均已留存。已Stop并恢复模型原有控制值、日志开关和运行长度；最终静态诊断0，磁盘包未改动。详见 `docs/issue-11-native-policy-acceptance-20261026.md` 及 `validation/issue11-acceptance-summary.json`。

