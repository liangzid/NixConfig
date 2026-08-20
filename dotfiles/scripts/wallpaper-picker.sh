#!/usr/bin/env bash
# 只轮换本仓库经 home-manager 链到 ~/Pictures 的图（store 符号链接）。
# 来源：dotfiles/wallpapers 与 images/。排除 README 截图；忽略用户另放的普通文件。

WALLPAPER_DIRS=("$HOME/Pictures/Wallpapers" "$HOME/Pictures/Images")

list_repo_wallpapers() {
    local dir
    for dir in "${WALLPAPER_DIRS[@]}"; do
        [ -d "$dir" ] || continue
        find "$dir" -maxdepth 1 -type l \( \
            -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \
        \) ! -name "screenshot_*"
    done
}

set_wallpaper() {
    local bg
    bg="$(list_repo_wallpapers | shuf -n 1)"
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
