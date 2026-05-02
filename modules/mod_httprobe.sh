#!/usr/bin/env bash
# ============================================================
#  mod_httprobe.sh — Vérification des URLs actives (HTTP/HTTPS)
#  Usage : bash mod_httprobe.sh <input_file> <output_file>
# ============================================================

source "$(dirname "$0")/lib.sh"

INPUT="${1:?Usage: $0 <input_file> <output_file>}"
OUT="${2:?Usage: $0 <input_file> <output_file>}"

# fallback sur final.txt si resolved.txt vide
[ ! -s "${INPUT}" ] && log_warn "Fichier d'entrée vide, vérifiez l'étape précédente." && exit 0

if check_tool httprobe; then
  log_step "httprobe — test HTTP/HTTPS (80, 443, 8080, 8443)..."
  COUNT=$(cat "${INPUT}" \
    | sort -u \
    | httprobe -s -p https:443 -p http:80 -p https:8443 -p http:8080 2>/dev/null \
    | sed 's/https\?:\/\///' \
    | tr -d ':443' \
    | sort -u \
    | tee "${OUT}" \
    | wc -l)
  log_info "httprobe : ${COUNT} URLs actives → ${OUT}"
fi
