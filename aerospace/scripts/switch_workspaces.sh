#!/bin/bash

FOCUSED_WORKSPACE=$(/opt/homebrew/bin/aerospace list-workspaces --focused)

FOCUSED_WORKSPACE_WINDOWS=$(/opt/homebrew/bin/aerospace list-windows --workspace focused --format "%{window-id}" --json)

TARGET_WORKSPACE=$1

TARGET_WORKSPACE_WINDOWS=$(/opt/homebrew/bin/aerospace list-windows --workspace "$TARGET_WORKSPACE" --format "%{window-id}" --json)

echo "$FOCUSED_WORKSPACE_WINDOWS " | jq -r '.[].["window-id"]' | xargs -I {} /opt/homebrew/bin/aerospace move-node-to-workspace "$TARGET_WORKSPACE" --fail-if-noop --window-id {}

echo "$TARGET_WORKSPACE_WINDOWS " | jq -r '.[].["window-id"]' | xargs -I {} /opt/homebrew/bin/aerospace move-node-to-workspace "$FOCUSED_WORKSPACE" --fail-if-noop --window-id {}

/opt/homebrew/bin/aerospace workspace "$TARGET_WORKSPACE"
