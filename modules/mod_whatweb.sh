#!/usr/bin/env bash
# ============================================================
#  mod_whatweb.sh — Fingerprinting technologies via whatweb
#  Usage : bash mod_whatweb.sh <alive.txt> <recon_dir>
# ============================================================

source "$(dirname "$0")/lib.sh"

ALIVE="${1:?Usage: $0 <alive.txt> <recon_dir>}"
RECON_DIR="${2:?Usage: $0 <alive.txt> <recon_dir>}"

DIR_WHATWEB="${RECON_DIR}/whatweb"
mkdir -p "${DIR_WHATWEB}"

if ! check_tool whatweb; then
  exit 0
fi

log_step "whatweb — fingerprinting des domaines actifs..."
TOTAL=$(wc -l < "${ALIVE}")
COUNT=0

while IFS= read -r domain; do
  COUNT=$((COUNT + 1))
  DOMAIN_DIR="${DIR_WHATWEB}/${domain}"
  mkdir -p "${DOMAIN_DIR}"
  touch "${DOMAIN_DIR}/output.txt" "${DOMAIN_DIR}/plugins.txt"

  log_info "[${COUNT}/${TOTAL}] whatweb sur ${domain}"

  # Plugins
  whatweb --info-plugins -t 50 -v "${domain}" \
    >> "${DOMAIN_DIR}/plugins.txt" 2>/dev/null
  sleep 2

  # Output complet
  whatweb -t 50 -v "${domain}" \
    >> "${DOMAIN_DIR}/output.txt" 2>/dev/null
  sleep 2
done < "${ALIVE}"

log_info "whatweb terminé → ${DIR_WHATWEB}/"
