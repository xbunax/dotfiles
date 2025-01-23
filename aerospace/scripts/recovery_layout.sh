#!/bin/bash

layout_file=~/.config/aerospace/scripts/layout.json

if [[ ! -f "$layout_file" ]]; then
  echo none
  exit 1
fi

jq -rc '.[] | "\(.["window-id"]) \(.workspace)"' "$layout_file" |
  xargs -n2 sh -c '$(brew --prefix)/bin/aerospace move-node-to-workspace --window-id $1 $2 --fail-if-noop' _
