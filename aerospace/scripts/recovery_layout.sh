#!/bin/bash

layout_file="/Users/xbunax/.config/aerospace/scripts/layout.json"

if [[ ! -f "$layout_file" ]]; then
  echo "布局文件 $layout_file 不存在！请先运行保存脚本。"
  exit 1
fi
jq -c '.[]' "$layout_file" | while read -r window; do
  window_id=$(echo "$window" | jq -r '.["window-id"]')
  workspace=$(echo "$window" | jq -r '.workspace | tonumber')

  /opt/homebrew/bin/aerospace move-node-to-workspace --window-id "$window_id" "$workspace" --fail-if-noop
  # echo "窗口 $window_id 移动到 workspace $workspace"
done
