#!/usr/bin/env bash
# ============================================================
#  mod_sublist3r.sh — Découverte via sublist3r
#  Usage : bash mod_sublist3r.sh <domaine> <output_file>
# ============================================================

source "$(dirname "$0")/lib.sh"

URL="${1:?Usage: $0 <domaine> <output_file>}"
OUT="${2:?Usage: $0 <domaine> <output_file>}"

if check_tool sublist3r; then
  log_step "sublist3r..."
  TMP=$(mktemp)
  sublist3r -d "${URL}" -o "${TMP}" -q 2>/dev/null
  COUNT=$(cat "${TMP}" | anew "${OUT}" | wc -l)
  rm -f "${TMP}"
  log_info "sublist3r : ${COUNT} nouveaux sous-domaines → ${OUT}"
fi
