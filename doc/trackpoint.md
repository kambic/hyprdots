Below is a **complete, copy-and-paste-ready** guide to turn the ThinkPad W550s touchpad (or any libinput device) into a **gesture powerhouse** under **Hyprland**.  
All bindings live in `~/.config/hypr/hyprland.conf` – no external tools required after the one-time setup.

---

## 1. Install the gesture daemon (Hyprland already uses libinput, but we need a tiny helper)

```bash
# Arch / Fedora / openSUSE
sudo pacman -S libinput-gestures   # or dnf install libinput-gestures
# Debian / Ubuntu
sudo apt install libinput-tools xdotool wmctrl
```

> **Why?** Hyprland can read libinput events, but the daemon translates *multi-finger swipes* into clean `gesture_*` events that Hyprland can bind.

---

## 2. Enable & start the daemon

```bash
# Add yourself to the input group
sudo gpasswd -a $USER input

# Start now
libinput-gestures-setup start

# Enable at login (Hyprland exec-once)
echo "exec-once = libinput-gestures-setup start" >> ~/.config/hypr/hyprland.conf
```

---

## 3. Advanced Gesture Bindings (copy into `hyprland.conf`)

```conf
# ──────────────────────────────────────────────────────────────
#  GESTURE BINDINGS – ThinkPad W550s optimized
# ──────────────────────────────────────────────────────────────

# 3-finger swipe LEFT / RIGHT  →  workspace prev / next
bind = , gesture_swipe_left_3,  workspace e-1
bind = , gesture_swipe_right_3, workspace e+1

# 3-finger swipe UP / DOWN     →  previous / next workspace (vertical)
bind = , gesture_swipe_up_3,    workspace e-1
bind = , gesture_swipe_down_3,  workspace e+1

# 4-finger swipe LEFT / RIGHT  →  switch monitor focus
bind = , gesture_swipe_left_4,  focusmonitor e-1
bind = , gesture_swipe_right_4, focusmonitor e+1

# 4-finger swipe UP            →  overview (all workspaces)
bind = , gesture_swipe_up_4,    exec, hyprctl dispatch overview

# 4-finger swipe DOWN          →  close overview / fullscreen toggle
bind = , gesture_swipe_down_4,  exec, hyprctl dispatch fullscreen 1

# 3-finger TAP                 →  middle click (paste)
bind = , gesture_tap_3,         exec, xdotool click 2

# 4-finger TAP                 →  show desktop (minimize all)
bind = , gesture_tap_4,         exec, hyprctl dispatch togglespecialworkspace

# Pinch IN / OUT               →  zoom desktop (Hyprland 0.41+)
bind = , gesture_pinch_in,      exec, hyprctl keyword general:scale 0.9
bind = , gesture_pinch_out,     exec, hyprctl keyword general:scale 1.1

# Hold 3 fingers + drag        →  move window
bind = , gesture_hold_3,        movewindow

# Edge swipes (optional – needs libinput-gestures edge support)
bind = , gesture_swipe_up_edge,    exec, wofi --show drun   # app launcher
bind = , gesture_swipe_down_edge,  exec, grim -g "$(slurp)" # screenshot region
```

> **Tip:** Use `libinput debug-events` to verify your touchpad reports 3-/4-finger gestures. W550s Synaptics usually caps at **3-finger**, so 4-finger bindings are *optional* (they’ll just be ignored).

---

## 4. Fine-tune gesture thresholds (optional)

Edit `~/.config/libinput-gestures.conf` (create if missing):

```ini
gesture swipe threshold 30
gesture swipe timeout 300
gesture pinch threshold 0.2
gesture hold fingers 3
```

Restart daemon: `libinput-gestures-setup restart`

---

## 5. Test gestures live

```bash
# Watch raw events
libinput debug-events | grep -i gesture
```

You should see lines like:

```
GESTURE_SWIPE_BEGIN   +0.00s   3 fingers
GESTURE_SWIPE_UPDATE  +0.12s   dx=-120.0 dy=0.0
GESTURE_SWIPE_END     +0.25s   3 fingers
```

---

## 6. Bonus: TrackPoint + Touchpad *dual-mode* gestures

```conf
# Use TrackPoint middle button + touchpad 2-finger scroll = natural scroll
input {
    touchpad {
        middle_button_emulation = yes
        natural_scroll = yes
    }
}

# 2-finger scroll on touchpad = workspace scroll (vertical)
bind = , gesture_scroll_up_2,   workspace e-1
bind = , gesture_scroll_down_2, workspace e+1
```

---

## 7. Full Example Snippet (drop into `hyprland.conf`)

```conf
exec-once = libinput-gestures-setup start

input {
    touchpad {
        natural_scroll = yes
        disable_while_typing = yes
        tap-to-click = yes
        scroll_factor = 0.7
    }
}

# ─── GESTURES ───
bind = , gesture_swipe_left_3,  workspace e-1
bind = , gesture_swipe_right_3, workspace e+1
bind = , gesture_swipe_up_3,    workspace e-1
bind = , gesture_swipe_down_3,  workspace e+1
bind = , gesture_tap_3,         exec, xdotool click 2
bind = , gesture_swipe_up_edge, exec, wofi --show drun
```

---

**Done.**  
Your W550s now has **macOS-level gestures** under Hyprland:  

- 3-finger swipe → workspace switch  
- 3-finger tap → middle click  
- Edge swipe → launcher  
- Optional 4-finger & pinch  

Reload: `hyprctl reload`  
Test. Tweak thresholds. Enjoy.
