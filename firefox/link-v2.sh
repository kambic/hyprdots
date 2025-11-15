#!/usr/bin/env bash
# Fully automated Firefox user.js installer for all profiles
# Backs up existing user.js before symlinking

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIREFOX_PROFILES="$HOME/.mozilla/firefox"

if [ ! -d "$FIREFOX_PROFILES" ]; then
  echo "No Firefox profiles found at $FIREFOX_PROFILES"
  exit 1
fi

for profile in "$FIREFOX_PROFILES"/*.default*; do
  if [ -f "$profile/user.js" ]; then
    BACKUP="$profile/user.js.bak.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing user.js in $profile to $BACKUP"
    mv "$profile/user.js" "$BACKUP"
  fi
  ln -sf "$DOTFILES_DIR/user.js" "$profile/user.js"
  echo "Linked user.js to $profile"
done
