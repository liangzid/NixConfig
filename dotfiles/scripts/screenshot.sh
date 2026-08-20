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

case "$1" in
  area)
    grimblast --freeze save area - | satty \
      --filename - \
      --early-exit \
      --copy-command wl-copy \
      --output-filename "$outdir/satty-$(date +%Y%m%d-%H%M%S).png"
    ;;
  screen)
    grimblast --notify copy screen
    ;;
  *)
    usage
    ;;
esac
