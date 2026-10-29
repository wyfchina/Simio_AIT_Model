# Issue #12 闭环记录

日期：2026-10-27  
活动模型：`/Project/Model`  
候选包：`AIT_V0.7_Issue12_Candidate.spfx`（Simio 活动副本）  
Simio：`20.297.56736.0`

## 闭环结论

Issue #12 的模型结构、路由、实验矩阵、产品配额、守恒检查和原生结果已经完成核验。D1 的“按先空出的 C1 分流”也已用两组非对称工时测试确认。当前模型处于停止状态，诊断为 0 errors，运行警告为 0。

## 独立证据

- `Exp_C_SA103` 保留 32 个正式场景：单线 24 个、双线 8 个；每个场景 5 次重复，共 160 次。
- 每次重复创建/完成 100 架，型号为 `45/30/25`，最终 WIP 为 0，守恒差额为 0。
- `results/expC/issue12_expC_replications.csv` 与候选包内 `Exp_C_SA103 ResponseResults.xml` 逐项比较 4,160 个响应值，差异为 0。
- 新建两个从未运行过的临时场景，各执行 1 次；均完成 100 架。逐响应结果与对应正式场景的第 1 次观测一致，随后临时场景已删除，正式场景配置与结果恢复一致。
- D1 判别测试使用 3 架飞机和不对称 C1 工时：
  - `L1=40 h, L2=10 h`：第 3 架在 `10.0017857 h` 进入 `Srv_L2_C1`；
  - `L1=10 h, L2=40 h`：第 3 架在 `10.0008929 h` 进入 `Srv_L1_C1`。
  两组测试均为 0 errors、0 warnings。Trace 原始副本见 `validation/issue12-d1-L1_slow-trace.csv` 和 `validation/issue12-d1-L2_slow-trace.csv`。
- 测试结束后，Task Sequence、控制属性、运行设置和 Trace 开关均恢复；磁盘包哈希未改变。
- 清理后的活动模型再次核对：32 个活动场景、160 次已完成重复、0 errors、0 warnings；原始 MCP 快照见 `validation/issue12-final-closure-audit-20261027.json`。

## 交付边界

本轮删除了 `Exp_C_SA103` 中两个空的停用调试场景：`Scenario1` 和 `ProbeControl`。该清理已在活动模型中完成，但当前 MCP 没有保存文件接口，因此候选包仍是清理前的磁盘版本。保存并重载后，才可以把本记录升级为“磁盘包已闭环”。

候选包原始 SHA-256：`dde929567b08a930c6b445bd9af236820206684739a05b1d0ca5b1746301a99e`。清理后的磁盘包应重新计算哈希，并再次核对 32 个场景、0 errors、0 warnings。

## 历史结果边界

`Exp_A_Buffer/BASE` 的约 346.17 天属于 V0.5 旧阶段；当前 Issue #12 的 BASE 参照应使用当前版本重新核验的约 316.34 天。旧结果不能与当前 `Exp_C_SA103` 结果混作同一版本的性能差值。历史说明见 `docs/issue-11-native-task-validation.md`。

