yabai -m space --create && \
    index="$(yabai -m query --spaces --display | jq 'map(select(."is-native-fullscreen" == false))[-1].index')" && \
    yabai -m space --focus "${index}"