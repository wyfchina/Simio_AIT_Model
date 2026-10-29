# 不需要 GitHub CLI。用法（在本文件夹中）：
#   powershell -ExecutionPolicy Bypass -File .\create_issues_rest.ps1
# 运行后按提示粘贴 GitHub 访问令牌（需对 wyfchina/Simio_AIT_Model 有 Issues 读写权限）
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$repo = 'wyfchina/Simio_AIT_Model'
$api  = "https://api.github.com/repos/$repo"
$sec  = Read-Host '粘贴 GitHub 令牌（输入不显示）' -AsSecureString
$tok  = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
$hdr  = @{ Authorization = "Bearer $tok"; Accept = 'application/vnd.github+json'; 'User-Agent' = 'ait-issue-import' }

function Post($url, $obj) {
  $bytes = [Text.Encoding]::UTF8.GetBytes(($obj | ConvertTo-Json -Depth 5))
  Invoke-RestMethod -Method Post -Uri $url -Headers $hdr -Body $bytes -ContentType 'application/json; charset=utf-8'
}

$existing = Invoke-RestMethod -Uri "$api/issues?state=all&per_page=1" -Headers $hdr
if (@($existing).Count -gt 0) { Write-Host '仓库已有 Issue/PR，编号将不从 #1 开始，已停止。' -ForegroundColor Red; exit 1 }

$labels = [ordered]@{ '总览'='5319e7'; '设计'='1d76db'; '数据'='0e8a16'; 'spike'='fbca04'; '建模'='0052cc'; '验证'='d93f0b'; '实验'='b60205'; '报告'='6f42c1' }
foreach ($k in $labels.Keys) {
  try { Post "$api/labels" @{ name = $k; color = $labels[$k] } | Out-Null } catch { }  # 已存在则跳过
}

$utf8  = New-Object System.Text.UTF8Encoding($false)
$items = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'issues.json'), $utf8) | ConvertFrom-Json
foreach ($it in $items) {
  $body = [string][IO.File]::ReadAllText((Join-Path $PSScriptRoot "issues\$($it.file)"), $utf8)
  $r = Post "$api/issues" @{ title = [string]$it.title; body = $body; labels = @([string]$it.label) }
  Write-Host "$($it.file) -> $($r.html_url)"
}
Write-Host '完成。' -ForegroundColor Green
