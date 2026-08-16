# sops-nix 密钥名清单（只有 key 名，不含值）。
# 值在 secrets/hosts/<hostname>.yaml（per-host 密文，进 git，age 加密），
# 由 scripts/set-secret.sh 维护。
# 加新密钥：直接跑 scripts/set-secret.sh NAME VALUE，或在此追加一行 "NAME"。
[
  "DEEPSEEK_API_KEY"
]
