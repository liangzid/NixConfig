#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

if ! pgrep -x "awww-daemon" > /dev/null; then
    awww-daemon &
    sleep 1
fi

while true; do
    BG=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 1)

    awww img "$BG" --transition-type wave --transition-angle 30 --transition-step 90 --transition-fps 60

    sleep 300
done
