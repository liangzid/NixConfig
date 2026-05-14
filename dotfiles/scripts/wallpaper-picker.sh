#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

set_wallpaper() {
    local bg
    bg=$(find -L "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null | shuf -n 1)
    if [ -n "$bg" ]; then
        awww img "$bg" --transition-type wave --transition-angle 30 --transition-step 90 --transition-fps 60
    fi
}

if ! awww query >/dev/null 2>&1; then
    awww-daemon 2>/dev/null &
    sleep 1
fi

set_wallpaper

while true; do
    sleep 300
    set_wallpaper
done
