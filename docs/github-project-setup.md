# GitHub Project 看板配置

仓库 Issue、Milestone 和 Pull Request 流程已经建立。Project V2 看板现已创建：[Simio Aerospace Delivery](https://github.com/users/wyfchina/projects/3)。

## 当前配置

- Project 编号：`3`；所有者：`wyfchina`。
- 默认视图：`交付看板`，布局为 Board。
- `Status` 字段选项：`待办`、`进行中`、`待验证`、`已完成`。
- 已加入 Issue #1–#14；初始状态按 GitHub Issue 状态映射，已关闭项为`已完成`，开放项为`待办`。
- 默认字段还包括 Milestone、Labels、Assignees、Repository 和 Linked pull requests。

## 使用约定

- 使用 Milestone 按 #1–#4、#5–#8、#9–#10、#11–#13、#14 分组；使用 Label 区分 `status:verified`、`status:partial`、`type:bug`、`type:model-change`。
- 工作状态是协作看板字段，不等同于验收结论。验收状态与依据仍以 Issue 评论和 `docs/github-issue-status-log.md` 为准。
- Issue 后续状态变化时，维护者应同步更新 Project `Status`；不要把看板状态当作模型验证证据。

Project URL 已加入仓库 README；后续看板结构调整通过 PR 记录。
