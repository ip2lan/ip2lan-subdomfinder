#!/usr/bin/env bash
# ============================================================
#  mod_crtsh.sh — Certificate Transparency via crt.sh
#  Usage : bash mod_crtsh.sh <domaine> <output_file>
# ============================================================

source "$(dirname "$0")/lib.sh"

URL="${1:?Usage: $0 <domaine> <output_file>}"
OUT="${2:?Usage: $0 <domaine> <output_file>}"

log_step "Certificate Transparency (crt.sh)..."
COUNT=$(curl -s "https://crt.sh/?q=%.${URL}&output=json" 2>/dev/null \
  | grep -o '"name_value":"[^"]*"' \
  | cut -d'"' -f4 \
  | sed 's/\*\.//g' \
  | grep "\.${URL}$" \
  | sort -u \
  | anew "${OUT}" \
  | wc -l)
log_info "crt.sh : ${COUNT} nouveaux sous-domaines → ${OUT}"
