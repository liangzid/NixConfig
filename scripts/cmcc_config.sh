#!/bin/bash
set -euo pipefail
mkdir -p ~/.codex ~/cmcc
cat > ~/.codex/config.toml <<'EOF'
model = "azure/gpt-5.6-sol"
model_provider = "cmcc"
model_reasoning_effort = "medium"
personality = "pragmatic"
approvals_reviewer = "user"
[model_providers.cmcc]
name = "CMCC mCloud AI Hub"
base_url = "https://mcloud-aihub.cmi.chinamobile.com/v1"
env_key = "CMCC_API_KEY"
wire_api = "responses"
supports_websockets = false
EOF
echo "Done. Now copy cmcc-api-key.txt to ~/cmcc/ and run: source ~/.bashrc"
