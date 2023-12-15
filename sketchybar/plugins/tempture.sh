#!/bin/bash

# 获取温度
TEMPERATURE=$(/usr/local/bin/smctemp -c)

# 检查smctemp命令是否成功执行
if [ $? -ne 0 ]; then
    echo "Error: Unable to get temperature."
    exit 1
fi

# 更新sketchybar显示
sketchybar --set $NAME temperature label="${TEMPERATURE}󰔄"
