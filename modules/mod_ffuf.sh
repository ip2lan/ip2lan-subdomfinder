#!/usr/bin/env bash
# ============================================================
#  mod_ffuf.sh — Brute force DNS via ffuf
#  Usage : bash mod_ffuf.sh <domaine> <output_file> [wordlist]
# ============================================================

source "$(dirname "$0")/lib.sh"

URL="${1:?Usage: $0 <domaine> <output_file> [wordlist]}"
OUT="${2:?Usage: $0 <domaine> <output_file> [wordlist]}"
WORDLIST="${3:-/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt}"

if ! check_tool ffuf; then
  exit 0
fi

if [ ! -f "${WORDLIST}" ]; then
  log_warn "Wordlist introuvable : ${WORDLIST}"
  log_warn "Passe-la en 3ème argument ou installe SecLists."
  exit 0
fi

log_step "ffuf (DNS brute force)..."
TMP=$(mktemp)
ffuf -w "${WORDLIST}" \
     -u "https://FUZZ.${URL}" \
     -mc 200,301,302,403 \
     -t 50 \
     -s \
     -o "${TMP}" \
     -of json 2>/dev/null

COUNT=$(cat "${TMP}" 2>/dev/null \
  | grep -o '"url":"[^"]*"' \
  | cut -d'"' -f4 \
  | sed 's|https\?://||' \
  | cut -d'/' -f1 \
  | anew "${OUT}" \
  | wc -l)
rm -f "${TMP}"
log_info "ffuf : ${COUNT} nouveaux sous-domaines → ${OUT}"
