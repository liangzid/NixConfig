#!/usr/bin/env bash
set -euo pipefail

# ======================================================================
# SCREENSHOT
#
# 1. 用 grimblast 截图，区域交给 satty 标注（替代 grim|slurp|swappy）。
# 2. 调用链：
#      hyprland.lua Print / XF86Calculator
#        └─ screenshot.sh area   → grimblast --freeze save area - | satty
#      hyprland.lua CTRL+Print / CTRL+XF86Calculator
#        └─ screenshot.sh screen → grimblast --notify copy screen
# 3. 修改历史：
#      2026-08-20 创建：快捷键不变，换截图/标注工具。
#      2026-08-30 修复：显式使用显示器的 1.5 倍缩放，避免截图重采样发虚。
#
#     Author: Zi Liang <zi1415926.liang@connect.polyu.hk>
#     Copyright © 2026, Zi Liang, all rights reserved.
#     Created: 20 August 2026
# ======================================================================

usage() {
  echo "用法: screenshot.sh area|screen" >&2
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
fi

outdir="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$outdir"

# REVIEW: 必须与 hyprland.lua 中显示器的 scale 保持一致，确保按 4K 原生像素输出。
screenshot_scale="1.5"

case "$1" in
  area)
    grimblast --freeze --scale "$screenshot_scale" save area - | satty \
      --filename - \
      --early-exit \
      --copy-command wl-copy \
      --output-filename "$outdir/satty-$(date +%Y%m%d-%H%M%S).png"
    ;;
  screen)
    grimblast --notify --scale "$screenshot_scale" copy screen
    ;;
  *)
    usage
    ;;
esac
