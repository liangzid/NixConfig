#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/liangzid/nix-config.git"
CONFIG_DIR="/home/zi/code/NixConfig"
FLAKE_REF=".#nixos"

print_usage() {
  echo "Usage:"
  echo "  $0 install   # Fresh install from NixOS ISO"
  echo "  $0 apply     # Apply config on existing NixOS system"
  echo "  $0 iso       # Generate NixOS ISO from this config"
}

cmd_apply() {
  echo "==> Applying NixOS configuration..."

  if [ -f "$CONFIG_DIR/flake.nix" ]; then
    sudo nixos-rebuild switch --flake "$CONFIG_DIR#$FLAKE_REF"
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

  # Generate hardware config for target machine
  nixos-generate-config --root /mnt

  # Determine install target (default: clone to /mnt/home/USER/code/NixConfig)
  TARGET_DIR="${CONFIG_DIR/#\/home\/zi/\/mnt\/home\/zi}"
  echo "==> Cloning config to $TARGET_DIR ..."
  mkdir -p "$(dirname "$TARGET_DIR")"
  git clone "$REPO_URL" "$TARGET_DIR"

  # Replace the repo's hardware-config with the one we just generated
  HW_GENERATED="/mnt/etc/nixos/hardware-configuration.nix"
  HW_TARGET="$TARGET_DIR/hosts/nixos/hardware-configuration.nix"
  cp "$HW_TARGET" "${HW_TARGET}.bak" 2>/dev/null || true
  cp "$HW_GENERATED" "$HW_TARGET"

  # Also keep a copy at /mnt/etc/nixos for reference
  mkdir -p /mnt/etc/nixos
  cp "$HW_GENERATED" /mnt/etc/nixos/hardware-configuration.nix.bak 2>/dev/null || true

  # Git-track the new hardware config so the flake can see it
  git -C "$TARGET_DIR" add -A
  git -C "$TARGET_DIR" config user.email "installer@nixos"
  git -C "$TARGET_DIR" config user.name "NixOS Installer"
  git -C "$TARGET_DIR" commit -m "install: add hardware-config for this machine"

  # Install
  nixos-install --flake "$TARGET_DIR#$FLAKE_REF"

  echo "==> Installation complete! Reboot and enjoy."
  echo "    After reboot, the config will be at ${TARGET_DIR#/mnt}."
}

cmd_iso() {
  echo "==> Building NixOS ISO..."
  nix build "$FLAKE_REF".config.system.build.iso
  echo "ISO built at ./result"
}

case "${1:-help}" in
  install) cmd_install ;;
  apply)   cmd_apply ;;
  iso)     cmd_iso ;;
  *)       print_usage ;;
esac
