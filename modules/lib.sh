#!/usr/bin/env bash
# ============================================================
#  lib.sh — Fonctions communes (couleurs, logs, check_tool)
#  Sourcé par tous les modules et le script principal
# ============================================================

export PATH="$PATH:/usr/local/bin:/usr/bin:/root/go/bin:/home/$USER/go/bin"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log_step() { echo -e "${GREEN}[+]${NC} $1"; }
log_info() { echo -e "${CYAN}[*]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_err()  { echo -e "${RED}[-]${NC} $1"; }

check_tool() {
  if which "$1" &>/dev/null || \
     [ -x "/usr/bin/$1" ] || \
     [ -x "/usr/local/bin/$1" ] || \
     [ -x "/root/go/bin/$1" ]; then
    return 0
  fi
  log_warn "Outil manquant : $1 — étape ignorée."
  return 1
}

check_all_tools() {
  local tools=("assetfinder" "amass" "sublist3r" "dnsrecon" "ffuf" "dnsx" "httprobe" "subjack" "whatweb" "waybackurls" "nmap" "curl" "jq" "anew")
  echo -e "${BOLD}  Outils disponibles :${NC}"
  for tool in "${tools[@]}"; do
    if which "$tool" &>/dev/null || [ -x "/usr/bin/$tool" ] || [ -x "/usr/local/bin/$tool" ] || [ -x "/root/go/bin/$tool" ]; then
      echo -e "    ${GREEN}✔${NC}  ${tool}"
    else
      echo -e "    ${RED}✘${NC}  ${tool} ${YELLOW}(manquant — étape ignorée)${NC}"
    fi
  done
  if which gowitness &>/dev/null || [ -x "/root/go/bin/gowitness" ]; then
    echo -e "    ${GREEN}✔${NC}  gowitness"
  else
    echo -e "    ${RED}✘${NC}  gowitness ${YELLOW}(manquant — étape ignorée)${NC}"
  fi
  echo ""
}

banner() {
  echo -e "${CYAN}"
  echo "  ██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗"
  echo "  ██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║"
  echo "  ██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║"
  echo "  ██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║"
  echo "  ██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║"
  echo "  ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝"
  echo -e "${NC}"
  echo -e "  ${BOLD}Subdomain Recon Pipeline${NC} — par ip2lan-subdomfinder.sh"
  echo ""
}
