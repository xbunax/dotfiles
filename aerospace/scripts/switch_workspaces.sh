#!/bin/bash

FOCUSED_WORKSPACE=$($(brew --prefix)/bin/aerospace list-workspaces --focused)

FOCUSED_WORKSPACE_WINDOWS=$($(brew --prefix)/bin/aerospace list-windows --workspace focused --format "%{window-id}" --json)

TARGET_WORKSPACE=$1

TARGET_WORKSPACE_WINDOWS=$($(brew --prefix)/bin/aerospace list-windows --workspace "$TARGET_WORKSPACE" --format "%{window-id}" --json)

echo "$FOCUSED_WORKSPACE_WINDOWS " | jq -r '.[].["window-id"]' | xargs -I {} $(brew --prefix)/bin/aerospace move-node-to-workspace "$TARGET_WORKSPACE" --fail-if-noop --window-id {}

echo "$TARGET_WORKSPACE_WINDOWS " | jq -r '.[].["window-id"]' | xargs -I {} $(brew --prefix)/bin/aerospace move-node-to-workspace "$FOCUSED_WORKSPACE" --fail-if-noop --window-id {}

/opt/homebrew/bin/aerospace workspace "$TARGET_WORKSPACE"
