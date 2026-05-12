#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

set_wallpaper() {
    local bg
    bg=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null | shuf -n 1)
    if [ -n "$bg" ]; then
        awww img "$bg" --transition-type wave --transition-angle 30 --transition-step 90 --transition-fps 60
    fi
}

awww kill 2>/dev/null
sleep 0.5

awww-daemon &
sleep 1

set_wallpaper

while true; do
    sleep 300
    set_wallpaper
done
