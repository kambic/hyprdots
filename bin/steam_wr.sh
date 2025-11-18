#!/bin/bash
#########################################################################
# Steam Wrapper - Full Version
# Features:
# - Rofi submenus (Steam Deck style)
# - Remember last-used presets per game
# - Quick toggle checkboxes
# - GPU optimization profiles
# - Gamescope, MangoHud, Debug modes
# - RAMFS / OverlayFS acceleration
#########################################################################

set -e

########################################
# CONFIG / ENV
########################################
ICD_DIR="/usr/share/vulkan/icd.d"
LOG_FILE="$HOME/work/steam/wrapper.log"
PREF_DIR="$HOME/.config/steam-wrapper/prefs"
mkdir -p "$PREF_DIR"

export MESA_SHADER_CACHE_MAX_SIZE=12G
export LD_BIND_NOW=1
export VK_DRIVER_FILES="${ICD_DIR}/radeon_icd.i686.json:${ICD_DIR}/radeon_icd.x86_64.json"
export DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1=1

echo "[wrapper] Starting wrapper..." >"$LOG_FILE"

########################################
# HELPER FUNCTIONS
########################################

# Read preference file if exists
load_prefs() {
  local appid="$1"
  PREF_FILE="$PREF_DIR/${appid}.json"
  if [[ -f "$PREF_FILE" ]]; then
    launch_mode=$(jq -r '.launch_mode' "$PREF_FILE")
    gpu_profile=$(jq -r '.gpu_profile' "$PREF_FILE")
    mangohud_toggle=$(jq -r '.toggles.mangohud' "$PREF_FILE")
    debug_toggle=$(jq -r '.toggles.debug' "$PREF_FILE")
  else
    launch_mode="Normal"
    gpu_profile="No GPU Optimizations"
    mangohud_toggle=false
    debug_toggle=false
  fi
}

# Save preferences
save_prefs() {
  local appid="$1"
  mkdir -p "$PREF_DIR"
  cat >"$PREF_DIR/${appid}.json" <<EOF
{
  "launch_mode": "$launch_mode",
  "gpu_profile": "$gpu_profile",
  "toggles": {
    "mangohud": $mangohud_toggle,
    "debug": $debug_toggle
  }
}
EOF
}

# Toggle display for checkbox
toggle_display() {
  local state="$1"
  if [[ "$state" == "true" ]]; then
    echo "[✔]"
  else
    echo "[ ]"
  fi
}

# Rofi select with optional preselection
rofi_select() {
  local prompt="$1"
  shift
  local options=("$@")
  printf "%s\n" "${options[@]}" | rofi -dmenu -i -p "$prompt"
}

########################################
# GAME INFO
########################################
GAME_PATH="$PWD"
GAME_NAME=$(basename "$GAME_PATH")
APPID=$(basename "$GAME_PATH") # fallback if Steam APPID not available

load_prefs "$APPID"

########################################
# MAIN MENU LOOP
########################################

while true; do
  main_choice=$(rofi_select "Steam Wrapper" \
    "Launch Mode →" \
    "GPU Profile →" \
    "Toggles →" \
    "Start Game" \
    "Exit")

  case "$main_choice" in
  "Launch Mode →")
    launch_mode=$(rofi_select "Launch Mode" \
      "Normal" \
      "Gamescope 1440p" \
      "RAMFS Copy (Full RAM)" \
      "OverlayFS RAM Accel" \
      "Back")
    [[ "$launch_mode" == "Back" ]] && continue
    ;;

  "GPU Profile →")
    gpu_profile=$(rofi_select "GPU Profile" \
      "No GPU Optimizations" \
      "NGGC" \
      "GPL" \
      "SAM" \
      "Ultra (nggc,gpl,sam)" \
      "Back")
    [[ "$gpu_profile" == "Back" ]] && continue
    ;;

  "Toggles →")
    while true; do
      mangohud_label="$(toggle_display $mangohud_toggle) MangoHud"
      debug_label="$(toggle_display $debug_toggle) Debug VK Validation"

      toggle_choice=$(rofi_select "Toggles" \
        "$mangohud_label" \
        "$debug_label" \
        "Back")

      case "$toggle_choice" in
      "$mangohud_label") mangohud_toggle=$([ "$mangohud_toggle" == "true" ] && echo false || echo true) ;;
      "$debug_label") debug_toggle=$([ "$debug_toggle" == "true" ] && echo false || echo true) ;;
      "Back") break ;;
      esac
    done
    ;;

  "Start Game")
    save_prefs "$APPID"
    break
    ;;

  "Exit")
    exit 0
    ;;
  esac
done

########################################
# APPLY SETTINGS
########################################

# GPU Profile
case "$gpu_profile" in
"No GPU Optimizations") unset RADV_PERFTEST ;;
"NGGC") export RADV_PERFTEST="nggc" ;;
"GPL") export RADV_PERFTEST="gpl" ;;
"SAM") export RADV_PERFTEST="sam" ;;
"Ultra (nggc,gpl,sam)") export RADV_PERFTEST="nggc,gpl,sam" ;;
esac

# Toggles
[[ "$mangohud_toggle" == "true" ]] && export VK_LOADER_LAYERS_ENABLE="VK_LAYER_MANGOHUD_overlay_x86_64"
[[ "$debug_toggle" == "true" ]] && export VK_LOADER_LAYERS_ENABLE="VK_LAYER_KHRONOS_validation" && export RADV_DEBUG=all

# Flags
USE_GAMESCOPE=0
USE_RAMFS=0
USE_OVERLAY=0

case "$launch_mode" in
"Normal") ;;
"Gamescope 1440p") USE_GAMESCOPE=1 ;;
"RAMFS Copy (Full RAM)") USE_RAMFS=1 ;;
"OverlayFS RAM Accel") USE_OVERLAY=1 ;;
esac

########################################
# RAMFS MODE
########################################
if [[ "$USE_RAMFS" == 1 ]]; then
  RAMDIR="/dev/shm/game_ramfs"
  rm -rf "$RAMDIR"
  mkdir -p "$RAMDIR"
  TOTAL_BYTES=$(du -sb "$GAME_PATH" | awk '{print $1}')

  if command -v zenity >/dev/null 2>&1; then
    (
      rsync -a --info=progress2 "$GAME_PATH/" "$RAMDIR/" 2>&1 |
        while IFS= read -r line; do
          if [[ "$line" =~ ([0-9]+)% ]]; then
            echo "${BASH_REMATCH[1]}"
          elif [[ "$line" =~ ([0-9]+)\  ]]; then
            BYTES="${BASH_REMATCH[1]}"
            echo $((BYTES * 100 / TOTAL_BYTES))
          fi
        done
    ) | zenity --progress \
      --title="Copying Game to RAMFS" \
      --text="Copying game files…" \
      --percentage=0 --auto-close --auto-kill
  else
    rsync -a --info=progress2 "$GAME_PATH/" "$RAMDIR/"
  fi
  cd "$RAMDIR"
fi

########################################
# OVERLAYFS MODE
########################################
if [[ "$USE_OVERLAY" == 1 ]]; then
  UPPER="/dev/shm/game_upper"
  WORK="/dev/shm/game_work"
  MERGED="/dev/shm/game_overlay"
  rm -rf "$UPPER" "$WORK" "$MERGED"
  mkdir -p "$UPPER" "$WORK" "$MERGED"

  sudo mount -t overlay overlay -o lowerdir="$GAME_PATH",upperdir="$UPPER",workdir="$WORK" "$MERGED"
  cd "$MERGED"
fi

########################################
# RUN GAME
########################################
if [[ "$USE_GAMESCOPE" == 1 ]]; then
  exec gamescope -f -H 1440 --mangoapp --force-grab-cursor --adaptive-sync --immediate-flips --backend sdl -- "$@"
else
  exec "$@"
fi

# Auto-clean overlayfs & ramfs on exit
# trap "$HOME/bin/steam_wr_cleanup.sh" EXIT
