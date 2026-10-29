# GitHub Project 看板配置

仓库 Issue、Milestone 和 Pull Request 流程已经建立。Project V2 看板需要单独的用户授权：当前 GitHub Token 只有 `gist`、`repo`、`workflow` scope，GraphQL 查询返回 `INSUFFICIENT_SCOPES`，因此本轮没有创建 Project 或伪造看板状态。

## 用户侧一次性配置

1. 在 GitHub Token 设置中为当前 Token 增加 `read:project` 和 `project`（写入）权限；若组织策略要求，批准组织访问。
2. 在仓库页面打开 **Projects → New project**，选择 Board 模板，命名为 `Simio Aerospace Delivery`。
3. 添加仓库 `wyfchina/Simio_AIT_Model` 的 Issues，建立四个视图状态：`待办`、`进行中`、`待验证`、`已完成`。
4. 使用 Milestone、Label 和 Assignee 作为筛选/分组字段。Issue 的验收状态仍以 Issue 评论和 `docs/github-issue-status-log.md` 为准，Project 只承担工作流视图。

## 建议字段和视图

- `Milestone`：按 #1–#4、#5–#8、#9–#10、#11–#13、#14 分组。
- `Status`：看板列使用 GitHub Project 的默认状态字段。
- `Labels`：保留 `status:verified`、`status:partial`、`type:bug`、`type:model-change`。
- `ModelVersion`：需要时作为自定义字段记录 `V0.2` 至 `V0.9` 或最终版本。

看板创建后，应将 Project URL 添加到仓库 README 和交付 PR；不要把 Project 卡片状态当作模型验收证据。
