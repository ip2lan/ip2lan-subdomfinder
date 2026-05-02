# ip2lan-subdomfinder
la reconnaissance de sous-domaines 

<div align="center">

```
  ██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗
  ██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║
  ██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║
  ██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║
  ██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║
  ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝
```

**Pipeline complet de reconnaissance de sous-domaines**

![Bash](https://img.shields.io/badge/bash-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Kali Linux](https://img.shields.io/badge/Kali_Linux-557C94?style=for-the-badge&logo=kali-linux&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)
![Version](https://img.shields.io/badge/version-1.0-blue?style=for-the-badge)

</div>

---

## Description

**ip2lan-subdomfinder** est un pipeline bash modulaire qui automatise l'intégralité de la chaîne de reconnaissance de sous-domaines. Il orchestre les meilleurs outils open-source en 11 étapes, de la collecte passive jusqu'aux screenshots des interfaces web découvertes.

Conçu pour les pentesters, bug hunters et professionnels de la cybersécurité qui veulent une surface d'attaque complète sans configuration complexe.

---

## Pipeline en 11 étapes

| # | Étape | Outils |
|---|-------|--------|
| 01 | Collecte passive | `assetfinder` `amass` `sublist3r` `dnsrecon` `crt.sh` |
| 02 | Domaines 3ème niveau | `sublist3r` (récursif) |
| 03 | Brute force DNS | `ffuf` + SecLists |
| 04 | Résolution DNS | `dnsx` |
| 05 | Vérification HTTP/HTTPS | `httprobe` (80, 443, 8080, 8443) |
| 06 | Subdomain Takeover | `subjack` |
| 07 | Fingerprinting | `whatweb` |
| 08 | Wayback Machine | `waybackurls` + extraction params/extensions |
| 09 | Scan de ports | `nmap` |
| 10 | Screenshots | `gowitness` |
| 11 | Rapport consolidé | rapport texte horodaté |

---

## Structure

```
ip2lan-subdomfinder/
├── ip2lan-subdomfinder.sh     ← orchestrateur principal
└── modules/
    ├── lib.sh                 ← fonctions communes (logs, check_tool, banner)
    ├── mod_assetfinder.sh
    ├── mod_amass.sh
    ├── mod_sublist3r.sh
    ├── mod_dnsrecon.sh
    ├── mod_crtsh.sh
    ├── mod_ffuf.sh
    ├── mod_3rdlevel.sh
    ├── mod_dnsx.sh
    ├── mod_httprobe.sh
    ├── mod_subjack.sh
    ├── mod_whatweb.sh
    ├── mod_wayback.sh
    ├── mod_nmap.sh
    ├── mod_gowitness.sh
    └── mod_report.sh
```

---

## Installation

### 1. Cloner le dépôt

```bash
git clone https://github.com/ip2lan/ip2lan-subdomfinder.git
cd ip2lan-subdomfinder
chmod +x ip2lan-subdomfinder.sh modules/*.sh
```

### 2. Outils système

```bash
sudo apt update && sudo apt install -y \
  amass sublist3r dnsrecon ffuf nmap whatweb curl jq
```

### 3. Outils Go

```bash
go install github.com/tomnomnom/assetfinder@latest
go install github.com/tomnomnom/httprobe@latest
go install github.com/tomnomnom/anew@latest
go install github.com/tomnomnom/waybackurls@latest
go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install github.com/haccer/subjack@latest
go install github.com/sensepost/gowitness@latest
```

### 4. SecLists (wordlists)

```bash
sudo apt install seclists
# ou
git clone --depth 1 https://github.com/danielmiessler/SecLists.git /usr/share/seclists
```

### 5. PATH Go

```bash
echo 'export PATH="$PATH:$HOME/go/bin"' >> ~/.bashrc && source ~/.bashrc
```

> Le script vérifie automatiquement la présence de chaque outil au démarrage. Les étapes dont les outils sont manquants sont ignorées sans erreur.

---

## Utilisation

### Lancement basique

```bash
./ip2lan-subdomfinder.sh <domaine>
```

```bash
# Exemple
./ip2lan-subdomfinder.sh tototata.com

# Avec une wordlist custom
./ip2lan-subdomfinder.sh tototata.com /usr/share/seclists/Discovery/DNS/subdomains-top1million-20000.txt
```

### Lancer un module seul

Chaque module est indépendant et peut être relancé sans reprendre tout le pipeline :

```bash
# Relancer uniquement httprobe
bash modules/mod_httprobe.sh output/tototata.com/recon/resolved.txt \
  output/tototata.com/recon/httprobe/alive.txt

# Relancer uniquement les screenshots
bash modules/mod_gowitness.sh output/tototata.com/recon/httprobe/alive.txt \
  output/tototata.com/recon

# Relancer la détection de takeover
bash modules/mod_subjack.sh output/tototata.com/recon/httprobe/alive.txt \
  output/tototata.com/recon
```

---

## Résultats

```
output/tototata.com/
├── report_20250501_143022.txt        ← rapport consolidé horodaté
└── recon/
    ├── final.txt                     ← tous les sous-domaines bruts
    ├── 3rd-lvl-domains.txt           ← domaines 3ème niveau
    ├── resolved.txt                  ← sous-domaines DNS résolus
    ├── 3rd-lvls/                     ← résultats sublist3r par domaine
    ├── httprobe/
    │   └── alive.txt                 ← URLs actives HTTP/HTTPS
    ├── potential_takeovers/
    │   └── potential_takeovers.txt
    ├── wayback/
    │   ├── wayback_output.txt        ← toutes les URLs historiques
    │   ├── params/
    │   │   ├── wayback_params.txt
    │   │   └── wayback_params_ready.txt
    │   └── extensions/
    │       ├── js.txt
    │       ├── php.txt
    │       ├── aspx.txt
    │       ├── json.txt
    │       └── html.txt
    ├── whatweb/
    │   └── <domaine>/
    │       ├── output.txt
    │       └── plugins.txt
    ├── scans/
    │   └── scanned.{nmap,gnmap,xml}
    └── gowitness/
        └── *.png
```

---

## Testé sur

| OS | Version |
|----|---------|
| Kali Linux | 2024.x |
| Debian | 12 |
| Ubuntu | 22.04 LTS |

---

## Avertissement légal

> ⚠️ **Usage éthique et légal uniquement.**
>
> Cet outil est destiné à des tests sur vos propres systèmes, des programmes de bug bounty avec scope défini, ou des missions de pentest avec autorisation écrite du client.
>
> Toute utilisation sur des systèmes sans autorisation explicite est illégale. **ip2lan.fr décline toute responsabilité en cas d'usage malveillant.**

---

## Licence

MIT — voir [LICENSE](LICENSE)

---

## Auteur

**ip2lan.fr** — Cybersécurité & Hacking Éthique

[![Website](https://img.shields.io/badge/ip2lan.fr-00BCD4?style=for-the-badge&logo=firefox&logoColor=white)](https://ip2lan.fr)
