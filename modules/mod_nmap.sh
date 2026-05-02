#!/usr/bin/env bash
# ============================================================
#  mod_nmap.sh — Scan de ports sur les hôtes actifs
#  Usage : bash mod_nmap.sh <alive.txt> <recon_dir>
# ============================================================

source "$(dirname "$0")/lib.sh"

ALIVE="${1:?Usage: $0 <alive.txt> <recon_dir>}"
RECON_DIR="${2:?Usage: $0 <alive.txt> <recon_dir>}"

DIR_SCANS="${RECON_DIR}/scans"
mkdir -p "${DIR_SCANS}"

if ! check_tool nmap; then
  exit 0
fi

log_step "nmap — scan de ports (top ports, T4)..."
nmap -iL "${ALIVE}" \
     -T4 \
     --open \
     -sV \
     --top-ports 1000 \
     -oA "${DIR_SCANS}/scanned" \
     2>/dev/null

log_info "nmap terminé → ${DIR_SCANS}/scanned.{nmap,gnmap,xml}"
