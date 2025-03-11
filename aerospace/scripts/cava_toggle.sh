#!/bin/bash

# 获取当前 drawing 状态（假设查询的是 "cava" 模块）
current_state=$($(brew --prefix)/bin/sketchybar --query media_cava | jq ."geometry"."drawing")
current_state=$(echo "$current_state" | tr -d '"')

# 确定新状态
if [ "$current_state" == "off" ]; then
  new_state="true"
else
  new_state="false"
fi

echo $new_state

# 触发 toggle 并更新状态
$(brew --prefix)/bin/sketchybar --trigger cava_toggle drawing=$new_state
