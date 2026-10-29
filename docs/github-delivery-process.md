# GitHub 协作与交付规程

## 变更流程

1. 每项可验收工作使用 Issue 描述目标、模型对象、控制属性、依赖、验收判据和预期证据。缺陷使用缺陷模板，机制或实验变更使用建模模板。
2. 在 `codex/<topic>` 或 `feature/<topic>` 分支提交变更，通过 Pull Request 合入 `main`。PR 必须关联 Issue，并说明模型版本、结果口径和验证证据。
3. 仓库离线检查通过后方可合并。Simio 原生诊断、运行、Experiment 和界面检查仍由有 Simio 环境的维护者完成；GitHub Actions 不声称替代这些验证。
4. 合并后更新 Issue 状态、证据索引、模型版本映射和 CHANGELOG。只有验收证据支持时才关闭 Issue。

## 模型与结果版本

- 每个 `.spfx` 使用 Git LFS；提交前检查 LFS 对象已成功上传。
- 对每个快照记录文件名、SHA-256、Experiment、主要结果路径、范围和已知边界。
- 结果 CSV、图表和响应摘要必须标明对应模型快照、Experiment、Scenario 和关键控制口径。
- 不得将不同模型快照的 BASE 或其他响应拼接比较。候选模型不得标为最终交付。
- 不提交 `.backup`、临时 Trace、完整 MCP 原始 JSON 或凭据；必要的精简验证证据放入 `docs/` 或 `results/`。

## Release 与冻结

1. 冻结前确认所有要求范围内的 Issue 已验收或有明确的未完成说明，模型诊断和规定的原生实验通过。
2. 保存模型后关闭并重新打开交付文件，核对模型名称、文件哈希、属性、Experiment 和结果边界。
3. 更新 `docs/model-version-map.csv`、`models/README.md`、`docs/validation-evidence-index.md` 和 `CHANGELOG.md`。
4. 为已复核快照创建有注释的版本标签，例如 `v1.0.0`，并在 GitHub Release 中附上模型、校验和、验证报告及已知限制。
5. 只有通过冻结检查的文件才能命名为 `AIT_V1.0_Final.spfx`。当前仓库没有该最终快照。

## GitHub 管理配置

- GitHub Milestones 按 Issue 阶段分组，用于查看阶段进度；Issue 状态仍以验收证据为准。
- Project 看板用于跨 Issue 的待办、进行中、待验证和完成视图，不替代 Issue、PR 或版本证据。
- `CODEOWNERS` 当前指向仓库唯一维护者 `@wyfchina`，用于变更通知；由于目前没有第二位维护者，不设置虚假的独立审查要求。
- `main` 保护应要求 Pull Request 和 `repository-checks` 状态检查；管理员可在恢复或紧急情况下绕过。启用前须确认该检查已在默认分支运行成功。

## 验证边界

GitHub Actions 只检查文件结构、映射表、LFS 指针和结果 CSV 可读性。Simio 运行时行为、资源占用、排程、Trace、Dashboard 渲染和 Experiment 响应必须在 Simio 原生环境验证，并将证据链接到 Issue/PR。
