#!/usr/bin/env bash
# Define pinned windows with app-bundle-id:window-title-regex-pattern format
PINNED_WINDOWS=("com.apple.AppStore:App Store")

####################################################################################################
## Start of script, don't modify beyond this line
####################################################################################################

AEROSPACE_PREV_WORKSPACE=$1
AEROSPACE_FOCUSED_WORKSPACE=$2

# Function to check if a window matches any pinned window criteria
function is_pinned_window() {
  local app_id=$1
  local window_title=$2
  for entry in "${PINNED_WINDOWS[@]}"; do
    IFS=':' read -r pinned_app_id pinned_pattern <<<"$entry"
    if [[ "$app_id" == "$pinned_app_id" ]] && echo "$window_title" | grep -E -q "$pinned_pattern"; then
      return 0
    fi
  done
  return 1
}

# Function to move pinned windows to the focused workspace
function move_pinned_windows_to_focused_workspace() {
  aerospace list-windows --all --format '%{window-id} %{app-bundle-id} %{window-title}' | while IFS=' ' read -r window_id app_id window_title; do
    if is_pinned_window "$app_id" "$window_title"; then
      aerospace move-node-to-workspace --window-id $window_id $AEROSPACE_FOCUSED_WORKSPACE
    fi
  done
}

# Main logic to handle workspace change
move_pinned_windows_to_focused_workspace
