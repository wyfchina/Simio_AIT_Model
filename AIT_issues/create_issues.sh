#!/usr/bin/env bash
# 用法：bash create_issues.sh   （需 gh 与 jq 已安装并 gh auth login；仓库尚无 Issue/PR）
set -euo pipefail
cd "$(dirname "$0")"; R=wyfchina/Simio_AIT_Model
[ "$(gh api "repos/$R/issues?state=all&per_page=1" --jq length)" = 0 ] || { echo "仓库已有 Issue/PR，已停止"; exit 1; }
for l in 总览:5319e7 设计:1d76db 数据:0e8a16 spike:fbca04 建模:0052cc 验证:d93f0b 实验:b60205 报告:6f42c1; do gh label create "${l%%:*}" --color "${l##*:}" -R $R --force >/dev/null; done
jq -c '.[]' issues.json | while read -r it; do
  f=$(jq -r .file <<<"$it"); t=$(jq -r .title <<<"$it"); l=$(jq -r .label <<<"$it")
  echo "$f -> $(gh issue create -R $R --title "$t" --label "$l" --body-file "issues/$f")"
done
