#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/liangzid/nix-config.git"
CONFIG_DIR="/home/zi/code/NixConfig"
FLAKE_ATTR="nixos"

print_usage() {
  echo "Usage:"
  echo "  $0 install   # Fresh install from NixOS ISO"
  echo "  $0 apply     # Apply config on existing NixOS system"
}

cmd_apply() {
  echo "==> Applying NixOS configuration..."
  if [ ! -f "$CONFIG_DIR/flake.nix" ]; then
    echo "Error: flake.nix not found at $CONFIG_DIR"
    exit 1
  fi
  "$CONFIG_DIR/scripts/nixos-rebuild-local.sh" switch
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

  nixos-generate-config --root /mnt

  TARGET_DIR="${CONFIG_DIR/#\/home\/zi/\/mnt\/home\/zi}"
  echo "==> Cloning config to $TARGET_DIR ..."
  mkdir -p "$(dirname "$TARGET_DIR")"
  git clone "$REPO_URL" "$TARGET_DIR"

  HW_GENERATED="/mnt/etc/nixos/hardware-configuration.nix"
  HW_TARGET="$TARGET_DIR/hosts/nixos/hardware-configuration.nix"
  cp "$HW_GENERATED" "$HW_TARGET"
  echo "==> Wrote local hardware-configuration.nix (gitignored; not committed)."

  # Installer tree may not have scripts yet until clone finishes — use same force-add trick.
  git -C "$TARGET_DIR" add -f "$HW_TARGET"
  nixos-install --flake "$TARGET_DIR#$FLAKE_ATTR"
  git -C "$TARGET_DIR" restore --staged "$HW_TARGET" 2>/dev/null || true

  echo "==> Installation complete! Reboot and enjoy."
  echo "    After reboot, the config will be at ${TARGET_DIR#/mnt}."
}

case "${1:-help}" in
  install) cmd_install ;;
  apply)   cmd_apply ;;
  *)       print_usage ;;
esac
