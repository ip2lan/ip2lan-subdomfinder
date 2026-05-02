#!/usr/bin/env bash
# ============================================================
#  mod_dnsx.sh — Résolution DNS des sous-domaines collectés
#  Usage : bash mod_dnsx.sh <input_file> <output_file>
# ============================================================

source "$(dirname "$0")/lib.sh"

INPUT="${1:?Usage: $0 <input_file> <output_file>}"
OUT="${2:?Usage: $0 <input_file> <output_file>}"
DNSX_FULL="$(dirname "${OUT}")/dnsx_full.txt"

TOTAL=$(wc -l < "${INPUT}" 2>/dev/null || echo 0)
log_info "Total brut (avant résolution) : ${TOTAL} entrées"

if check_tool dnsx; then
  log_step "dnsx — résolution A + CNAME..."
  COUNT=$(cat "${INPUT}" \
    | dnsx -silent -a -cname -resp 2>/dev/null \
    | tee "${DNSX_FULL}" \
    | awk '{print $1}' \
    | anew "${OUT}" \
    | wc -l)
  log_info "dnsx : ${COUNT} sous-domaines résolus → ${OUT}"
elif check_tool host; then
  log_step "résolution basique avec 'host' (fallback)..."
  while IFS= read -r sub; do
    host "${sub}" 2>/dev/null | grep -q "has address" && echo "${sub}" | anew "${OUT}"
  done < "${INPUT}"
  log_info "Résolus : $(wc -l < "${OUT}") sous-domaines → ${OUT}"
else
  log_warn "Aucun outil de résolution disponible (dnsx / host)."
fi
