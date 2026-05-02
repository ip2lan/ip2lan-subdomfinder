#!/usr/bin/env bash
# ============================================================
#  mod_wayback.sh — Scraping Wayback Machine + extraction params/extensions
#  Usage : bash mod_wayback.sh <final.txt> <recon_dir>
# ============================================================

source "$(dirname "$0")/lib.sh"

FINAL="${1:?Usage: $0 <final.txt> <recon_dir>}"
RECON_DIR="${2:?Usage: $0 <final.txt> <recon_dir>}"

DIR_WAYBACK="${RECON_DIR}/wayback"
DIR_PARAMS="${DIR_WAYBACK}/params"
DIR_EXT="${DIR_WAYBACK}/extensions"
mkdir -p "${DIR_PARAMS}" "${DIR_EXT}"

WAYBACK_OUT="${DIR_WAYBACK}/wayback_output.txt"

if ! check_tool waybackurls; then
  exit 0
fi

# ─── Collecte ───────────────────────────────────────────────
log_step "waybackurls — scraping des URLs historiques..."
cat "${FINAL}" | waybackurls 2>/dev/null | sort -u | tee "${WAYBACK_OUT}" \
  | wc -l | xargs -I{} log_info "wayback : {} URLs collectées"

[ ! -s "${WAYBACK_OUT}" ] && log_warn "Aucune URL wayback trouvée." && exit 0

# ─── Extraction des paramètres ──────────────────────────────
log_step "Extraction des paramètres GET..."
grep '?.*=' "${WAYBACK_OUT}" \
  | cut -d'=' -f1 \
  | sort -u \
  | tee "${DIR_PARAMS}/wayback_params.txt" \
  | wc -l | xargs -I{} log_info "params : {} paramètres uniques"

# Ajouter le signe = pour usage direct
awk '{print $0"="}' "${DIR_PARAMS}/wayback_params.txt" \
  > "${DIR_PARAMS}/wayback_params_ready.txt"

# ─── Tri par extension ──────────────────────────────────────
log_step "Tri des URLs par extension (js/php/aspx/jsp/json/html)..."
declare -A EXT_MAP=(
  [js]="js.txt"
  [php]="php.txt"
  [aspx]="aspx.txt"
  [jsp]="jsp.txt"
  [json]="json.txt"
  [html]="html.txt"
)

for ext in "${!EXT_MAP[@]}"; do
  grep "\.${ext}$\|\.${ext}?" "${WAYBACK_OUT}" \
    | sort -u > "${DIR_EXT}/${EXT_MAP[$ext]}"
  COUNT=$(wc -l < "${DIR_EXT}/${EXT_MAP[$ext]}")
  [ "${COUNT}" -gt 0 ] && log_info "  .${ext} : ${COUNT} fichiers"
done

log_info "wayback terminé → ${DIR_WAYBACK}/"
