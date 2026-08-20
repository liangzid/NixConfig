#!/usr/bin/env bash
set -euo pipefail

# ======================================================================
# CLIPBOARD-HIST
#
# 1. 从 cliphist 弹出 wofi 选一条，写回剪贴板。
# 2. 调用链：hyprland.lua Super+Shift+V → clipboard-hist.sh
#      → cliphist list | wofi | cliphist decode | wl-copy
# 3. 修改历史：
#      2026-08-20 创建：不占用 Super+V（仍是浮动窗口）。
#
#     Author: Zi Liang <zi1415926.liang@connect.polyu.hk>
#     Copyright © 2026, Zi Liang, all rights reserved.
#     Created: 20 August 2026
# ======================================================================

selection="$(cliphist list | wofi --dmenu --prompt clipboard || true)"
if [[ -z "$selection" ]]; then
  exit 0
fi
printf '%s' "$selection" | cliphist decode | wl-copy
