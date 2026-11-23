#!/usr/bin/env bash
set -euo pipefail

# ======================================================================
# TEST-THRONE-ROUTE
#
# 1. Probe common CN / HK-direct / always-VPS hosts through TUN (no
#    HTTP_PROXY). Report connect success and whether Throne sent the
#    flow DIRECT or via the VPS, by reading throne.log outbound lines.
# 2. Calling chain:
#      test-throne-route.sh
#        -> curl_one -> classify_from_log -> print_table
# 3. 23 November 2026: first version for HK AI only vs CN bypass check.
#
# Author: Zi Liang <zi1415926.liang@connect.polyu.hk>
# Copyright © 2026, Zi Liang, all rights reserved.
# Created: 23 November 2026
# ======================================================================

LOG="${THRONE_LOG:-$HOME/.config/Throne/config/logs/throne.log}"

# name|url
TARGETS=(
  'Baidu|https://www.baidu.com'
  'QQ|https://www.qq.com'
  'WeChat|https://weixin.qq.com'
  'Bilibili|https://www.bilibili.com'
  'Taobao|https://www.taobao.com'
  'Weibo|https://weibo.com'
  'Zhihu|https://www.zhihu.com'
  'JD|https://www.jd.com'
  'Aliyun|https://www.aliyun.com'
  'astaple.com|https://astaple.com'
  'GitHub|https://github.com'
  'Google|https://www.google.com'
  'YouTube|https://www.youtube.com'
  'Wikipedia|https://www.wikipedia.org'
  'X/Twitter|https://x.com'
  'Discord|https://discord.com'
  'ChatGPT|https://chatgpt.com'
  'OpenAI API|https://api.openai.com'
  'Claude|https://claude.ai'
  'Anthropic API|https://api.anthropic.com'
  'Gemini|https://gemini.google.com'
  'Gemini API|https://generativelanguage.googleapis.com'
  'Gemini CLI|https://cloudcode-pa.googleapis.com'
  'AI Studio|https://aistudio.google.com'
)

unset_proxy_env() {
  unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY all_proxy no_proxy NO_PROXY
}

log_lines() {
  if [[ -f "$LOG" ]]; then
    wc -l < "$LOG" | tr -d ' '
  else
    echo 0
  fi
}

# Map sing-box outbound tag in the new log slice to 直连 / VPS / 未知.
classify_from_log() {
  local host="$1"
  local ip="$2"
  local start_line="$3"
  local slice hit

  if [[ ! -f "$LOG" ]]; then
    echo "未知(无日志)"
    return
  fi

  slice=$(tail -n +"$((start_line + 1))" "$LOG" || true)
  hit=$(printf '%s\n' "$slice" | grep -E "outbound/[^:]+: outbound (packet )?connection to" | grep -Ei "${host}|${ip}" | tail -n 1 || true)

  if [[ -z "$hit" ]]; then
    echo "未知"
    return
  fi
  if [[ "$hit" == *'outbound/direct:'* ]]; then
    echo "直连"
  elif [[ "$hit" == *'[proxy]'* ]] || [[ "$hit" == *'outbound/socks'* ]]; then
    echo "VPS"
  else
    echo "未知"
  fi
}

curl_one() {
  local url="$1"
  curl -4 -sS -o /dev/null -L --max-redirs 3 \
    --connect-timeout 6 --max-time 12 \
    -w '%{http_code} %{remote_ip}' \
    "$url" 2>/dev/null || echo '000'
}

print_row() {
  printf '| %-16s | %-12s | %-8s |\n' "$1" "$2" "$3"
}

main() {
  unset_proxy_env

  if [[ ! -f "$LOG" ]]; then
    echo "Throne 日志不存在: $LOG" >&2
    echo "先打开 Throne、选好 Routing、开 TUN 再跑。" >&2
    exit 1
  fi
  if ! ip link show throne-tun >/dev/null 2>&1; then
    echo "没有 throne-tun：TUN 可能没开。" >&2
    exit 1
  fi

  echo "日志: $LOG"
  echo "期望（自己对照）："
  echo "  HK AI only : 国内 / GitHub / Google / YouTube = 直连；AI = VPS"
  echo "  CN bypass  : 国内 / astaple = 直连；GitHub / Google / YouTube / AI = VPS"
  echo

  print_row "名称" "连接" "路径"
  print_row "----------------" "------------" "--------"

  local entry name url host start out http_code remote_ip connect path
  for entry in "${TARGETS[@]}"; do
    name="${entry%%|*}"
    url="${entry#*|}"
    host="${url#https://}"
    host="${host#http://}"
    host="${host%%/*}"

    start=$(log_lines)
    out=$(curl_one "$url")
    sleep 0.35

    http_code="${out%% *}"
    remote_ip="${out#* }"
    if [[ "$http_code" == "000" || -z "$http_code" ]]; then
      connect="失败"
    else
      connect="成功 ${http_code}"
    fi
    path=$(classify_from_log "$host" "$remote_ip" "$start")
    print_row "$name" "$connect" "$path"
  done
}

main "$@"
