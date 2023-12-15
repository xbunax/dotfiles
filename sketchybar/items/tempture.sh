#!/bin/bash


tempture=(
    script="$PLUGIN_DIR/tempture.sh"
    icon=󱤋
    icon.color=$GREEN
    icon.font="$FONT:Regular:19.0"
    icon.padding_right=7
   	padding_right=0
	padding_left=0
	# label.drawing=on
	label.padding_right=10
	update_freq=10
)

sketchybar --add item tempture left\
    --set tempture "${tempture[@]}" 
