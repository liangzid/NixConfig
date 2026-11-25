#!/usr/bin/env bash
set -euo pipefail

# ======================================================================
# LOCK
#
# 1. Single-instance swaylock for Super+L, lid close, and swayidle
#    before-sleep. A second instance steals ext-session-lock and the
#    password field stops receiving keys.
# 2. Call graph:
#      hyprland.lua Super+L / switch:on:Lid Switch / swayidle before-sleep
#        └─ lock.sh
#             └─ swaylock -f (fork after the lock is acquired)
# 3. 25 November 2026: drop `-S` screenshot+blur. On this NVIDIA hybrid
#    it raced suspend and left a blur-only surface with no indicator.
#
# Author: Zi Liang <zi1415926.liang@connect.polyu.hk>
# Copyright © 2026, Zi Liang, all rights reserved.
# Created: 25 November 2026
# ======================================================================

if pgrep -x swaylock >/dev/null; then
  exit 0
fi

# Solid Tokyo-Night panel + always-on ring so keypresses are visible.
# Do not add -S / --effect-blur: screenshot during lid-close suspend
# is what produced the "just a blur, cannot type" lock screen.
exec swaylock -f \
  --ignore-empty-password \
  --show-failed-attempts \
  --indicator \
  --indicator-idle-visible \
  --clock \
  --timestr '%H:%M' \
  --datestr '%Y-%m-%d' \
  --font 'Sarasa UI SC' \
  --font-size 28 \
  --indicator-radius 140 \
  --indicator-thickness 10 \
  --color 1a1b26 \
  --inside-color 1a1b26 \
  --inside-ver-color 1a1b26 \
  --inside-wrong-color 1a1b26 \
  --inside-clear-color 1a1b26 \
  --ring-color 7aa2f7 \
  --ring-ver-color e0af68 \
  --ring-wrong-color f7768e \
  --ring-clear-color 7aa2f7 \
  --line-color 00000000 \
  --separator-color 00000000 \
  --text-color c0caf5 \
  --text-ver-color e0af68 \
  --text-wrong-color f7768e \
  --text-clear-color c0caf5 \
  --key-hl-color 9ece6a \
  --bs-hl-color f7768e
