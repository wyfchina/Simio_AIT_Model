# Issue #5 实施与验收记录（2026-10-23）

> 历史实施记录。本文记录的是 2026-10-23 当时的版本和验收状态；当前交付包已更新为根目录 `AIT_V0.3_FlowLine.spfx`。请以 [`issue-5-validation.md`](issue-5-validation.md) 的“正式包统一复核：2026-10-24”为当前文件状态，不要将本文的旧文件名、旧哈希或旧结论用于最终交付判断。

## 结论

Issue #5 的模型要求已完成并通过本次原生实验验收。完成范围仅为 #5。

活动模型：`/Project/Model`。交付文件：`AIT_V0.2_Skeleton.spfx`。

## 投放与型号抽样

- `MySource1` 的 Created Entity 触发器绑定 `Prc_飞机创建初始化`；源每次实验按 `Prop_NumPlanes` 创建飞机。`OnRunInitialized` 中用户配置的 `RemainSA103 = Prop_NumSA103` 仍保留。
- 初始化流程按剩余配额概率分支：`RemainSA101 / 总剩余` 选择 SA101；否则按 `RemainSA102 / (RemainSA102 + RemainSA103)` 选择 SA102 或 SA103。抽中后扣减对应配额。两个 Decide 使用专用随机流 101。
- 每架飞机设置 `CurLoc=0`，按创建顺序递增 `NextPlaneID` 并写入 `PlaneID`；同时累计三个型号计数和两个顺序校验和。
- 原型实验 `Issue5_Validation` 有 5 个活动场景、每场景 30 次重复，共 150 次，均完成且无实验错误。所有重复均完成至 336 小时。

| 场景 | 批量 | SA101 | SA102 | SA103 | 重复验收 |
|---|---:|---:|---:|---:|---|
| `Scenario1`（S0） | 75 | 45 | 30 | 0 | 30/30 次精确匹配 |
| `S1_75` | 75 | 45 | 30 | 0 | 30/30 次精确匹配 |
| `S2_75` | 75 | 45 | 30 | 0 | 30/30 次精确匹配 |
| `S3_75` | 75 | 45 | 30 | 0 | 30/30 次精确匹配 |
| `S0_100` | 100 | 45 | 30 | 25 | 30/30 次精确匹配 |

顺序校验值按飞机编号加权，不是飞机顺序的可逆编码。第二个校验和在每个场景的 30 次重复中均有 30 个不同值，足以作为重复间顺序变化的验收证据；第一个校验和存在个别碰撞，因此不单独作为通过依据。

## 实体、机械师与诊断

- `Ent_Plane` 包含 `PlaneID`、`PlaneType`、`CurLoc`、进出工位时间戳及 `OpenWO` 等状态；其工序仍按 `Tbl_Tasks.OwnerCell` 读取。`CurLoc` 只定位和统计。
- 机械师按 10 个 `Worker` 群体对象建模，每群体 8 人；没有重新创建此前删除的 80 个 Resource 或 12 个 ObjectList。
- 四种实验场景分别把 `Wkr_InitialWorkSchedule` 设为 `Sch_S0`、`Sch_S1`、`Sch_S2`、`Sch_S3`。各 Worker 的 `Initial Work Schedule` 引用该属性，供场景在运行初始化时选择日程。`Prop_Shift` 仍是班次编号控制项，不会单独触发运行中的动态换班。
- 保存后读取 `OnRunInitialized`、抽样流程和 `MySource1` 绑定均符合预期；`get_diagnostics` 返回 0 个错误。

## 保存与版本边界

- 保存前快照：`snapshots/AIT_V0.2_Skeleton_PreIssue5Completion_20261023.spfx`，SHA-256：`67C1EAD5D07E81A487AB67B808B47A35BCB681F00E05A8F25FD88AFEDD9B069C`。
- 经 Simio 桌面保存并重新选取磁盘模型后，MCP 回读仍为 `/Project/Model`，上述流程、绑定、实验响应及诊断仍有效。
- 当前交付文件 SHA-256：`8C7FD29BF51B225D5FB3EDF53CCC041D5A01FB45338FE6148CA3373359D527CD`；文件大小 3,180,198 字节。

## 历史状态说明

本文件旧版中“固定型号为 1”“尚未完成配额抽样/重复验证/保存”等描述对应抽样流程完成前的中间状态，已被 2026-10-23 本记录中的流程回读、150 次原生实验及保存后复核取代。先前关于 `SetWorkSchedule` 群体引用导致运行错误的记录也是历史方案；当前使用 `Wkr_InitialWorkSchedule` 属性和实验场景选择日程。
