#!/bin/bash

# Specify the workspace where we want to check for open windows (in this case, 'V')
WORKSPACE="2"
# FLAG_FILE="$HOME/workspace_v_initialized"

# Check if there are any open windows in the workspace
# open_windows=$(aerospace list-windows --workspace $WORKSPACE --count)
#
# if [ "$open_windows" -gt 0 ]; then
#   if [ -f "$FLAG_FILE" ]; then
#     echo "Windows already initialized in workspace $WORKSPACE. Skipping further actions."
#     exit 0
#   fi
# else
# No windows are open in the workspace, so proceed to open new windows and run the commands

# Open the first WezTerm window, execute SSH, run eza, and keep the session open
open -a WeChat
# wezterm start -- zsh -c "export PATH=/home/linuxbrew/.linuxbrew/bin:\$PATH; ssh -t usr@xxx.xxx.xxx.xx 'home/linuxbrew/.linuxbrew/bin/eza --tree --level=2 --long --color=always --icons=always --no-time --no-user --no-permissions; exec zsh'" &

# Wait for the first window to finish its command before proceeding
sleep 0.2

WECHAT_ID=$(aerospace list-windows --workspace $WORKSPACE | grep 微信 | awk -F'|' '{print $1}' | sed 's/ //g')

# Open the second WezTerm window, execute SSH, run neofetch and pm2 status, and keep the session open
open -a QQ
# wezterm start -- zsh -c "export PATH=/usr/bin:\$PATH; ssh -t usr@xxx.xxx.xxx.xx 'neofetch; pm2 status; exec zsh'" &

# Wait for the second window to finish its command before proceeding
sleep 0.2

QQ_ID=$(aerospace list-windows --workspace $WORKSPACE | grep QQ | awk -F'|' '{print $1}' | sed 's/ //g')
# Open the third WezTerm window, execute SSH, run bpytop, and keep the session open
# wezterm start -- zsh -c "export PATH=/home/linuxbrew/.linuxbrew/bin:\$PATH; ssh -t usr@xxx.xxx.xxx.xx '/home/usr/.local/bin/bpytop; exec zsh'" &

# Wait for all windows to finish executing their commands
# sleep 0.2

# Now apply the layout after all windows are executed

# Focus the first window and apply the h_tiles layout
# aerospace focus --window-id $QQ_ID
aerospace move left --window-id $QQ_ID

aerospace move right --window-id $WECHAT_ID
# Move the first window left, and the others will fall into place
aerospace focus --window-id $QQ_ID
aerospace resize smart -100

# Create the flag file to indicate windows are initialized
# touch "$FLAG_FILE"
echo "Workspace 2 initialized and layout applied."
# fi
