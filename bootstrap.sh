#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/liangzid/nix-config.git"
CONFIG_DIR="/home/zi/code/NixConfig"
# path: 包含本机未跟踪的 hardware-configuration.nix；ATTR 不要带 ".#"。
FLAKE_ATTR="nixos"

print_usage() {
  echo "Usage:"
  echo "  $0 install   # Fresh install from NixOS ISO"
  echo "  $0 apply     # Apply config on existing NixOS system"
}

cmd_apply() {
  echo "==> Applying NixOS configuration..."

  if [ -f "$CONFIG_DIR/flake.nix" ]; then
    if [ ! -f "$CONFIG_DIR/hosts/nixos/hardware-configuration.nix" ]; then
      echo "Error: missing local hosts/nixos/hardware-configuration.nix" >&2
      echo "Generate it with: sudo nixos-generate-config --show-hardware-config" >&2
      exit 1
    fi
    sudo nixos-rebuild switch --flake "path:$CONFIG_DIR#$FLAKE_ATTR"
  else
    echo "Error: flake.nix not found at $CONFIG_DIR"
    echo "Clone the repo first or set CONFIG_DIR correctly."
    exit 1
  fi

  echo "==> Done. Reboot recommended if kernel or bootloader changed."
}

cmd_install() {
  echo "==> NixOS Fresh Install"
  echo ""
  echo "This assumes you are booted from the NixOS installer ISO."
  echo ""
  read -p "Have you partitioned and mounted your disks to /mnt? [y/N] " -r
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please partition and mount first, then re-run."
    exit 1
  fi

  # Generate hardware config for target machine (local only — never commit).
  nixos-generate-config --root /mnt

  TARGET_DIR="${CONFIG_DIR/#\/home\/zi/\/mnt\/home\/zi}"
  echo "==> Cloning config to $TARGET_DIR ..."
  mkdir -p "$(dirname "$TARGET_DIR")"
  git clone "$REPO_URL" "$TARGET_DIR"

  HW_GENERATED="/mnt/etc/nixos/hardware-configuration.nix"
  HW_TARGET="$TARGET_DIR/hosts/nixos/hardware-configuration.nix"
  cp "$HW_GENERATED" "$HW_TARGET"

  echo "==> Wrote local hardware-configuration.nix (gitignored; not committed)."

  # path: so the untracked hardware file is part of the flake tree.
  nixos-install --flake "path:$TARGET_DIR#$FLAKE_ATTR"

  echo "==> Installation complete! Reboot and enjoy."
  echo "    After reboot, the config will be at ${TARGET_DIR#/mnt}."
}

case "${1:-help}" in
  install) cmd_install ;;
  apply)   cmd_apply ;;
  *)       print_usage ;;
esac
