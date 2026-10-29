# 验证证据索引

本文件用于 GitHub 复盘时定位证据。路径均相对于项目根目录；文件名中的日期是生成日期，不是模型版本号。

| 主题 | 首选证据 | 可复核内容 | 限制 |
|---|---|---|---|
| 统一假设 | `docs/assumptions.md`、`AIT_issues/issues/02.md` | 时间、随机、型号配额、工序和日程口径 | 原始案例 PDF/工作簿不随项目目录提供 |
| 任务表与工位 | `data/Tbl_Tasks.xlsx`、`AIT_issues/issues/03.md`、`docs/issue-4-validation.md` | 83 道任务、OwnerCell、Seq、Mechanics、关联表 | 原型 S1–S4 记录不能替代正式模型验收 |
| 公共骨架与配额 | `docs/issue-5-validation.md` | Worker 群体、日程、飞机状态、型号抽样、30 次重复 | 保存/重载必须以最终快照再次确认 |
| Flow 容量/缓冲 | `docs/issue-6-validation.md`、`docs/issue-7-validation.md` | 10 工位、容量/缓冲参数、Flow 四组合、诊断 | 屏幕目视布局证据另存于用户截图 |
| 基准 Pulse | `docs/issue-9-validation.md`、`results/expA/` | 工单守恒、逾期、traveled work、补工 | 仅适用于 V0.5；BASE 不得与 V0.6 混用 |
| 缓冲与容量实验 | `docs/issue-10-validation.md`、`results/expA/` | BASE、A1–A5 的逐重复结果和配对分析 | BASE 的 Flow 专用 WIP/FlowTime 不适用 |
| B0–B4 用工 | `docs/issue-11-native-task-validation.md`、`results/expB/` | Task 原生取人、释放、策略矩阵和收益 | 结果绑定 V0.6 活动配置 |
| SA103 与分流 | `docs/issue-12-closure-20261027.md`、`results/expC/` | 32 场景、160 次、45/30/25、D1/D2 | 候选包清理后的保存边界需重核 |
| 班次与成本 | `docs/issue-13-validation-20261027.md` | 20 场景、200 次、Reports 与响应、成本复算 | 删除静态汇总表后的最终包需重载 |
| WIP Dashboard | `docs/issue-14-wip-dashboard-validation-20261028.md`、`results/issue14_wip_daily_A1_A3.csv` | 24 小时 TimePeriod、A1/A3、日均 WIP、有效重复数 | Edit 模式仍报告内部字段 Invalid column |
| 确定性 Trace | `docs/validation_V0.3.md`、`validation/` 下 V1/V2/V4 文件 | V1–V7 记录和原始 Trace CSV | #8 仍缺界面截图；超大 Trace 不建议直接放普通 Git |

## 不应直接发布的文件

- `*.spfx`、`*.backup`：大型二进制模型快照，改用 Git LFS 或独立交付包。
- `*_trace.csv`：可达数十 MB，保留摘要和经过筛选的最小证据；原始文件放独立归档。
- `validation/issue11-acceptance-inspect.json` 等完整 MCP 分页原始响应：通常数 MB 以上，发布摘要 JSON 和哈希即可。
- 临时脚本、失败尝试和带本机路径的日志：除非它们被验证文档明确引用。

## 证据写法

每条结果至少写明：模型快照、实验名、场景控制值、重复数、响应名、单位、是否原生输出、验证日期和保存/重载状态。运行结果和编辑器状态若不一致，分别记录，不用其中一个覆盖另一个。
