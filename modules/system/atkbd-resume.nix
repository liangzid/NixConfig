# ======================================================================
# ATKBD-RESUME
#
# 1. After s2idle, this laptop's i8042 AT keyboard often fails to come
#    back (`atkbd serio0: Failed to enable keyboard`). kanata still holds
#    an exclusive grab on the dead node, so swaylock gets no keys.
# 2. Call graph:
#      systemd-sleep resume
#        └─ powerManagement.resumeCommands
#             ├─ unbind+bind serio0 on the atkbd driver
#             └─ systemctl try-restart kanata-internalKeyboard
#      boot.kernelParams i8042.reset / i8042.nomux / atkbd.reset
#        └─ kernel resume path (needs reboot to take effect)
# 3. 25 November 2026: lid close 10:23 → resume 10:23:47 showed both
#    atkbd enable failure and kanata `failed poll: Interrupted system
#    call`; lock screen then accepted no password. Arch i8042 workaround
#    (serio unbind/bind) plus kanata restart.
#
# Author: Zi Liang <zi1415926.liang@connect.polyu.hk>
# Copyright © 2026, Zi Liang, all rights reserved.
# Created: 25 November 2026
# ======================================================================

{ pkgs, ... }:

let
  # KEYPOINT (review): keep this root-only and sequential. Bind must
  # finish before kanata restarts, or kanata grabs the stale event node.
  rebindAtkbd = pkgs.writeShellScript "rebind-atkbd-after-resume" ''
    set -eu
    sleep 1
    if [ -e /sys/bus/serio/drivers/atkbd/unbind ]; then
      printf '%s' serio0 > /sys/bus/serio/drivers/atkbd/unbind || true
      sleep 0.3
      printf '%s' serio0 > /sys/bus/serio/drivers/atkbd/bind || true
    fi
    sleep 0.5
    ${pkgs.systemd}/bin/systemctl try-restart kanata-internalKeyboard.service || true
  '';
in
{
  # i8042.reset=1: reset the controller on resume (the dmesg we saw).
  # i8042.nomux=1: skip active-multiplexing probe; common on AMD laptops.
  # atkbd.reset=1: reset the keyboard device itself after resume.
  # These only apply after a reboot; the script above applies on the next
  # suspend/resume without a reboot.
  boot.kernelParams = [
    "i8042.reset=1"
    "i8042.nomux=1"
    "atkbd.reset=1"
  ];

  powerManagement.resumeCommands = ''
    ${rebindAtkbd}
  '';
}
