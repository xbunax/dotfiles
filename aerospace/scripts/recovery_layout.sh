#!/bin/bash

layout_file="/Users/xbunax/.config/aerospace/scripts/layout.json"

if [[ ! -f "$layout_file" ]]; then
  exit 1
fi

jq -rc '.[] | "\(.["window-id"]) \(.workspace)"' "$layout_file" |
  xargs -n2 sh -c '/opt/homebrew/bin/aerospace move-node-to-workspace --window-id $1 $2 --fail-if-noop' _
