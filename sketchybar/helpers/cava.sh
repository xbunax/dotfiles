#!/bin/sh

PLUGIN_DIR="~/.config/sketchybar/helpers"

device=$(SwitchAudioSource -t output -c)

if [ "$device" != "WH-1000XM5" ]; then
  sketchybar --trigger cava_toggle drawing=true
  while true; do
    cava -p ~/.config/sketchybar/helpers/cava.conf | sed -u 's/ //g; s/0/▁/g; s/1/▂/g; s/2/▃/g; s/3/▄/g; s/4/▅/g; s/5/▆/g; s/6/▇/g; s/7/█/g; s/8/█/g' | while read line; do
      sketchybar --set media_cava label=$line
      # sketchybar --set $NAME label="▁▂▃▄▅▆▇██"
    done

    sleep 5
  done
else
  sketchybar --trigger cava_toggle drawing=false
fi
