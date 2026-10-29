# Issue #11 策略表配置错误修订记录

日期：2026-10-26。操作对象：Simio 活动模型 `/Project/Model`，本机 MCP 地址 `http://localhost:51310`。

本轮已修复表引用为空、线1全池名单重复和策略表的选择规则错误。静态诊断由 38 条错误降为 0 条。随后按修改前已有的单架确定性 Pulse 控制值完成一次原生仿真：飞机完工数 1、工作订单生成数 5、完成数 5，运行警告 0。仿真结束后已调用 Stop，模型返回设计态，可由用户保存。

## 表引用必填错误

用户已将原 `TableProperty1` 属性更名为 `Prop_TasksLabor_L1`，但默认表仍为空；诊断信息仍使用原名称。线2属性 `Prop_TasksLabor_L2` 的默认表也为空。这两项导致模型及18个既有实验场景各产生两项必填错误，共38项。

修订默认值与当前值：

| 属性 | 修订后的默认表 |
|---|---|
| Prop_TasksLabor_L1 | Tbl_Tasks_Labor_B0_L1 |
| Prop_TasksLabor_L2 | Tbl_Tasks_Labor_L2 |

默认值已传递到18个既有场景；逐场景读回确认其余控制值、Active、要求重复数及已有完成重复数均与修改前相同。两项属性已补充中文说明。此修订只解决有效的表引用，不代表Server已完成按场景切换全部Task字段的接线。

## 全池名单去重

原 `Lst_All_L1` 有11项：线1五个专属Worker群组各出现两次，另有机动群组一次。MCP `set_list_data` 虽说明为替换，实际会追加；首次清理读回发现变成17项后，已停止使用该接口覆盖既有名单。

最终通过原生MCP暂存旧名单、新建同名名单、迁移引用再清理暂存名单，得到以下6个不重复群组：

```text
Wkr_L1_C1
Wkr_L1_C2
Wkr_L1_C3
Wkr_L1_C4
Wkr_L1_C5
Wkr_L1_Float
```

保留机动群组是为了兼容现有释放过程的名单范围；B1场景中机动群组人数必须为0，线内总人数仍须为40。名单条目数不等于实际工人人数。

已迁移并核对83个B1表单元格、5个旧取人步骤的资源元组和1个旧释放步骤的资源元组。旧取人过程的5个B1步骤原名称重复，现按工位1–5分别命名，便于唯一寻址；过程ID连接和资源需求表达式保持原逻辑。所有迁移元组逐字段读回，除名单引用对象外保留原值；旧暂存名单已删除，引用搜索无残留。没有创建新的取人过程或增员Source。

## 策略表选择规则

`Tbl_Tasks_Labor_B0_L1` 至 `Tbl_Tasks_Labor_B4_L1` 的 `SelectionGoal` 原为 `SmallestDistance`。已将全部415行及字段默认值改为原生枚举 `PreferredOrder`，并补充 `SelectionGoal`、`MechList` 字段中文说明。

B2名单保持本站在前、相邻工位在后；B3名单保持本站在前、机动群组在后。逐行比对确认TaskID、MechList、NumberOfResources、UnitsPerResource及其他数据列未改变。

## 原生运行与证据边界

运行使用修改前已有的控制值，没有临时修改场景：`Prop_Policy=1`、`Prop_LaborPolicy=1`、`Prop_NumPlanes=1`、`Prop_NumSA103=0`、`Prop_NumLines=2`、`Prop_CellCap=1`、`Prop_Buffer=0`、`Prop_Deterministic=True`。按原有20000小时运行长度完成，读取统计和运行时状态后停止。模型控制值已与运行前逐项比较一致。

在 `TimeNow=20000` 小时读取：

| 状态 | 值 |
|---|---:|
| St_CompletedCount | 1 |
| St_WOGenerated | 5 |
| St_WOCompleted | 5 |

这次试跑证明修订后的当前模型可以编译、启动并完成当前单架Pulse样本，不能作为B0–B4策略表切换的运行验收。Task日志当前未启用，结果中没有逐任务日志行，因此本轮没有声称已验证逐任务的Worker分配。

同时读到Pulse运行末值 `St_WIP=-1`。这是 `docs/issue-10-validation.md` 已记载的Flow专用WIP边界不适用于Pulse的问题，本轮未改其统计口径，未将该数值视为有效Pulse WIP。

Issue #11仍需完成原生Task策略表切换接线、B3/B4场景人数配置、旧增员Source和额外取放过程清理、两线与Pulse用工验证，以及15场景实验及分析。当前表引用有值和诊断为0，不代表这些工作已经完成。

## 保存与复核材料

本轮修改只在live模型中实施，没有覆盖用户磁盘模型。修改前磁盘包及SHA256位于 `snapshots/Issue11_Configuration_PreFix_*`，详细live配置也保存在该目录；磁盘副本不包含当时尚未保存的界面修改。

- 修订前配置：`validation/issue11-configuration-inspect.json`。
- 修订后配置及18场景核验：`validation/issue11-configuration-fixed.json`。
- 名单迁移前后：`validation/issue11-list-repair-before.json`、`validation/issue11-list-repair-after.json`。
- 原生运行参数：`validation/issue11-repair-smoke-before.json`。
- 原生运行统计、工作订单守恒、Stop及最终诊断：`validation/issue11-repair-smoke-results.json`。

Computer Use本轮两次返回本机管道不存在，未执行界面点击；全部最终模型修改均通过Simio MCP完成。尚需用户保存当前模型并重载，才能核实最终磁盘交付包。
