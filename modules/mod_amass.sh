#!/usr/bin/env bash
# ============================================================
#  mod_amass.sh — Énumération passive via amass
#  Usage : bash mod_amass.sh <domaine> <output_file>
# ============================================================

source "$(dirname "$0")/lib.sh"

URL="${1:?Usage: $0 <domaine> <output_file>}"
OUT="${2:?Usage: $0 <domaine> <output_file>}"

if check_tool amass; then
  log_step "amass (mode passif)..."
  COUNT=$(amass enum -passive -d "${URL}" 2>/dev/null \
    | anew "${OUT}" \
    | wc -l)
  log_info "amass : ${COUNT} nouveaux sous-domaines → ${OUT}"
fi
