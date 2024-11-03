#!/bin/bash

# get temperature
TEMPERATURE=$(~/.local/bin/smctemp -c)

# check smctemp whether running well
if [ $? -ne 0 ]; then
    echo "Error: Unable to get temperature."
    exit 1
fi

# update sketchybar shown
sketchybar --set $NAME temperature label="${TEMPERATURE}󰔄"
