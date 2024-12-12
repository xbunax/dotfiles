#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=./display-info.sh
source ~/.config/aerospace/scripts/display_info.sh

# new dimensions and position of the focused window
calc() { printf %.2f "$(echo "$1" | bc -l)"; }

new_width=$(calc "$screen_width / 5 * 4")
new_height=$(calc "$screen_height / 5 * 4")

new_x=$(calc "($screen_width - $new_width) / 2")
new_y=$(calc "($screen_height - $new_height) / 2")

# resize/reposition the focused window
aerospace layout floating && osascript -e "
tell application \"System Events\"
  set _app to name of first application process whose frontmost is true
  tell process _app
    set _window to front window
    set position of _window to {$new_x, $new_y}
    set size of _window to {$new_width, $new_height}
    activate
  end tell
end tell" && aerospace flatten-workspace-tree && aerospace mode floating || aerospace layout tiling
