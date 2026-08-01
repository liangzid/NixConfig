#!/usr/bin/env bash

WALLPAPER_DIRS=("$HOME/Pictures/Wallpapers" "$HOME/Pictures/Images")

set_wallpaper() {
    local bg
    bg=$(for dir in "${WALLPAPER_DIRS[@]}"; do
        [ -d "$dir" ] && find -L "$dir" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) ! -name "screenshot_*" 2>/dev/null
    done | shuf -n 1)
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
    sleep 180
    set_wallpaper
done
