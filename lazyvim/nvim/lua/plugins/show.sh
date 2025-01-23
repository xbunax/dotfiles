#!/bin/bash

file_path=$1

frames=$(awk -v RS= '{gsub(/\n/, "\\n"); print}' "$file_path")

clear_screen() {
  tput reset
}

move_cursor_home() {
  tput cup 0 0
}

cols=$(tput cols)
rows=$(tput lines)

clear_screen

while true; do
  for frame in $frames; do
    move_cursor_home
    printf "%b" "$frame"
    sleep 0.05
  done
done
