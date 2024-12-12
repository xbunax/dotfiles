#!/bin/bash

# Kill any existing instance of the script
pkill -f "$(basename "$0")" 2>/dev/null

# Initialize previous window count
previous_window_count=$(aerospace list-windows --workspace focused --count)

# Arrange windows dynamically
arrange_windows() {
  # Get current window count
  current_window_count=$(aerospace list-windows --workspace focused --count)

  if [ "$current_window_count" -gt "$previous_window_count" ]; then
    # Get the number of windows in the focused workspace
    workspace_window_count=$(aerospace list-windows --workspace focused --count)

    if [ "$workspace_window_count" -eq 1 ]; then
      # If only one window, split horizontally
      if aerospace flatten-workspace-tree && aerospace split horizontall; then
        echo "New window split horizontally"
      else
        echo "Error: Could not split horizontally"
      fi
    else
      # Otherwise, split with opposite orientation
      if aerospace split opposite; then
        echo "New window split with opposite orientation"
      else
        echo "Error: Could not split with opposite orientation"
      fi
    fi
  fi

  # Update previous window count
  previous_window_count=$current_window_count
}

# Main loop to arrange windows dynamically
while true; do
  arrange_windows
  sleep 0.05 # Set polling interval; default 50ms
done
