#!/bin/bash

ICD_DIR="/usr/share/vulkan/icd.d"
LOG_FILE="$HOME/work/steam/wrapper.log"
STAT_FILE="$HOME/work/steam/stat.log"
#!/bin/bash
#########################################################################
# Steam Wrapper with:
# Rofi presets, Gamescope, MangoHud, Debug mode,
# AMD RADV_PERFTEST optimization presets,
# RAMFS full-copy mode with Zenity progress bar,
# OverlayFS RAM acceleration mode.
#########################################################################

########################################
# ENV / BASE CONFIG
########################################
ICD_DIR="/usr/share/vulkan/icd.d"
LOG_FILE="$HOME/work/steam/wrapper.log"

export MESA_SHADER_CACHE_MAX_SIZE=12G
export LD_BIND_NOW=1
export VK_DRIVER_FILES="${ICD_DIR}/radeon_icd.i686.json:${ICD_DIR}/radeon_icd.x86_64.json"
export DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1=1

echo "[wrapper] Starting wrapper…" >"$LOG_FILE"

########################################
# ROFI PRESET MENU
########################################
choose_preset() {
  printf "%s\n" \
    "Normal" \
    "MangoHud" \
    "Gamescope 1440p" \
    "RAMFS Copy (Full RAM)" \
    "OverlayFS RAM Accel" \
    "AMD Ultra (nggc,gpl,sam)" \
    "AMD NGGC" \
    "AMD GPL" \
    "AMD SAM" \
    "AMD Disable Perftest" \
    "Debug VK Validation" \
    "Native (Disable Wrapper)" |
    rofi -dmenu -i -p "Launch mode"
}

preset=$(choose_preset)
[ -z "$preset" ] && exit 0

########################################
# APPLY PRESET FLAGS
########################################
USE_GAMESCOPE=0
USE_RAMFS=0
USE_OVERLAY=0

case "$preset" in
"Normal") ;;
"MangoHud")
  export VK_LOADER_LAYERS_ENABLE=VK_LAYER_MANGOHUD_overlay_x86_64
  ;;
"Gamescope 1440p")
  USE_GAMESCOPE=1
  ;;
"RAMFS Copy (Full RAM)")
  USE_RAMFS=1
  ;;
"OverlayFS RAM Accel")
  USE_OVERLAY=1
  ;;
"AMD Ultra (nggc,gpl,sam)")
  export RADV_PERFTEST="nggc,gpl,sam"
  ;;
"AMD NGGC")
  export RADV_PERFTEST="nggc"
  ;;
"AMD GPL")
  export RADV_PERFTEST="gpl"
  ;;
"AMD SAM")
  export RADV_PERFTEST="sam"
  ;;
"AMD Disable Perftest")
  unset RADV_PERFTEST
  ;;
"Debug VK Validation")
  export VK_LOADER_LAYERS_ENABLE=VK_LAYER_KHRONOS_validation
  export RADV_DEBUG=all
  ;;
"Native (Disable Wrapper)")
  exec "$@"
  ;;
esac

########################################
# GAME DIRECTORY (Steam sets PWD)
########################################
GAME_PATH="$PWD"
echo "[wrapper] GAME PATH: $GAME_PATH" >>"$LOG_FILE"

########################################
# RAMFS MODE — Full Copy to /dev/shm
########################################
if [[ "$USE_RAMFS" == 1 ]]; then
  RAMDIR="/dev/shm/game_ramfs"
  rm -rf "$RAMDIR"
  mkdir -p "$RAMDIR"

  echo "[wrapper] RAMFS copy enabled" | tee -a "$LOG_FILE"

  # Total game size for progress tracking
  TOTAL_BYTES=$(du -sb "$GAME_PATH" | awk '{print $1}')
  echo "[wrapper] Game total bytes: $TOTAL_BYTES" >>"$LOG_FILE"

  # Copy with Zenity GUI progress bar
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
      --text="Copying game files to RAM…" \
      --percentage=0 --auto-close --auto-kill
  else
    # Terminal fallback
    echo "[wrapper] Zenity not found — using terminal progress" | tee -a "$LOG_FILE"
    rsync -a --info=progress2 "$GAME_PATH/" "$RAMDIR/" | pv -p -t -e -s "$TOTAL_BYTES"
  fi

  cd "$RAMDIR"
  echo "[wrapper] Running game from RAMFS: $RAMDIR" >>"$LOG_FILE"
fi

########################################
# OVERLAYFS MODE — Write to RAM, Read from SSD
########################################
if [[ "$USE_OVERLAY" == 1 ]]; then
  UPPER="/dev/shm/game_upper"
  WORK="/dev/shm/game_work"
  MERGED="/dev/shm/game_overlay"

  echo "[wrapper] Setting up OverlayFS…" | tee -a "$LOG_FILE"

  rm -rf "$UPPER" "$WORK" "$MERGED"
  mkdir -p "$UPPER" "$WORK" "$MERGED"

  sudo mount -t overlay overlay \
    -o lowerdir="$GAME_PATH",upperdir="$UPPER",workdir="$WORK" \
    "$MERGED"

  cd "$MERGED"
  echo "[wrapper] Running game from OverlayFS merged path: $MERGED" >>"$LOG_FILE"
fi

########################################
# RUN THE GAME
########################################
if [[ "$USE_GAMESCOPE" == 1 ]]; then
  echo "[wrapper] Launching through Gamescope…" >>"$LOG_FILE"
  exec gamescope \
    -f \
    -H 1440 \
    --mangoapp \
    --force-grab-cursor \
    --adaptive-sync \
    --immediate-flips \
    --backend sdl -- "$@"
else
  echo "[wrapper] Launching native…" >>"$LOG_FILE"
  exec "$@"
fi
