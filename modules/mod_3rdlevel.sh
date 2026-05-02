#!/usr/bin/env bash
# ============================================================
#  mod_3rdlevel.sh — Extraction et énumération des domaines 3ème niveau
#  Usage : bash mod_3rdlevel.sh <domaine> <final.txt> <recon_dir>
# ============================================================

source "$(dirname "$0")/lib.sh"

URL="${1:?Usage: $0 <domaine> <final.txt> <recon_dir>}"
FINAL="${2:?Usage: $0 <domaine> <final.txt> <recon_dir>}"
RECON_DIR="${3:?Usage: $0 <domaine> <final.txt> <recon_dir>}"

DIR_3RD="${RECON_DIR}/3rd-lvls"
FILE_3RD="${RECON_DIR}/3rd-lvl-domains.txt"
mkdir -p "${DIR_3RD}"
touch "${FILE_3RD}"

log_step "Extraction des domaines 3ème niveau..."
grep -Po '(\w+\.\w+\.\w+)$' "${FINAL}" | sort -u >> "${FILE_3RD}"
COUNT_3RD=$(wc -l < "${FILE_3RD}")
log_info "3rd-level : ${COUNT_3RD} domaines trouvés → ${FILE_3RD}"

# Injecter les 3rd-level dans final.txt (déduplication via anew)
while IFS= read -r line; do
  echo "${line}" | anew "${FINAL}"
done < "${FILE_3RD}"

# Sublist3r sur chaque domaine 3ème niveau
if check_tool sublist3r && [ "${COUNT_3RD}" -gt 0 ]; then
  log_step "sublist3r sur chaque domaine 3ème niveau..."
  while IFS= read -r domain; do
    OUT_FILE="${DIR_3RD}/${domain}.txt"
    log_info "  → sublist3r sur ${domain}"
    sublist3r -d "${domain}" -o "${OUT_FILE}" -q 2>/dev/null
    [ -f "${OUT_FILE}" ] && cat "${OUT_FILE}" | anew "${FINAL}"
  done < "${FILE_3RD}"
fi
