#!/bin/bash

# 获取当前窗口布局并保存到文件
$(brew --prefix)/bin/aerospace list-windows --all --format "%{window-id}%{workspace}%{app-bundle-id}" --json >~/.config/aerospace/scripts/layout.json
