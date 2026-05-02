#!/usr/bin/env bash
# ============================================================
#  mod_gowitness.sh — Screenshots automatiques via gowitness
#  Usage : bash mod_gowitness.sh <alive.txt> <recon_dir>
# ============================================================

source "$(dirname "$0")/lib.sh"

ALIVE="${1:?Usage: $0 <alive.txt> <recon_dir>}"
RECON_DIR="${2:?Usage: $0 <alive.txt> <recon_dir>}"

DIR_SCREENS="${RECON_DIR}/gowitness"
mkdir -p "${DIR_SCREENS}"

if ! check_tool gowitness; then
  log_warn "gowitness introuvable — étape ignorée."
  log_warn "Installe-le : go install github.com/sensepost/gowitness@latest"
  exit 0
fi

log_step "gowitness — capture d'écran des domaines actifs..."
gowitness file \
  -f "${ALIVE}" \
  --screenshot-path "${DIR_SCREENS}" \
  --timeout 10 \
  --threads 4 \
  2>/dev/null

COUNT=$(find "${DIR_SCREENS}" -name "*.png" 2>/dev/null | wc -l)
log_info "gowitness : ${COUNT} screenshots → ${DIR_SCREENS}/"
