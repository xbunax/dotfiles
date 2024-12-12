#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=./display-info.sh
source ~/.config/aerospace/scripts/display_info.sh

osascript -e "
tell application \"System Events\"
  set _app to name of first application process whose frontmost is true
  tell process _app
    set _window to front window
    set {x0, y0, width, height} to _window's position & _window's size
    set {x1, y1} to {x0 + $1, y0 + $2}
    if x1 + width <= $screen_width then
      if y1 + height <= $screen_height then
        set position of _window to {my max(7, x1), my max(45, y1)}
      end if
    end if
    activate
  end tell
end tell

on max(x, y)
  if x >= y then return x
  return y
end max
" && aerospace flatten-workspace-tree
