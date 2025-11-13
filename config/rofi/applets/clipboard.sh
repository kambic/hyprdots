#!/bin/bash

# Theme
theme="$HOME/.config/rofi/configs/dmenu.rasi"
title="Clipboard History"

# Replace newlines with a visible symbol for display
NL_REPLACEMENT="↵"

# Rofi command
rofi_cmd() {
    rofi -theme-str "textbox-prompt-colon {str: '';}" \
        -theme-str "window {width: 720px;}" \
        -theme "${theme}" \
        -p "$title" \
        -l 8 \
        -dmenu \
        -markup-rows
}

# Load clipboard history and prepare display lines
run_rofi() {
    mapfile -t lines < <(cliphist list)
    display_lines=()
    for line in "${lines[@]}"; do
        # Remove numeric ID
        clean="$(echo "$line" | sed 's/^[0-9]\+\t//')"
        # Replace newlines with NL_REPLACEMENT for rofi
        clean="${clean//$'\n'/$NL_REPLACEMENT}"
        display_lines+=("$clean")
    done

    # Show rofi menu
    selected_display="$(printf '%s\n' "${display_lines[@]}" | rofi_cmd)"
    echo "$selected_display"
}

# Copy the selected entry to clipboard and remove from history
copy_to_clipboard() {
    selected_display="$1"
    if [[ -n "$selected_display" ]]; then
        # Restore newlines
        cleaned="${selected_display//$NL_REPLACEMENT/$'\n'}"

        # Copy to clipboard
        echo -n "$cleaned" | wl-copy
        notify-send -u low "Clipboard" "Copied: ${cleaned//$'\n'/ }"

        # Find the original line that matches (with numeric ID)
        original_line="$(cliphist list | grep -F "$(echo "$cleaned" | sed 's/[][\\.^$*]/\\&/g')")"

        # Remove original line
        if [[ -n "$original_line" ]]; then
            cliphist remove --exact "$original_line"
        fi
    fi
}

# Main
chosen="$(run_rofi)"
if [[ -n "$chosen" ]]; then
    copy_to_clipboard "$chosen"
fi
