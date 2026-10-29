# Simio Aerospace 建模与验证协作复盘

记录日期：2026-10-29  
项目仓库：<https://github.com/wyfchina/Simio_AIT_Model>  
本地工作目录：`Simio_Aerospace_Fall_2024_Claude`

## 1. 项目目标与协作边界

项目目标是把 Aerospace Fall 2024 案例转成可运行、可解释、可复核的 Simio 模型，用于回答四类问题：现行四日脉动线的真实表现；完工驱动线的容量和缓冲影响；灵活用工策略 B0–B4 的收益；引入 SA103、增加第二条线和调整班次后的产能与人工成本。

协作采用“GitHub 记录需求，本地 Simio 完成建模”的方式：Issue #1–#14 记录目标、前置条件和验收标准；用户在 Simio Desktop 中完成保存、另存和部分界面操作；模型修改和原生运行通过 Simio Desktop Interactive MCP 读取或执行；Trace 截图等必须依赖桌面界面的证据单独保留。

GitHub 复盘不把 MCP 对话当成模型本体。每条结论都应能追溯到模型快照、实验结果、验证文档或明确标注的用户界面证据。

本地此前没有 Git 提交历史。当前 GitHub 提交链按 Issue 依赖和现存证据重建，所有提交使用真实重建日期；它表达阶段顺序，不代表逐次实时操作记录。具体重建方法见 [`reconstruction-method.md`](reconstruction-method.md)。

## 2. 关键建模决策

### 2.1 责任工位和飞机位置解耦

`Tbl_Tasks.OwnerCell` 表示任务由哪个工位负责，`Ent_Plane.CurLoc` 表示飞机当前物理位置。完工驱动线中两者通常同步；脉动线中飞机四天到点就移动，未完成任务由责任工位的虚拟作业站继续处理。这个解耦使 traveled work、逾期工单和补工区可以被显式统计。

### 2.2 单一任务表和 Task Sequence

83 道工序放在统一的 `Tbl_Tasks` 中，用 `OwnerCell` 过滤责任工位；同一 `Seq` 的任务并行，较大的 `Seq` 等待前一组完成。处理时长从型号列读取，`Mechanics` 表示同时占用的人数，时长不因人数除算。

### 2.3 Worker 资源

机械师按 Worker 群体建模，每组 8 人；未保留早期密集布局中的 80 个独立 Resource 和 12 个 ObjectList。Task Sequence 原生负责同时取人和释放资源。用工策略通过任务资源关系表的 `PolicyCode` 与 `Prop_LaborPolicy` 选择 B0–B4 名单。

### 2.4 Flow、Pulse、分流和补工

`Prop_Policy=1` 为四日脉动，`Prop_Policy=2` 为完工驱动。`TN_Release` 和零行程 Connector 按 `Prop_NumLines` 选择一条或两条生产线；100 架混合机队通过 D1/D2 策略分流。脉动线用 `Srv_P_Loc1..5` 处理位置，用 `Srv_P_Work_1..5` 处理订单，并在第 5 站后用 `Srv_P_Hold` 等待补工完成。

### 2.5 统计和输出

CT、Makespan、WIP、FlowTime、守恒、Worker 计划利用率、逾期工单和人工成本分别在 Experiment Responses、原生 Reports、State Statistic、Output Statistic 或外部验证脚本中记录。输入表不再充当仿真输出表；`Tbl_ShiftSummary` 的预览用途已删除。

## 3. Issue 时间线与当前证据状态

| Issue | 主要工作 | 当前可引用结论 | 证据边界 |
|---:|---|---|---|
| #1 | 路线图和 Issue 包 | 需求、依赖和阶段顺序已形成 | Issue 正文中的完成勾选和最终评论没有统一回填，不能当作模型验收 |
| #2 | 假设与口径 | A1–A13 已写入 `docs/assumptions.md` | 原始案例 PDF/工作簿不在本项目目录，来源复核依赖已有解析记录 |
| #3 | 任务、工位、关联表 | `Tbl_Tasks`、`Tbl_Cells`、`Tbl_Stations` 结构和任务数据已用于正式模型 | 早期检查发现 `Tbl_Stations` Description 缺失，后续是否在最终包中完全补齐要以包内回读为准 |
| #4 | Task Sequence 原型 | 形成了 Task Sequence、并行 Seq、人数和日程的设计基础 | 原始原型文档明确记载 S1–S4 未独立完成；不要把原型记录当成正式模型证明 |
| #5 | 公共骨架、配额、Worker、日程、Flow 分流 | 型号配额、10 个 Worker 群体、日程、`TN_Release` 和 Flow 路由均有原生运行记录 | 正式包保存/关闭/重载边界和部分中文 Description 需按最终快照复核 |
| #6 | 完工驱动线、容量/缓冲、状态图形 | 10 个工位、Task Sequence、容量/缓冲参数化；Flow 四组合 120 次重复通过，诊断 0 errors | 屏幕布局目视证据和最后一次保存后重载证据需单独保留 |
| #7 | 统计框架 | CT、FlowTime、WIP、Makespan、资源利用率和守恒响应已扩展到 Experiment | WIP Dashboard 的运行展示曾成功，但 Edit 模式字段解析错误；不要把编辑器红叉写成已修复 |
| #8 | 确定性 V1–V7 | 解析值、单架运行、并行 Seq、日程、守恒和型号配额均有记录 | `docs/validation_V0.3.md` 和 `validation/` 中有 Trace CSV，但 Trace 界面截图尚缺；这是界面证据缺口，不等同于逻辑未运行 |
| #9 | 脉动基准、工作订单、traveled work、补工 | 工单生成/完成守恒、逾期和补工尾巴实验已建立；配额除零问题已修复 | 结果必须引用 V0.5 配额修复阶段，不能与 V0.6 BASE 混用 |
| #10 | BASE 与 A1–A5 缓冲/容量比较 | `Exp_A_Buffer` 有完整 10 次重复和配对统计；Flow 指标对 BASE 标为不适用 | V0.5 BASE 约 346 天，不能与 V0.6 BASE 约 316 天合并比较 |
| #11 | B0–B4 原生 Task 用工策略 | A1/A4/BASE 的策略切换、同时取人、释放和守恒有矩阵证据；A4 的 B2 接近全池上界 | 结论绑定 V0.6 用工配置；历史 `issue-11-native-policy-acceptance` 中的未完成结论属于早期阶段 |
| #12 | SA103、单线/双线和 D1/D2 分流 | 32 个场景、160 次预验收重复；100 架均为 45/30/25，守恒为 0，D1 非对称负荷烟测通过 | 清理调试场景后的正式磁盘包需以保存/重载后的哈希再确认 |
| #13 | 班次、人工成本和 Shift Dashboard | `Exp_D_Shift` 20 个场景 × 10 次，共 200 次；原生 Reports 与响应一致，成本独立复算一致 | 删除静态汇总表和 Dashboard 绑定后需要再次保存并重载；不把旧静态表当成输出源 |
| #14 | 报告、Dashboard 和交接 | WIP 日周期、Makespan、状态、CT–付薪人时和 SA103 展示方案已设计，WIP 实验有 10 次重复 | WIP Dashboard 在运行视图可显示，但 Edit 模式报告 `DataSource`、`DataItem`、`StatisticType` 等 Invalid column；没有 `AIT_V1.0_Final.spfx` |

## 4. 版本和结果边界

模型快照和结果目录的逐项映射见 [`model-version-map.csv`](model-version-map.csv)。最容易误用的是 BASE：

- V0.5 `AIT_V0.5_PulseLine_QuotaInitFix.spfx` 阶段的 `Exp_A_Buffer/BASE` 和 #9 脉动基准约为 346 天真实完工；名义 316 天是最后一架离开位置线，不是最后工单完成。
- V0.6 用工策略阶段的 BASE 约为 316.34 天。该阶段的任务资源绑定和工单逻辑已经变化，不能把 316 天和 V0.5 的 346 天当成同一模型的前后对照。
- V0.8 `Exp_D_Shift` 使用当前班次和成本定义，S0 BASE 为约 316.34 天；这是当前班次实验的版本基线。

差异的事实已经记录，但历史材料没有完成一组单架、同参数、同随机口径的判别性复跑来解释全部 30 天差异。因此复盘应保留“版本不可比”和“根因未完全定位”两层结论，不能用“版本不同”替代原因分析。

## 5. 失败与返工记录

1. Simio MCP 没有保存/另存接口，Computer Use 多次受到 native pipe 或自动审查服务 503 影响。解决方式是由用户在 Simio 中保存、另存、关闭和重载，再由 MCP 只读复核。
2. 早期把责任工位和物理位置混在一起会阻止飞机按四日节拍离站；改为位置站、工作站和工作订单三者解耦。
3. 直接用输入表 `Tbl_ShiftSummary` 承载实验输出造成 Dashboard 数据职责混乱；后来删除静态输出表，正式结果回到 Experiment Results、Reports 和外部导出。
4. WIP Dashboard 的运行图和编辑器定义出现不一致：运行视图可以显示数据，Edit 模式仍把内部字段报告为不存在。该问题被保留为证据边界，没有把运行截图解释成编辑定义已通过。
5. 脉动配额初始化曾在剩余配额为零时除零；在初始化和抽样流程中保留三种型号配额并修正终止条件后，#9 实验完成 20/20 次且守恒通过。
6. 用工策略早期尝试通过额外 Source/Process 补资源，后来改为 Task Sequence 的原生资源需求和 `MechList`，使 `Prop_LaborPolicy` 真正影响取人名单。

## 6. 推荐的 GitHub 发布结构

普通 Git 适合保存：Issue Markdown、假设、验证 Markdown、结果 CSV/摘要、图表 SVG、版本映射和证据索引。`.spfx`、`.backup`、数十 MB Trace、完整 MCP 原始分页 JSON 应使用 Git LFS 或单独交付包，并在索引中写 SHA-256、模型版本和生成日期。

发布顺序建议为：先提交文档和小型结果；再在每个 GitHub Issue 下追加对应验证记录链接；最后单独发布一个带版本号的模型快照和校验哈希。不要把“本地活动模型已验证”写成“GitHub 中的磁盘包已验证”，除非完成保存、关闭、重载和再核验。

## 7. 当前待交接项

- 形成并保存 `AIT_V1.0_Final.spfx`，记录 SHA-256。
- 对最终包执行关闭、重载、诊断和停止状态复核。
- 补充 #8 Trace 界面截图的路径、时间和对应测试用例。
- 决定 WIP Dashboard 是修复 Edit 模式字段绑定，还是改用已验证的原生 Experiment Report，并在文档中明确取舍。
- 把 GitHub Issue 的完成评论、模型版本、结果目录和证据文档逐一互链。
