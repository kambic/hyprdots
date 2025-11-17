#!/bin/bash

ICD_DIR="/usr/share/vulkan/icd.d"
LOG_FILE="$HOME/work/steam/wrapper.log"
STAT_FILE="$HOME/work/steam/stat.log"

export MESA_SHADER_CACHE_MAX_SIZE=12G
export LD_BIND_NOW=1
export VK_DRIVER_FILES="${ICD_DIR}/radeon_icd.i686.json:${ICD_DIR}/radeon_icd.x86_64.json"
export DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1=1

# --- launch presets ---
show_menu() {
  printf "%s\n" \
    "Normal" \
    "MangoHud" \
    "Gamescope 1440p" \
    "Native (Disable Wrapper)" \
    "Debug VK_LAYER" |
    rofi -dmenu -i -p "Launch mode"
}

preset=$(show_menu)
[ -z "$preset" ] && exit 0

case "$preset" in
"Normal") ;; # nothing extra
"MangoHud")
  export VK_LOADER_LAYERS_ENABLE=VK_LAYER_MANGOHUD_overlay_x86_64
  ;;
"Gamescope 1440p")
  USE_GAMESCOPE=1
  ;;
"Native (Disable Wrapper)")
  exec "$@"
  ;;
"Debug VK_LAYER")
  export VK_LOADER_LAYERS_ENABLE=VK_LAYER_KHRONOS_validation
  ;;
esac

# --- run mode ---
if [[ "$USE_GAMESCOPE" == 1 ]]; then
  exec gamescope \
    -f \
    -H 1440 \
    --mangoapp \
    --force-grab-cursor \
    --adaptive-sync \
    --immediate-flips \
    --backend sdl -- "$@"
else
  exec "$@"
fi
