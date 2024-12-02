#!/bin/bash

sleep 2
# Start Waybar if not running
if ! pgrep -x "waybar" > /dev/null; then
    waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/styles.css &
    echo "Waybar started."
else
    echo "Waybar is already running."
fi

