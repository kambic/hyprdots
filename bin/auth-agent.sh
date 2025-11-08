#!/bin/bash

# This script is used to launch the polkit and restart it if it crashes.
while true; do
	/usr/lib/hyprpolkitagent/hyprpolkitagent

	echo "Hyprpolkitagent crashed. Restarting ..." | systemd-cat -t hyprdots -p error

	sleep 1
done
