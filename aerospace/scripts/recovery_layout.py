#!/usr/bin/python3

import json
import os
import subprocess

# 布局文件路径
layout_file = "/Users/xbunax/.config/aerospace/scripts/layout.json"

# 检查布局文件是否存在
if not os.path.isfile(layout_file):
    print(f"布局文件 {layout_file} 不存在！请先运行保存脚本。")
    exit(1)

# 读取 JSON 文件内容
try:
    with open(layout_file, "r", encoding="utf-8") as f:
        layout_data = json.load(f)
except json.JSONDecodeError as e:
    print(f"JSON 文件解析错误: {e}")
    exit(1)

# 遍历布局并恢复窗口位置
for window in layout_data:
    window_id = window.get("window-id")
    workspace = window.get("workspace")

    # 确保字段有效
    if window_id is None or workspace is None:
        print(f"跳过无效项: {window}")
        continue

    # 将 workspace 转换为整数类型（如需要）
    try:
        workspace = int(workspace)
    except ValueError:
        print(f"无效的 workspace 值: {workspace}")
        continue

    # 执行命令
    command = [
        "/opt/homebrew/bin/aerospace",
        "move-node-to-workspace",
        "--window-id", str(window_id),
        str(workspace),
        "--fail-if-noop"
    ]

    try:
        subprocess.run(command, check=True)
        # 打印调试信息
        # print(f"窗口 {window_id} 移动到 workspace {workspace}")
    except subprocess.CalledProcessError as e:
        print(f"命令执行失败: {e}")
