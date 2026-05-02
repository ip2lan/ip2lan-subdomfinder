#!/usr/bin/env bash
# ============================================================
#  mod_dnsrecon.sh — Énumération DNS + tentative zone transfer
#  Usage : bash mod_dnsrecon.sh <domaine> <output_file>
# ============================================================

source "$(dirname "$0")/lib.sh"

URL="${1:?Usage: $0 <domaine> <output_file>}"
OUT="${2:?Usage: $0 <domaine> <output_file>}"

if check_tool dnsrecon; then
  log_step "dnsrecon (std + axfr)..."
  COUNT=$(dnsrecon -d "${URL}" -t std,axfr 2>/dev/null \
    | grep -oP '(?<=\s)[a-zA-Z0-9._-]+\.'"${URL}" \
    | anew "${OUT}" \
    | wc -l)
  log_info "dnsrecon : ${COUNT} nouveaux sous-domaines → ${OUT}"
fi
