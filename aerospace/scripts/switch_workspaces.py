#!/usr/bin/python3

import subprocess
import json
import sys

def get_focused_workspace():
    """获取当前焦点 workspace"""
    result = subprocess.run(
        ["/opt/homebrew/bin/aerospace", "list-workspaces", "--focused"],
        capture_output=True, text=True, check=True
    )
    return result.stdout.strip()

def get_windows_in_workspace(workspace):
    """获取指定 workspace 的窗口 ID 列表"""
    result = subprocess.run(
        [
            "/opt/homebrew/bin/aerospace",
            "list-windows",
            "--workspace", workspace,
            "--format", "%{window-id}",
            "--json"
        ],
        capture_output=True, text=True, check=True
    )
    return json.loads(result.stdout)

def move_window_to_workspace(window_id, target_workspace):
    """将窗口移动到指定 workspace"""
    command = [
        "/opt/homebrew/bin/aerospace",
        "move-node-to-workspace",
        "--window-id", str(window_id),
        str(target_workspace),
    ]
    subprocess.run(command, check=True)


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 script.py <target_workspace>")
        sys.exit(1)

    target_workspace = sys.argv[1]

    # 获取焦点 workspace 和其窗口
    focused_workspace = get_focused_workspace()
    focused_workspace_windows = get_windows_in_workspace("focused")

    # 获取目标 workspace 的窗口
    target_workspace_windows = get_windows_in_workspace(target_workspace)

    # 将当前焦点 workspace 的窗口移动到目标 workspace
    for window in focused_workspace_windows:
        window_id = window.get("window-id")
        if window_id is not None:
            move_window_to_workspace(window_id, target_workspace)

    # 将目标 workspace 的窗口移动到当前焦点 workspace
    for window in target_workspace_windows:
        window_id = window.get("window-id")
        if window_id is not None:
            move_window_to_workspace(window_id, focused_workspace)

    subprocess.run([
        "/opt/homebrew/bin/aerospace",
        "workspace",
        str(target_workspace)
    ])

if __name__ == "__main__":
    main()
