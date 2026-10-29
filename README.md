# Simio Aerospace AIT Model

这是 Simio Aerospace（Fall 2024）案例的建模、原生仿真验证和交付复盘资料。

项目以 GitHub Issue #1–#14 记录需求与验收目标；Simio 模型在本地通过 Simio Desktop Interactive MCP 和 Simio 原生 Experiment 完成修改与验证。模型快照和实验结果必须按版本关联使用，不能把不同阶段的 BASE 结果拼成一条时间序列。

Git 提交历史是 2026-10-29 根据本地材料重建的里程碑历史，不能视为实时记录。重建原则和每个里程碑的证据日期见 [`docs/reconstruction-method.md`](docs/reconstruction-method.md)。

## 目录

- [`AIT_issues/issues/`](AIT_issues/issues/)：Issue #1–#14 的目标、条件、设计和验收标准
- [`docs/assumptions.md`](docs/assumptions.md)：统一建模假设 A1–A13
- [`docs/collaboration-retrospective.md`](docs/collaboration-retrospective.md)：中文协作与验证复盘
- [`docs/github-delivery-process.md`](docs/github-delivery-process.md)：Issue、PR、模型版本和发布流程
- [`docs/github-project-setup.md`](docs/github-project-setup.md)：Project V2 看板权限缺口与配置说明
- [`CHANGELOG.md`](CHANGELOG.md)：阶段模型与验证变更记录
- [`docs/reconstruction-method.md`](docs/reconstruction-method.md)：Git 里程碑历史的重建原则和来源映射
- [`docs/github-issue-status-log.md`](docs/github-issue-status-log.md)：GitHub Issue 状态、关闭依据和未闭环项
- [`docs/model-version-map.csv`](docs/model-version-map.csv)：模型快照与结果目录的版本映射
- [`docs/validation-evidence-index.md`](docs/validation-evidence-index.md)：验证证据索引及边界
- [`data/`](data/)：任务表和关联数据
- [`models/`](models/)：使用 Git LFS 管理的阶段性 `.spfx` 快照及 SHA-256 校验说明
- [`results/`](results/)：按模型阶段整理的实验汇总、逐重复数据和图表

## 结果使用规则

引用任何 CSV、图表或响应摘要时，同时写明实验名称、模型快照、控制口径和验证文档。`AIT_V1.0_Final.spfx` 已保存并登记；在关闭、重载和最终交付核验完成前，不能把仓库资料描述为已经冻结的单一交付包。

`.spfx` 模型快照通过 Git LFS 管理；`.backup`、超大 Trace 和完整 MCP 原始 JSON 不在本次发布范围内。上传的当前本地快照与历史验证包哈希不一致之处列在 [`models/README.md`](models/README.md)，不能默认当作历史验收包的精确副本。
