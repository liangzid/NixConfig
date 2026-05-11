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

  # Clone config
  mkdir -p /mnt/etc/nixos
  git clone "$REPO_URL" /mnt/etc/nixos

  # Replace the auto-generated hardware-config with the one we just generated
  cp /mnt/etc/nixos/hosts/nixos/hardware-configuration.nix /mnt/etc/nixos/hosts/nixos/hardware-configuration.nix.bak 2>/dev/null || true
  cp /mnt/nixos/hardware-configuration.nix /mnt/etc/nixos/hosts/nixos/hardware-configuration.nix

  # Install
  nixos-install --flake /mnt/etc/nixos#"$FLAKE_REF"

  echo "==> Installation complete! Reboot and enjoy."
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
