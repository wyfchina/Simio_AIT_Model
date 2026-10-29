# Simio 模型快照

本目录提供项目各阶段当前本地目录中的主 `.spfx` 文件，通过 Git LFS 存储。文件名用于和验证记录、实验版本对应；它们是可下载的模型快照，不代表每个文件都与对应验证文档记录的原始保存包逐字节一致。

## 使用前核对

- `docs/model-version-map.csv` 列出每个上传文件的 SHA-256 和关联结果。
- SHA-256 是本次发布所用本地快照的校验值。下载后可重新计算并比对。
- #5 记录的正式 `AIT_V0.2_Skeleton.spfx` 哈希为 `8C7FD29BF51B225D5FB3EDF53CCC041D5A01FB45338FE6148CA3373359D527CD`，与本次发布的同名本地 `.spfx` 文件不同。
- #5 正式包复核记录的 `AIT_V0.3_FlowLine.spfx` 哈希为 `CC5EF7072AF0F10CA0F8EF1B2EEC00E858129A73C9D39D67E434817F2FF595DA`，也与本次发布的同名本地文件不同。
- `AIT_V1.0_Final.spfx` 已保存到本地并纳入版本映射，当前状态为“已保存待复核”。在 Simio 中完成关闭、重载、诊断、Experiment/Dashboard 核对并建立 Release 前，不把它称为最终冻结交付包。
- 打开模型前请确认 Simio 版本兼容性，并先另存工作副本。

## 目录内容

| 文件 | 阶段 |
|---|---|
| `Aerospace.spfx` | 初始模型 |
| `AIT_V0.2_Skeleton.spfx` | 公共骨架阶段 |
| `AIT_V0.3_FlowLine.spfx` | Flow 线阶段 |
| `AIT_V0.4_Validated.spfx` | 确定性验证阶段 |
| `AIT_V0.5_PulseLine_QuotaInitFix.spfx` | Pulse 与工作订单阶段 |
| `AIT_V0.6_LaborFlex_C1PolicyPilot.spfx` | B0–B4 用工策略阶段 |
| `AIT_V0.7_Issue12_Candidate.spfx` | SA103 与分流阶段 |
| `AIT_V0.8_Shift_Candidate.spfx` | 班次和成本阶段 |
| `AIT_V0.9_Issue14_DashboardCandidate.spfx` | Dashboard 候选阶段 |
| `AIT_V1.0_Final.spfx` | 已保存的正式候选交付快照，待最终关闭/重载复核 |
