#!/bin/bash
level=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
notify-send -e -u low \
    -h string:x-canonical-private-synchronous:brightness_notif \
    -h int:value:$level \
    "Brightness: $level%"
