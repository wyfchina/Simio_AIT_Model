# Issue #11：B0–B4 原生策略切换运行验收

日期：2026-10-26。验收对象：本机 Simio MCP 活动模型 `/Project/Model`。

## 结论

**B0–B4 当前均未通过。** 五次均已实际调用原生仿真引擎，在 `TimeNow=0` 小时、`Srv_L1_C1` 处出现相同运行时错误，完工飞机数均为0。错误发生在资源关系表的行引用求值阶段，尚未进入有效的任务人数、名单优先级、正常释放或完工守恒验收。

静态诊断在运行前后均为0错误，但不能据此判定策略切换通过。此前单架Pulse成功使用的是另一路资源表绑定，不能替代本轮Flow策略表切换验收。

## 本轮测试范围

原文件：`AIT_V0.6_LaborFlex_C1PolicyPilot.spfx`，用户保存时间 `2026-10-26 15:48:00`，SHA256：

```text
764c164bd7d9c720d462c7a231ae7cca12775ced05b63c7c15bb287f2e0dfe3e
```

修改前快照：`snapshots/Issue11_NativeAcceptance_PreRun_20261026_155150/`，同时保存live配置和磁盘包校验值。

测试为线1确定性Flow试验，使用2架飞机、单线、工位容量2、缓冲0，运行上限2400小时。每次同时设置 `Prop_LaborPolicy` 和 `Prop_TasksLabor_L1`；未替换或重建任务模板，没有通过旧过程变通来制造策略通过结果。

| 用例 | Prop_LaborPolicy | Prop_TasksLabor_L1 | 实际停止错误时刻（小时） | 完工数 | 判定 |
|---|---:|---|---:|---:|---|
| Flow_B0 | 1 | Tbl_Tasks_Labor_B0_L1 | 0 | 0 | 运行时错误，未通过 |
| Flow_B1 | 2 | Tbl_Tasks_Labor_B1_L1 | 0 | 0 | 运行时错误，未通过 |
| Flow_B2 | 3 | Tbl_Tasks_Labor_B2_L1 | 0 | 0 | 运行时错误，未通过 |
| Flow_B3 | 4 | Tbl_Tasks_Labor_B3_L1 | 0 | 0 | 运行时错误，未通过 |
| Flow_B4 | 5 | Tbl_Tasks_Labor_B4_L1 | 0 | 0 | 运行时错误，未通过 |

这不是15个完整绩效场景的结果；当前基础切换机制已失败，因此本轮没有继续将线2和Pulse作为通过样本。

## 已定位的直接原因

五个线1Server的 `Task Resources Referenced Table Name` 均已设为 `Prop_TasksLabor_L1`。但是同一个Processing Tasks模板内部的资源字段仍引用原表，例如：

```text
TaskResourceRequirementsResourceType = Tbl_Tasks_Labor.ResourceType
TaskResourceRequirementsResourceListName = Tbl_Tasks_Labor.MechList
TaskResourceRequirementsSelectionGoal = Tbl_Tasks_Labor.SelectionGoal
TaskResourceRequirementsNumberOfResources = Tbl_Tasks_Labor.NumberOfResources
TaskResourceRequirementsUnitsPerResource = Tbl_Tasks_Labor.UnitsPerResource
```

当外层表选择 `Tbl_Tasks_Labor_B0_L1` 等策略表时，内层字段没有自动改为相应策略表的列；引擎无法取得原表 `Tbl_Tasks_Labor` 的有效行引用。

五次错误均指向：

```text
Object: Srv_L1_C1
Property: ProcessingTasks[1].TaskResourceRequirementsResourceType
Value: Tbl_Tasks_Labor.ResourceType
Time: 0.0 Hours
无法确定在引用表或重复组使用的行“Tbl_Tasks_Labor”。
```

原生表达式补全也显示：`Prop_TasksLabor_L1.` 仅有 `HasValue`，没有具体策略表的列成员。因此，不能未经运行证明就把子字段机械改成 `Prop_TasksLabor_L1.MechList`，或再次宣称只切换外层Table属性即可。

## 同时确认的未完成项

- 线1五个Task模板仍有 `TaskReadyAddOnProcess=Prc_LaborPolicyAcquire_C1`、`FinishedTaskAddOnProcess=Prc_LaborPolicyRelease_C1`；原生人数列又为 `Tbl_Tasks.Mechanics`。旧取人入口尚未退出，存在重复申请资源的风险。本轮在原生资源字段求值阶段已报错，不能据此声称已经完成重复申请的正常运行验证。
- 线2仍固定引用 `Tbl_Tasks_Labor_L2`，未使用 `Prop_TasksLabor_L2` 切换策略。
- 五个Pulse工作站仍固定引用 `Tbl_Tasks_Labor`，未接入本次五张策略表。
- Worker专属群组的Initial Number In System仍为5，另有12个 `Src_Init_Wkr_*` 按策略补充人数；机动组Initial Number In System为0。用户已要求最终从Task和原生配员入手，旧结构尚待替换清理，不能将它作为新方案验收通过的依据。
- 当前失败运行在0时刻中断，ResourceInfo尚不代表完整初始化后的配员。因此本轮没有据其条目数判定每线40人是否满足。

下一步首先需要解决Task内部资源字段与所选策略表保持一致的原生绑定方式，并清理旧取放入口；先在C1用B0/B1最小样本证明切换，再推广其余工位与B2–B4。五张表的名单填写结果保留有效，但整个切换方案尚未完成原生运行验证。

## 记录和恢复

每次均保存了原生错误、运行时状态、Task/ResourceUsage/ResourceInfo日志与诊断。运行时错误被MCP捕获后，先Pause再采集，随后Stop；没有让失败仿真继续运行。

- 汇总：`validation/issue11-acceptance-summary.json`。
- 五次原生记录：`validation/issue11-acceptance-Flow_B0.json` 至 `validation/issue11-acceptance-Flow_B4.json`。
- 实际模板、名单、配员与Source检查：`validation/issue11-acceptance-inspect.json`。
- 原始控制及全部15个工位的资源表绑定：`validation/issue11-acceptance-baseline.json`。
- 原生表达式补全：`validation/issue11-acceptance-completions.json`。
- 恢复读回：`validation/issue11-acceptance-restored.json`。

验收结束已恢复原有模型控制值、线1Worker日志开关和20000小时运行长度，模型停在设计态，静态诊断0错误。Simio运行编译自动将内部版本由66更新为67；其余模型属性值逐项比对一致。未改动用户保存的磁盘包，SHA256仍与上述基线相同。没有修改五张表的数据、旧资源过程或增员Source。
