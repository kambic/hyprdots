#!/usr/bin/env bash

# Run wofi drun and capture output
D="$(wofi --show drun --define=drun-print_desktop_file=true)"

# Convert "foo.desktop Foo" → "foo.desktop:Foo"
case "$D" in
  *'.desktop '*)
    APP="${D%.desktop *}.desktop:${D#*.desktop }"
    ;;
  *)
    APP="$D"
    ;;
esac

# Launch via uwsm
exec uwsm app -- "$APP"
