#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting global git config..."
git config --global user.name "liangzid"
git config --global user.email "2273067585@qq.com"
git config --global credential.helper store

echo "==> Configuring GitHub credential helper..."
git config --global credential.https://github.com.helper store

echo "==> Generating SSH key (ed25519)..."
KEYFILE="$HOME/.ssh/id_ed25519"
if [ -f "$KEYFILE" ]; then
  echo "SSH key already exists at $KEYFILE, skipping generation."
else
  ssh-keygen -t ed25519 -N "" -f "$KEYFILE"
  echo "SSH key generated."
fi

echo "==> Copying SSH key to remote hosts..."
for host in is1 gs14 gs14o; do
  echo "==> Copying to $host..."
  ssh-copy-id -i "$KEYFILE.pub" "$host"
done

echo "==> Done."
