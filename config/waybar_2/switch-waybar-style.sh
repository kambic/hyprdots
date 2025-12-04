#!/usr/bin/env bash
# switch-waybar-style.sh
# -------------------------------------------------
# Switch Waybar style by symlinking config & style.css
# to a chosen subdir under .dotfiles/config/waybar/styles/
#
# Usage:  ./switch-waybar-style.sh [style_name]
#         (style_name must be a directory inside styles/)
#
# If no argument is given, an interactive menu is shown.
# -------------------------------------------------

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STYLES_DIR="${BASE_DIR}/styles"

# -------------------------------------------------------------------------
# Helper: list available styles
# -------------------------------------------------------------------------
list_styles() {
  find "${STYLES_DIR}" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;
}

# -------------------------------------------------------------------------
# Helper: restart Waybar (gracefully)
# -------------------------------------------------------------------------
restart_waybar() {
  if pgrep -x waybar >/dev/null; then
    pkill -x waybar
    waybar >/dev/null 2>&1 &
    echo "Waybar restarted."
  else
    waybar >/dev/null 2>&1 &
    echo "Waybar started."
  fi
}

# -------------------------------------------------------------------------
# Interactive selector (fzf > rofi > dmenu > plain list)
# -------------------------------------------------------------------------
choose_interactive() {
  local choices=($(list_styles))
  local choice

  if command -v fzf >/dev/null; then
    choice=$(printf "%s\n" "${choices[@]}" | fzf --prompt="Select style: ")
  elif command -v rofi >/dev/null; then
    choice=$(printf "%s\n" "${choices[@]}" | rofi -dmenu -p "Waybar style")
  elif command -v dmenu >/dev/null; then
    choice=$(printf "%s\n" "${choices[@]}" | dmenu -p "Waybar style")
  else
    echo "Available styles:"
    local i=1
    for s in "${choices[@]}"; do
      echo "  $i) $s"
      ((i++))
    done
    read -rp "Enter number: " num
    choice="${choices[$((num - 1))]}"
  fi

  echo "$choice"
}

# -------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------
main() {
  local target_style="${1:-}"

  # If no argument, ask interactively
  if [[ -z "$target_style" ]]; then
    target_style=$(choose_interactive)
  fi

  # Validate
  if [[ -z "$target_style" ]]; then
    echo "No style selected."
    exit 1
  fi

  local style_path="${STYLES_DIR}/${target_style}"
  if [[ ! -d "$style_path" ]]; then
    echo "Error: style '$target_style' not found in $STYLES_DIR"
    exit 1
  fi

  # Resolve config file (must exist inside the style dir)
  local config_src="${style_path}/config"
  if [[ ! -f "$config_src" ]]; then
    echo "Error: $config_src not found!"
    exit 1
  fi

  # Resolve style.css (must exist inside the style dir)
  local style_src="${style_path}/style.css"
  if [[ ! -f "$style_src" ]]; then
    echo "Error: $style_src not found!"
    exit 1
  fi

  # Create/overwrite symlinks
  ln -sf "$config_src" "${BASE_DIR}/config"
  ln -sf "$style_src" "${BASE_DIR}/style.css"

  echo "Switched to style: $target_style"
  echo "  config  -> $config_src"
  echo "  style.css -> $style_src"

  # Restart Waybar
  restart_waybar
}

main "$@"
