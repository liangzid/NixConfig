#!/usr/bin/env bash
set -euo pipefail

# ======================================================================
# SET-SECRET
#
# 1. 把 NAME=VALUE 加密写入 secrets/secrets.yaml（本地，不进 git），
#    并同步更新 secrets/keys.nix（密钥名清单，进 git）。
# 2. 调用链：
#      set-secret.sh
#        ├─ nix run nixpkgs#ssh-to-age  生成本机 age 公钥（首次）
#        ├─ nix run nixpkgs#sops -d     解密现有密文
#        ├─ python3                     更新/追加 NAME 行
#        └─ nix run nixpkgs#sops -e     重新加密写回
# 3. 修改历史：
#      2026-08-16 创建：替代手动 sops -d/-e 加解密流程。
#
#     Author: Zi Liang <zi1415926.liang@connect.polyu.hk>
#     Copyright © 2026, Zi Liang, all rights reserved.
#     Created: 16 August 2026
# ======================================================================

usage() {
  cat >&2 <<'EOF'
用法:
  set-secret.sh NAME VALUE       # 直接指定值（会出现在进程列表）
  set-secret.sh NAME             # 从 stdin 读值（避免泄露到进程列表）

把 NAME 加密写入 secrets/secrets.yaml（本地），并更新 secrets/keys.nix。
首次运行会自动生成本地 .sops.yaml（用本机 ~/.ssh/id_ed25519）。
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
  exit 0
fi

NAME="$1"
if [[ $# -ge 2 ]]; then
  VALUE="$2"
else
  IFS= read -r VALUE
fi

# 校验 NAME 是合法环境变量名
if [[ ! "$NAME" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
  echo "错误: NAME 必须是合法环境变量名（字母/数字/下划线，不能以数字开头）" >&2
  exit 1
fi
if [[ -z "$VALUE" ]]; then
  echo "错误: VALUE 为空" >&2
  exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SECRETS_FILE="$REPO_DIR/secrets/secrets.yaml"
KEYS_FILE="$REPO_DIR/secrets/keys.nix"
SOPS_CFG="$REPO_DIR/.sops.yaml"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_ed25519}"

# 1. 生成本地 .sops.yaml（若不存在）：复刻双公钥结构，
#    age 公钥给 sops-nix 激活时解密，ssh 公钥给 sops CLI 加解密。
if [[ ! -f "$SOPS_CFG" ]]; then
  [[ -f "$SSH_KEY.pub" ]] || { echo "错误: 找不到 $SSH_KEY.pub" >&2; exit 1; }
  age_pub="$(nix run nixpkgs#ssh-to-age -- -i "$SSH_KEY.pub")"
  ssh_pub="$(cut -d' ' -f1,2 "$SSH_KEY.pub")"
  cat > "$SOPS_CFG" <<EOF
keys:
- &zi $age_pub
- &zi_ssh $ssh_pub
creation_rules:
  - key_groups:
      - age:
          - *zi
          - *zi_ssh
EOF
  echo "==> 已生成本地 .sops.yaml（本机 ssh key）"
fi

# 2. 解密现有密文（若存在）。解密失败必须中止，避免静默覆盖丢失旧密钥。
plain=""
if [[ -f "$SECRETS_FILE" ]]; then
  if ! plain="$(nix run nixpkgs#sops -- -d --age "$SSH_KEY" "$SECRETS_FILE" 2>/dev/null)"; then
    echo "错误: 无法解密 $SECRETS_FILE（检查 $SSH_KEY 是否匹配）" >&2
    exit 1
  fi
fi

# 3. 更新/追加 NAME 行（值统一 YAML 双引号 + 转义）。
plain="$(printf '%s' "$plain" | python3 -c '
import sys
name = sys.argv[1]
value = sys.argv[2]

def yaml_dq(s):
    return "\"" + s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n") + "\""

new_line = name + ": " + yaml_dq(value)
data = sys.stdin.read()
lines = [ln for ln in data.split("\n") if ln.strip()]
out = []
found = False
for ln in lines:
    if ln.lstrip().startswith(name + ":"):
        out.append(new_line)
        found = True
    else:
        out.append(ln)
if not found:
    out.append(new_line)
sys.stdout.write("\n".join(out) + "\n")
' "$NAME" "$VALUE")"

# 4. 加密写回（临时文件用 .yaml 后缀 + 显式类型，避免 sops 输出成 JSON）。
tmp="$(mktemp --suffix=.yaml)"
printf '%s' "$plain" > "$tmp"
SOPS_CONFIG="$SOPS_CFG" nix run nixpkgs#sops -- -e --input-type yaml --output-type yaml "$tmp" > "$SECRETS_FILE"
rm -f "$tmp"

# 5. 同步 keys.nix（key 名清单，进 git）。
if [[ ! -f "$KEYS_FILE" ]]; then
  printf '[\n]\n' > "$KEYS_FILE"
fi
if ! grep -q "\"$NAME\"" "$KEYS_FILE"; then
  python3 -c '
import sys
name = sys.argv[1]
path = sys.argv[2]
content = open(path).read()
lines = content.rstrip("\n").split("\n")
for i in range(len(lines) - 1, -1, -1):
    if lines[i].strip() == "]":
        lines.insert(i, "  \"" + name + "\"")
        break
else:
    lines.append("  \"" + name + "\"")
open(path, "w").write("\n".join(lines) + "\n")
' "$NAME" "$KEYS_FILE"
fi

cat <<EOF

==> 已加密写入 $NAME → secrets/secrets.yaml，并同步 secrets/keys.nix
下一步：
  sudo nixos-rebuild switch --flake .#nixos
  systemctl --user restart sops-secrets-env.service
  # 新开 shell 验证: echo \$$NAME
EOF
