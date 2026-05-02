#!/usr/bin/env bash
# ============================================================
#  ip2lan-subdomfinder.sh — Orchestrateur principal
#
#  Structure :
#    ip2lan-subdomfinder.sh        ← ce fichier
#    modules/
#      lib.sh                      ← fonctions communes + check_all_tools
#      mod_assetfinder.sh          ← collecte passive
#      mod_amass.sh                ← collecte passive
#      mod_sublist3r.sh            ← collecte passive
#      mod_dnsrecon.sh             ← collecte passive + axfr
#      mod_crtsh.sh                ← certificate transparency
#      mod_ffuf.sh                 ← brute force DNS
#      mod_3rdlevel.sh             ← domaines 3ème niveau + sublist3r récursif
#      mod_dnsx.sh                 ← résolution DNS
#      mod_httprobe.sh             ← vérification HTTP/HTTPS
#      mod_subjack.sh              ← détection subdomain takeover
#      mod_whatweb.sh              ← fingerprinting technologies
#      mod_wayback.sh              ← waybackurls + params + extensions
#      mod_nmap.sh                 ← scan de ports
#      mod_gowitness.sh           ← screenshots (gowitness)
#      mod_report.sh               ← rapport final consolidé
#
#  Usage : ./ip2lan-subdomfinder.sh <domaine> [wordlist]
#  Ex    : ./ip2lan-subdomfinder.sh tesla.com
#          ./ip2lan-subdomfinder.sh tesla.com /path/to/wordlist.txt
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/modules/lib.sh"

# ─── Vérification argument ───────────────────────────────────
if [ -z "$1" ]; then
  echo -e "${RED}Usage : ./ip2lan-subdomfinder.sh <domaine> [wordlist]${NC}"
  echo "  Ex  : ./ip2lan-subdomfinder.sh tesla.com"
  exit 1
fi

URL="$1"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
WORDLIST="${2:-/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt}"

BASE_DIR="output/${URL}"
RECON_DIR="${BASE_DIR}/recon"
FINAL="${RECON_DIR}/final.txt"
RESOLVED="${RECON_DIR}/resolved.txt"
LIVE="${RECON_DIR}/httprobe/alive.txt"
REPORT="${BASE_DIR}/report_${TIMESTAMP}.txt"

banner

# ─── Création arborescence complète ─────────────────────────
mkdir -p \
  "${RECON_DIR}/3rd-lvls" \
  "${RECON_DIR}/scans" \
  "${RECON_DIR}/httprobe" \
  "${RECON_DIR}/potential_takeovers" \
  "${RECON_DIR}/wayback/params" \
  "${RECON_DIR}/wayback/extensions" \
  "${RECON_DIR}/whatweb" \
  "${RECON_DIR}/gowitness"

touch "${LIVE}" "${FINAL}"

log_info "Cible     : ${BOLD}${URL}${NC}"
log_info "Output    : ${BASE_DIR}"
log_info "Wordlist  : ${WORDLIST}"
echo ""
check_all_tools

# ═══════════════════════════════════════════════════════════════
# ÉTAPE 1 — COLLECTE PASSIVE
# ═══════════════════════════════════════════════════════════════
echo -e "${BOLD}━━━ ÉTAPE 1 : Collecte passive ━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

bash "${SCRIPT_DIR}/modules/mod_assetfinder.sh" "${URL}" "${FINAL}"
bash "${SCRIPT_DIR}/modules/mod_amass.sh"       "${URL}" "${FINAL}"
bash "${SCRIPT_DIR}/modules/mod_sublist3r.sh"   "${URL}" "${FINAL}"
bash "${SCRIPT_DIR}/modules/mod_dnsrecon.sh"    "${URL}" "${FINAL}"
bash "${SCRIPT_DIR}/modules/mod_crtsh.sh"       "${URL}" "${FINAL}"

echo ""
log_info "Collecte passive : $(wc -l < "${FINAL}") sous-domaines bruts"
echo ""

# ═══════════════════════════════════════════════════════════════
# ÉTAPE 2 — DOMAINES 3ÈME NIVEAU
# ═══════════════════════════════════════════════════════════════
echo -e "${BOLD}━━━ ÉTAPE 2 : Domaines 3ème niveau ━━━━━━━━━━━━━━━━━━━━━━${NC}"

bash "${SCRIPT_DIR}/modules/mod_3rdlevel.sh" "${URL}" "${FINAL}" "${RECON_DIR}"

echo ""

# ═══════════════════════════════════════════════════════════════
# ÉTAPE 3 — BRUTE FORCE DNS
# ═══════════════════════════════════════════════════════════════
echo -e "${BOLD}━━━ ÉTAPE 3 : Brute force DNS ━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

bash "${SCRIPT_DIR}/modules/mod_ffuf.sh" "${URL}" "${FINAL}" "${WORDLIST}"

echo ""

# ═══════════════════════════════════════════════════════════════
# ÉTAPE 4 — RÉSOLUTION DNS
# ═══════════════════════════════════════════════════════════════
echo -e "${BOLD}━━━ ÉTAPE 4 : Résolution DNS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

bash "${SCRIPT_DIR}/modules/mod_dnsx.sh" "${FINAL}" "${RESOLVED}"

echo ""

# ═══════════════════════════════════════════════════════════════
# ÉTAPE 5 — VÉRIFICATION HTTP/HTTPS (httprobe)
# ═══════════════════════════════════════════════════════════════
echo -e "${BOLD}━━━ ÉTAPE 5 : URLs actives (httprobe) ━━━━━━━━━━━━━━━━━━━${NC}"

INPUT_PROBE="${RESOLVED}"
[ ! -s "${RESOLVED}" ] && INPUT_PROBE="${FINAL}"

bash "${SCRIPT_DIR}/modules/mod_httprobe.sh" "${INPUT_PROBE}" "${LIVE}"

echo ""

# ═══════════════════════════════════════════════════════════════
# ÉTAPE 6 — SUBDOMAIN TAKEOVER (subjack)
# ═══════════════════════════════════════════════════════════════
echo -e "${BOLD}━━━ ÉTAPE 6 : Subdomain takeover ━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

bash "${SCRIPT_DIR}/modules/mod_subjack.sh" "${LIVE}" "${RECON_DIR}"

echo ""

# ═══════════════════════════════════════════════════════════════
# ÉTAPE 7 — FINGERPRINTING (whatweb)
# ═══════════════════════════════════════════════════════════════
echo -e "${BOLD}━━━ ÉTAPE 7 : Fingerprinting technologies (whatweb) ━━━━━━${NC}"

bash "${SCRIPT_DIR}/modules/mod_whatweb.sh" "${LIVE}" "${RECON_DIR}"

echo ""

# ═══════════════════════════════════════════════════════════════
# ÉTAPE 8 — WAYBACK MACHINE
# ═══════════════════════════════════════════════════════════════
echo -e "${BOLD}━━━ ÉTAPE 8 : Wayback Machine ━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

bash "${SCRIPT_DIR}/modules/mod_wayback.sh" "${FINAL}" "${RECON_DIR}"

echo ""

# ═══════════════════════════════════════════════════════════════
# ÉTAPE 9 — SCAN DE PORTS (nmap)
# ═══════════════════════════════════════════════════════════════
echo -e "${BOLD}━━━ ÉTAPE 9 : Scan de ports (nmap) ━━━━━━━━━━━━━━━━━━━━━━${NC}"

bash "${SCRIPT_DIR}/modules/mod_nmap.sh" "${LIVE}" "${RECON_DIR}"

echo ""

# ═══════════════════════════════════════════════════════════════
# ÉTAPE 10 — SCREENSHOTS (gowitness)
# ═══════════════════════════════════════════════════════════════
echo -e "${BOLD}━━━ ÉTAPE 10 : Screenshots (gowitness) ━━━━━━━━━━━━━━━━━━${NC}"

bash "${SCRIPT_DIR}/modules/mod_gowitness.sh" "${LIVE}" "${RECON_DIR}"

echo ""

# ═══════════════════════════════════════════════════════════════
# ÉTAPE 11 — RAPPORT FINAL CONSOLIDÉ
# ═══════════════════════════════════════════════════════════════
echo -e "${BOLD}━━━ ÉTAPE 11 : Rapport consolidé ━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

bash "${SCRIPT_DIR}/modules/mod_report.sh" "${URL}" "${RECON_DIR}" "${REPORT}"

echo ""
echo -e "${GREEN}${BOLD}✔  Recon terminée !${NC}"
echo -e "   Rapport    : ${BOLD}${REPORT}${NC}"
echo -e "   Live URLs   : ${BOLD}${LIVE}${NC}"
echo -e "   Wayback     : ${BOLD}${RECON_DIR}/wayback/${NC}"
echo -e "   Whatweb     : ${BOLD}${RECON_DIR}/whatweb/${NC}"
echo -e "   gowitness   : ${BOLD}${RECON_DIR}/gowitness/${NC}"
echo -e "   Nmap        : ${BOLD}${RECON_DIR}/scans/${NC}"
echo ""
