param(
    [string]$Repository = 'wyfchina/Simio_AIT_Model',
    [string]$Marker = '<!-- codex-status-log:2026-10-29 -->'
)

$ErrorActionPreference = 'Stop'
$credentialLines = @('protocol=https', 'host=github.com', '') | git credential fill 2>$null
$tokenLine = $credentialLines | Where-Object { $_ -like 'password=*' } | Select-Object -First 1
$token = $tokenLine -replace '^password=', ''
if ([string]::IsNullOrWhiteSpace($token)) {
    throw 'No GitHub credential was returned by git credential fill.'
}

$headers = @{
    Authorization = "Bearer $token"
    Accept = 'application/vnd.github+json'
    'User-Agent' = 'Simio-AIT-Issue-Status-Sync'
}
$base = "https://api.github.com/repos/$Repository"

function Invoke-GitHubApi {
    param(
        [ValidateSet('Get', 'Post', 'Put', 'Patch')][string]$Method,
        [string]$Path,
        [object]$Body = $null
    )
    $params = @{ Method = $Method; Uri = "$base$Path"; Headers = $headers }
    if ($null -ne $Body) {
        $params.Body = $Body | ConvertTo-Json -Depth 10
        $params.ContentType = 'application/json'
    }
    Invoke-RestMethod @params
}

$updates = @{
    1 = @{ State = 'open'; Label = 'status:partial'; Body = @"
$Marker
@wyfchina 状态同步：**部分完成，保持开放**。

需求路线图和 Issue #1–#14 已归档；复盘见 [协作复盘](https://github.com/$Repository/blob/main/docs/collaboration-retrospective.md)。仍缺统一的 Issue 完成勾选、最终报告、最终模型快照和全项目交接验收。
"@ }
    2 = @{ State = 'open'; Label = 'status:partial'; Body = @"
$Marker
@wyfchina 状态同步：**部分完成，保持开放**。

A1–A13 已写入 [假设清单](https://github.com/$Repository/blob/main/docs/assumptions.md)。原始案例 PDF/工作簿未随项目归档，来源独立复核仍缺。
"@ }
    3 = @{ State = 'open'; Label = 'status:partial'; Body = @"
$Marker
@wyfchina 状态同步：**部分完成，保持开放**。

83 行任务数据和 `OwnerCell` 设计已进入 [任务数据](https://github.com/$Repository/tree/main/data)。`Tbl_Stations` 每字段中文 Description 是否随最终模型包完整保存，仍需最终快照核对。
"@ }
    4 = @{ State = 'open'; Label = 'status:partial'; Body = @"
$Marker
@wyfchina 状态同步：**部分完成，保持开放**。

Task Sequence、并行 Seq、人数和日程机制已形成设计基础；[原型记录](https://github.com/$Repository/blob/main/docs/issue-4-validation.md) 明确记载原型 S1–S4 未完整运行。后续正式模型结果不替代原型验收证据。
"@ }
    5 = @{ State = 'closed'; Label = 'status:verified'; Body = @"
$Marker
@wyfchina 状态同步：**已完成，关闭**。

根据 [#5 原生验证记录](https://github.com/$Repository/blob/main/docs/issue-5-validation.md)，公共骨架、飞机型号配额、10 个 Worker 群体、日程、`TN_Release` Flow 路由、临时测试清理和 5 个场景各 30 次结果均有记录。可下载快照见 [models/](https://github.com/$Repository/tree/main/models)。发布快照与历史正式包哈希差异已在模型 README 中明确，不再作为本 Issue 的未完成项。
"@ }
    6 = @{ State = 'open'; Label = 'status:partial'; Body = @"
$Marker
@wyfchina 状态同步：**部分完成，保持开放**。

[Flow 线验证](https://github.com/$Repository/blob/main/docs/issue-6-validation.md) 记录了 10 个工位、容量/缓冲参数化和四组合原生运行。仍缺最后一次保存后的关闭重载证据和 Facility 屏幕布局的独立目视记录。
"@ }
    7 = @{ State = 'open'; Label = 'status:partial'; Body = @"
$Marker
@wyfchina 状态同步：**部分完成，保持开放**。

CT、FlowTime、WIP、Makespan、利用率和守恒响应已建立，详见 [统计框架](https://github.com/$Repository/blob/main/docs/issue-7-validation.md)。WIP Dashboard 运行视图曾显示，但 Edit 模式仍报告 `DataSource`、`DataItem`、`StatisticType` 等字段无效。
"@ }
    8 = @{ State = 'open'; Label = 'status:partial'; Body = @"
$Marker
@wyfchina 状态同步：**主要验证通过，保持开放**。

V1–V7 的数值和守恒判据已记录在 [确定性验证](https://github.com/$Repository/blob/main/docs/validation_V0.3.md)，V5 按约定的排班比例近似口径通过。当前仅缺原生 Simio Trace 界面截图。
"@ }
    9 = @{ State = 'closed'; Label = 'status:verified'; Body = @"
$Marker
@wyfchina 状态同步：**已完成，关闭**。

[Pulse 验收记录](https://github.com/$Repository/blob/main/docs/issue-9-validation.md) 已覆盖位置/作业解耦、工作订单、traveled work、补工区、20 次重复以及飞机/工单守恒；75 架场景的生成、完成和守恒差额均有结果。
"@ }
    10 = @{ State = 'closed'; Label = 'status:verified'; Body = @"
$Marker
@wyfchina 状态同步：**已完成，关闭**。

[Exp_A_Buffer](https://github.com/$Repository/blob/main/docs/issue-10-validation.md) 和 `results/expA/` 已包含 BASE、A1–A5 的逐重复结果、配对分析和状态统计。BASE 的 Flow 专用 WIP/FlowTime 已明确标为不适用，结果只按 V0.5 版本使用。
"@ }
    11 = @{ State = 'closed'; Label = 'status:verified'; Body = @"
$Marker
@wyfchina 状态同步：**已完成，关闭**。

[B0–B4 原生 Task 验收](https://github.com/$Repository/blob/main/docs/issue-11-native-task-validation.md) 已验证策略切换、同时取人、释放、守恒和正式 `Exp_B_Labor` 结果。结论绑定 V0.6 用工模型和 `results/expB/`，不与 V0.5 BASE 混用。
"@ }
    12 = @{ State = 'closed'; Label = 'status:verified'; Body = @"
$Marker
@wyfchina 状态同步：**已完成，关闭**。

[SA103 闭环记录](https://github.com/$Repository/blob/main/docs/issue-12-closure-20261027.md) 已记录 32 个场景、160 次预验收重复、45/30/25 型号守恒和 D1 非对称负荷分流测试；结果位于 `results/expC/`。候选包保存边界已在文档中注明。
"@ }
    13 = @{ State = 'closed'; Label = 'status:verified'; Body = @"
$Marker
@wyfchina 状态同步：**已完成，关闭**。

[班次与人工成本验收](https://github.com/$Repository/blob/main/docs/issue-13-validation-20261027.md) 已完成 `Exp_D_Shift` 的 20 个场景 × 10 次重复，并核对原生 Reports、Experiment Responses 和成本复算；结果位于 `results/expD/`。
"@ }
    14 = @{ State = 'open'; Label = 'status:partial'; Body = @"
$Marker
@wyfchina 状态同步：**部分完成，保持开放**。

[WIP Dashboard 验证](https://github.com/$Repository/blob/main/docs/issue-14-wip-dashboard-validation-20261028.md) 已确认 24 小时 TimePeriod、A1/A3 日均 WIP 和运行视图结果。Edit 模式仍报告内部字段 `Invalid column`，尚未形成 `AIT_V1.0_Final.spfx` 和最终交接包。
"@ }
}

foreach ($label in @(
    @{ name = 'status:verified'; color = '0e8a16'; description = '验收证据满足当前 Issue 范围' },
    @{ name = 'status:partial'; color = 'fbca04'; description = '有结果但仍存在明确证据或交付缺口' }
)) {
    try {
        Invoke-GitHubApi -Method Post -Path '/labels' -Body $label | Out-Null
    } catch {
        if ($_.Exception.Response.StatusCode.value__ -ne 422) { throw }
    }
}

foreach ($number in ($updates.Keys | Sort-Object {[int]$_})) {
    $update = $updates[$number]
    $issue = Invoke-GitHubApi -Method Get -Path "/issues/$number"
    $comments = Invoke-GitHubApi -Method Get -Path "/issues/$number/comments?per_page=100"
    if (-not ($comments.body -like "*$Marker*")) {
        Invoke-GitHubApi -Method Post -Path "/issues/$number/comments" -Body @{ body = $update.Body } | Out-Null
    }

    $categoryLabels = @($issue.labels.name | Where-Object { $_ -notin @('status:verified', 'status:partial') })
    $desiredLabels = @($categoryLabels + $update.Label) | Select-Object -Unique
    Invoke-GitHubApi -Method Put -Path "/issues/$number/labels" -Body @{ labels = $desiredLabels } | Out-Null

    if ($issue.state -ne $update.State) {
        $reason = if ($update.State -eq 'closed') { 'completed' } else { 'reopened' }
        Invoke-GitHubApi -Method Patch -Path "/issues/$number" -Body @{ state = $update.State; state_reason = $reason } | Out-Null
    }
    Write-Output "Issue #$number synchronized: $($update.State), $($update.Label)"
}
