#!/bin/bash
# Steam Wrapper Cleanup Helper
# Unmounts OverlayFS and cleans RAMFS directories safely

# Paths used in the wrapper
OVERLAY_MERGED="/dev/shm/game_overlay"
OVERLAY_UPPER="/dev/shm/game_upper"
OVERLAY_WORK="/dev/shm/game_work"
RAMDIR="/dev/shm/game_ramfs"

echo "[cleanup] Starting cleanup..."

# OverlayFS cleanup
if mountpoint -q "$OVERLAY_MERGED"; then
  echo "[cleanup] Unmounting OverlayFS at $OVERLAY_MERGED..."
  sudo umount "$OVERLAY_MERGED" || echo "[cleanup] Failed to unmount OverlayFS"
fi
rm -rf "$OVERLAY_MERGED" "$OVERLAY_UPPER" "$OVERLAY_WORK"
echo "[cleanup] OverlayFS directories removed."

# RAMFS cleanup
if [[ -d "$RAMDIR" ]]; then
  echo "[cleanup] Removing RAMFS at $RAMDIR..."
  rm -rf "$RAMDIR"
fi

echo "[cleanup] Done."
