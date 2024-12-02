#!/bin/bash
while true; do
    RANDOM_WALLPAPER="$(find ~/.config/hypr/hyprpaper/backgrounds/walls-catppuccin-mocha/ -type f | shuf -n 1)"
    hyprpaper --config ~/.config/hypr/hyprpaper/hyprpaper.conf --wallpaper "monitor_name,$RANDOM_WALLPAPER"
    sleep 3600  # 3600 seconds = 1 hour
done


