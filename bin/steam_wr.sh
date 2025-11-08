#!/bin/bash
# Usage: ./wrapper.sh [--disable] [command args...]

ICD_DIR="/usr/share/vulkan/icd.d"
LOG_FILE="$HOME/work/steam/wrapper.log"
STAT_FILE="$HOME/work/steam/stat.log"
export MESA_SHADER_CACHE_MAX_SIZE=12G
# export LD_PRELOAD=""
# export LD_PRELOAD="/usr/lib/libgamemodeauto.so.0"
export LD_BIND_NOW=1
# export RADV_PERFTEST=nggc,gpl,sam
# export VK_LOADER_LAYERS_ENABLE=VK_LAYER_MANGOHUD_overlay_x86_64
export VK_DRIVER_FILES="${ICD_DIR}/radeon_icd.i686.json:${ICD_DIR}/radeon_icd.x86_64.json"
export DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1=1

# Toggle runmode
DISABLED=false
if [[ "$1" == "--disable" ]]; then
  DISABLED=true
  shift
fi

# If no command provided, show usage and exit
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 [--disable] <command> [args...]"
  exit 1
fi

# Log setup
echo "" >"$LOG_FILE"
log() {
  echo "[wrapper] $@" | tee "$LOG_FILE"
}
# Wrapper
if $DISABLED; then
  log "[ DIRECT  RUN ] [cmdline]: $*"
  "$@" | tee "$LOG_FILE"
else
  gamemoderun \
  gamescope \
    -f \
    -H 1440 \
    --mangoapp \
    --force-grab-cursor \
    --adaptive-sync \
    --immediate-flips \
    --backend sdl -- "$@"
fi
