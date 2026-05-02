#!/usr/bin/env bash
# ============================================================
#  mod_report.sh — Génération du rapport final consolidé
#  Usage : bash mod_report.sh <domaine> <recon_dir> <report_file>
# ============================================================

source "$(dirname "$0")/lib.sh"

URL="${1:?Usage: $0 <domaine> <recon_dir> <report_file>}"
RECON_DIR="${2:?Usage: $0 <domaine> <recon_dir> <report_file>}"
REPORT="${3:?Usage: $0 <domaine> <recon_dir> <report_file>}"

FINAL="${RECON_DIR}/final.txt"
RESOLVED="${RECON_DIR}/resolved.txt"
LIVE="${RECON_DIR}/httprobe/alive.txt"
FILE_3RD="${RECON_DIR}/3rd-lvl-domains.txt"
TAKEOVERS="${RECON_DIR}/potential_takeovers/potential_takeovers.txt"
WAYBACK="${RECON_DIR}/wayback/wayback_output.txt"
PARAMS="${RECON_DIR}/wayback/params/wayback_params.txt"
NMAP="${RECON_DIR}/scans/scanned.nmap"

count() { wc -l < "$1" 2>/dev/null || echo 0; }

{
  echo "========================================================"
  echo "  RAPPORT RECON — ${URL}"
  echo "  Date : $(date)"
  echo "========================================================"
  echo ""
  echo "┌─────────────────────────────────────────────────────┐"
  echo "│  STATISTIQUES                                       │"
  echo "└─────────────────────────────────────────────────────┘"
  printf "  %-35s : %s\n" "Sous-domaines bruts (final.txt)"   "$(count "${FINAL}")"
  printf "  %-35s : %s\n" "Domaines 3ème niveau"              "$(count "${FILE_3RD}")"
  printf "  %-35s : %s\n" "Sous-domaines résolus (DNS)"       "$(count "${RESOLVED}")"
  printf "  %-35s : %s\n" "URLs actives (httprobe)"           "$(count "${LIVE}")"
  printf "  %-35s : %s\n" "Takeovers potentiels"              "$(count "${TAKEOVERS}")"
  printf "  %-35s : %s\n" "URLs wayback collectées"           "$(count "${WAYBACK}")"
  printf "  %-35s : %s\n" "Paramètres GET uniques"            "$(count "${PARAMS}")"
  echo ""
  echo "┌─────────────────────────────────────────────────────┐"
  echo "│  ARBORESCENCE DES FICHIERS                          │"
  echo "└─────────────────────────────────────────────────────┘"
  printf "  %-35s : %s\n" "Tous les sous-domaines"            "${FINAL}"
  printf "  %-35s : %s\n" "3ème niveau"                       "${FILE_3RD}"
  printf "  %-35s : %s\n" "Sous-domaines résolus"             "${RESOLVED}"
  printf "  %-35s : %s\n" "URLs actives"                      "${LIVE}"
  printf "  %-35s : %s\n" "Takeovers"                         "${TAKEOVERS}"
  printf "  %-35s : %s\n" "Wayback output"                    "${WAYBACK}"
  printf "  %-35s : %s\n" "Params GET"                        "${PARAMS}"
  printf "  %-35s : %s\n" "Whatweb"                           "${RECON_DIR}/whatweb/"
  printf "  %-35s : %s\n" "gowitness"                         "${RECON_DIR}/gowitness/"
  printf "  %-35s : %s\n" "Nmap"                              "${RECON_DIR}/scans/"
  echo ""

  if [ -s "${TAKEOVERS}" ]; then
    echo "┌─────────────────────────────────────────────────────┐"
    echo "│  ⚠  TAKEOVERS POTENTIELS                            │"
    echo "└─────────────────────────────────────────────────────┘"
    cat "${TAKEOVERS}"
    echo ""
  fi

  echo "┌─────────────────────────────────────────────────────┐"
  echo "│  URLS ACTIVES                                       │"
  echo "└─────────────────────────────────────────────────────┘"
  if [ -s "${LIVE}" ]; then
    cat "${LIVE}"
  else
    echo "  (aucune URL active trouvée)"
  fi
  echo ""

  echo "┌─────────────────────────────────────────────────────┐"
  echo "│  TOUS LES SOUS-DOMAINES                             │"
  echo "└─────────────────────────────────────────────────────┘"
  if [ -s "${FINAL}" ]; then
    cat "${FINAL}"
  else
    echo "  (aucun sous-domaine trouvé)"
  fi

} | tee "${REPORT}"

echo ""
log_info "Rapport sauvegardé : ${BOLD}${REPORT}${NC}"
