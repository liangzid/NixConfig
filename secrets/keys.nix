# sops-nix 密钥名清单（只有 key 名，不含值）。
# 值在本地 secrets/secrets.yaml（已 gitignore），由 scripts/set-secret.sh 维护。
# 加新密钥：直接跑 scripts/set-secret.sh NAME VALUE，或在此追加一行 "NAME"。
[
  "DEEPSEEK_API_KEY"
]
