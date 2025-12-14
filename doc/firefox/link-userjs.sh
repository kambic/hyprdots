#!/usr/bin/env bash
PROFILE_DIR="$HOME/.mozilla/firefox"

for profile in "$PROFILE_DIR"/*.default-release; do
  # ln -sf "$PWD/user.js" "$profile/user.js"
  echo "Linked user.js to $profile"
done
