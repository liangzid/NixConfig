#!/usr/bin/env bash
set -euo pipefail

# ======================================================================
# NIXOS-REBUILD-LOCAL
#
# 1. Flake 在 git 仓库内只看见「已跟踪/已暂存」文件；gitignore 的
#    hardware-configuration.nix 必须临时 git add -f，求值完再 unstage，
#    避免误 commit 把本机 UUID 推上云端。
# 2. 调用链：update/upgrade 别名 → 本脚本 → nixos-rebuild
# 3. 修改历史：
#      2026-08-20 创建：修正「仅 path: 即可」的错误假设。
#
#     Author: Zi Liang <zi1415926.liang@connect.polyu.hk>
#     Copyright © 2026, Zi Liang, all rights reserved.
#     Created: 20 August 2026
# ======================================================================

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HW_FILE="$REPO_DIR/hosts/nixos/hardware-configuration.nix"
FLAKE_ATTR="${FLAKE_ATTR:-nixos}"

if [[ ! -f "$HW_FILE" ]]; then
  echo "错误: 缺少本机 $HW_FILE" >&2
  echo "请先生成: sudo nixos-generate-config --show-hardware-config" >&2
  echo "或: sudo nixos-generate-config --root / && cp /etc/nixos/hardware-configuration.nix $HW_FILE" >&2
  exit 1
fi

# 临时纳入 index，供 flake 看见；结束后撤掉暂存，文件仍留在磁盘且保持 ignore。
git -C "$REPO_DIR" add -f "$HW_FILE"
cleanup() {
  git -C "$REPO_DIR" restore --staged "$HW_FILE" 2>/dev/null || true
}
trap cleanup EXIT

if [[ $# -eq 0 ]]; then
  set -- switch
fi

sudo nixos-rebuild "$@" --flake "$REPO_DIR#$FLAKE_ATTR"
