#!/usr/bin/env bash
# ============================================================
#  mod_assetfinder.sh — Découverte passive via assetfinder
#  Usage : source modules/lib.sh && bash mod_assetfinder.sh <domaine> <output_file>
# ============================================================

source "$(dirname "$0")/lib.sh"

URL="${1:?Usage: $0 <domaine> <output_file>}"
OUT="${2:?Usage: $0 <domaine> <output_file>}"

if check_tool assetfinder; then
  log_step "assetfinder..."
  COUNT=$(assetfinder --subs-only "${URL}" 2>/dev/null \
    | grep "\.${URL}$" \
    | anew "${OUT}" \
    | wc -l)
  log_info "assetfinder : ${COUNT} nouveaux sous-domaines → ${OUT}"
fi
