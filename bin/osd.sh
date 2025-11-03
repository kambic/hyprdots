#!/bin/bash
# ~/.local/bin/control-notify
# Unified Volume / Brightness / Media control with notifications

ACTION="$1"

notify() {
    local value="$1"
    local text="$2"
    local sync="$3"
    notify-send -e -u low \
        -h string:x-canonical-private-synchronous:"$sync" \
        -h int:value:"$value" \
        "$text"
}

case "$ACTION" in

    vol-up)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1
        vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
        if echo "$vol" | grep -q MUTED; then
            notify 0 "Volume: Muted" "volume_notif"
        else
            pct=$(echo "$vol" | awk '{printf "%d", $2*100}')
            notify "$pct" "Volume: $pct%" "volume_notif"
        fi
        ;;

    vol-down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
        if echo "$vol" | grep -q MUTED; then
            notify 0 "Volume: Muted" "volume_notif"
        else
            pct=$(echo "$vol" | awk '{printf "%d", $2*100}')
            notify "$pct" "Volume: $pct%" "volume_notif"
        fi
        ;;

    vol-mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
        if echo "$vol" | grep -q MUTED; then
            notify 0 "Volume: Muted" "volume_notif"
        else
            pct=$(echo "$vol" | awk '{printf "%d", $2*100}')
            notify "$pct" "Volume: $pct%" "volume_notif"
        fi
        ;;

    bright-up)
        brightnessctl set 5%+
        level=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
        notify "$level" "Brightness: $level%" "brightness_notif"
        ;;

    bright-down)
        brightnessctl set 5%-
        level=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
        notify "$level" "Brightness: $level%" "brightness_notif"
        ;;

    media-play)
        playerctl play-pause
        status=$(playerctl status 2>/dev/null || echo "Stopped")
        if [ "$status" = "Playing" ]; then
            title=$(playerctl metadata title 2>/dev/null | cut -c1-30)
            [ ${#title} -gt 27 ] && title="${title:0:27}…"
            notify 1 "Now Playing" "media_notif"
        else
            notify 0 "Paused" "media_notif"
        fi
        ;;

    media-next)
        playerctl next
        title=$(playerctl metadata title 2>/dev/null | cut -c1-30)
        [ ${#title} -gt 27 ] && title="${title:0:27}…"
        notify 1 "Next Track" "media_notif"
        ;;

    media-prev)
        playerctl previous
        title=$(playerctl metadata title 2>/dev/null | cut -c1-30)
        [ ${#title} -gt 27 ] && title="${title:0:27}…"
        notify 1 "Previous Track" "media_notif"
        ;;

    *)
        echo "Usage: $0 {vol-up|vol-down|vol-mute|bright-up|bright-down|media-play|media-next|media-prev}"
        exit 1
        ;;
esac
