#!/usr/bin/env bash
# ============================================================
#  mod_subjack.sh — Détection de subdomain takeover
#  Usage : bash mod_subjack.sh <alive.txt> <recon_dir>
# ============================================================

source "$(dirname "$0")/lib.sh"

ALIVE="${1:?Usage: $0 <alive.txt> <recon_dir>}"
RECON_DIR="${2:?Usage: $0 <alive.txt> <recon_dir>}"

DIR_TAKEOVER="${RECON_DIR}/potential_takeovers"
mkdir -p "${DIR_TAKEOVER}"

if ! check_tool subjack; then
  exit 0
fi

# Chercher le fichier fingerprints.json de subjack
FINGERPRINTS=""
for path in \
  ~/go/src/github.com/haccer/subjack/fingerprints.json \
  ~/go/pkg/mod/github.com/haccer/subjack*/fingerprints.json \
  /usr/share/subjack/fingerprints.json \
  $(go env GOPATH 2>/dev/null)/src/github.com/haccer/subjack/fingerprints.json; do
  if [ -f "${path}" ]; then
    FINGERPRINTS="${path}"
    break
  fi
done

log_step "subjack — détection subdomain takeover..."

if [ -n "${FINGERPRINTS}" ]; then
  subjack -w "${ALIVE}" \
          -t 100 \
          -timeout 30 \
          -ssl \
          -c "${FINGERPRINTS}" \
          -v 3 2>/dev/null \
  | tee "${DIR_TAKEOVER}/takeovers_raw.txt"
else
  log_warn "fingerprints.json introuvable, lancement sans -c..."
  subjack -w "${ALIVE}" -t 100 -timeout 30 -ssl -v 3 2>/dev/null \
  | tee "${DIR_TAKEOVER}/takeovers_raw.txt"
fi

sort -u "${DIR_TAKEOVER}/takeovers_raw.txt" > "${DIR_TAKEOVER}/potential_takeovers.txt"
rm -f "${DIR_TAKEOVER}/takeovers_raw.txt"

COUNT=$(wc -l < "${DIR_TAKEOVER}/potential_takeovers.txt")
log_info "subjack : ${COUNT} takeovers potentiels → ${DIR_TAKEOVER}/potential_takeovers.txt"
