#!/bin/bash

# Specify the workspace where we want to check for open windows (in this case, 'V')
WORKSPACE="3"
FLAG_FILE="$HOME/workspace_3_initialized"

# Check if there are any open windows in the workspace
open_windows=$(aerospace list-windows --workspace $WORKSPACE --count)

if [ "$open_windows" -gt 0 ]; then
  if [ -f "$FLAG_FILE" ]; then
    echo "Windows already initialized in workspace $WORKSPACE. Skipping further actions."
    exit 0
  fi
else

  aerospace workspace 3
  # No windows are open in the workspace, so proceed to open new windows and run the commands

  # Open the first WezTerm window, execute SSH, run eza, and keep the session open
  kitty @ launch --hold --type=os-window '/opt/homebrew/bin/spotify_player'

  # Wait for the first window to finish its command before proceeding
  sleep 0.2

  # Open the second WezTerm window, execute SSH, run neofetch and pm2 status, and keep the session open
  kitty @ launch --hold --type=os-window zsh -c '/Users/july/.local/bin/sptlrx -c /Users/july/.config/sptlrx/config.yaml'

  # Wait for the second window to finish its command before proceeding
  sleep 0.2

  # Open the third WezTerm window, execute SSH, run bpytop, and keep the session open
  kitty @ launch --hold --type=os-window zsh -c '/opt/homebrew/bin/cmatrix'

  # Wait for all windows to finish executing their commands
  sleep 0.2

  kitty @ launch --hold --type=os-window '/opt/homebrew/bin/cava'

  sleep 0.2
  # Now apply the layout after all windows are executed

  # Focus the first window and apply the h_tiles layout
  # aerospace focus left
  # aerospace focus left
  # aerospace focus left

  aerospace layout h_tiles
  aerospace join-with left

  # Move the first window left, and the others will fall into place

  # Resize bpytop window
  # aerospace resize height +26

  # Create the flag file to indicate windows are initialized
  touch "$FLAG_FILE"
  echo "Workspace $WORKSPACE initialized and layout applied."
fi
