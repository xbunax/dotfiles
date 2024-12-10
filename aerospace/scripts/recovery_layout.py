#!/usr/bin/python3

import json
import os
import subprocess

layout_file = "/Users/xbunax/.config/aerospace/scripts/layout.json"

if not os.path.isfile(layout_file):
    print(f"布局文件 {layout_file} 不存在！请先运行保存脚本。")
    exit(1)

try:
    with open(layout_file, "r", encoding="utf-8") as f:
        layout_data = json.load(f)
except json.JSONDecodeError as e:
    print(f"JSON 文件解析错误: {e}")
    exit(1)

for window in layout_data:
    window_id = window.get("window-id")
    workspace = window.get("workspace")

    if window_id is None or workspace is None:
        print(f"跳过无效项: {window}")
        continue

    try:
        workspace = int(workspace)
    except ValueError:
        print(f"无效的 workspace 值: {workspace}")
        continue

    command = [
        "/opt/homebrew/bin/aerospace",
        "move-node-to-workspace",
        "--window-id", str(window_id),
        str(workspace),
        "--fail-if-noop"
    ]

    try:
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as e:
        print(f"命令执行失败: {e}")
