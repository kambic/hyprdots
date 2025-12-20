#!/bin/bash

# Improved notification demo: Focus on interactive notifications and progress bars
# Uses minimal sleeps (only enough to see changes)
# Requires: libnotify (notify-send)
# For full interactivity (buttons that do something), we use a trick with dunstify if available,
# otherwise fall back to basic notify-send actions.
# Progress bar works best with daemons that support value hints (mako, dunst, fnott).

# Check if dunstify is available (better for replacing notifications and actions)
if command -v dunstify >/dev/null 2>&1; then
    USE_DUNSTIFY=true
    echo "Using dunstify for better interactivity and progress updates"
else
    USE_DUNSTIFY=false
    echo "dunstify not found – falling back to notify-send (limited interactivity)"
fi

echo "Starting interactive & progress demo..."

# -----------------------------
# 1. Simple interactive notification with buttons
# -----------------------------
if $USE_DUNSTIFY; then
    response=$(dunstify --action="yes,Yes" --action="no,No" --action="cancel,Cancel" \
        "Question" "Do you like this demo?")

    case "$response" in
        "yes")    notify-send "Great! 😊" "You clicked Yes." ;;
        "no")     notify-send "Oh no! 😢" "You clicked No." ;;
        "cancel") notify-send "Canceled" "You clicked Cancel." ;;
        *)        notify-send "Dismissed" "Notification was closed without action." ;;
    esac
else
    # Basic notify-send actions (prints to stdout, doesn't wait)
    notify-send "Question (notify-send)" "Choose an option if your daemon supports buttons" \
        --action="reply1:Good" --action="reply2:Bad" --action="reply3:Maybe"
    echo "(With plain notify-send, button clicks only show in daemon history – no script feedback)"
fi

sleep 1.5

# -----------------------------
# 2. Real-time progress bar (replaces the same notification)
# -----------------------------
if $USE_DUNSTIFY; then
    # dunstify can replace by ID
    id=$(dunstify --printid "Task in progress" "Starting... 0%")
    
    for i in {1..20}; do
        percent=$((i * 5))
        dunstify --replace="$id" "Task in progress" "$percent% complete" -h int:value:$percent
        sleep 0.15  # Fast but visible
    done
    
    dunstify --replace="$id" "Task Complete! ✅" "100% done" -h int:value:100 -t 5000
else
    # Fallback: send new notifications (no smooth replacement, but progress hint still works)
    notify-send "Task Starting" "0%" -h int:value:0
    
    for i in {1..20}; do
        percent=$((i * 5))
        notify-send "Task in progress" "$percent% complete" -h int:value:$percent
        sleep 0.15
    done
    
    notify-send "Task Complete! ✅" "100% done" -h int:value:100 -t 5000
fi

sleep 1

# -----------------------------
# 3. Another interactive example: Confirm action
# -----------------------------
if $USE_DUNSTIFY; then
    answer=$(dunstify -u critical --action="confirm,Confirm" --action="abort,Cancel" \
        "Dangerous Action" "Are you sure you want to proceed?")

    if [[ "$answer" == "confirm" ]]; then
        notify-send "Proceeding..." "Action confirmed."
    else
        notify-send "Aborted" "Action canceled or dismissed."
    fi
fi

echo "Demo finished!"
