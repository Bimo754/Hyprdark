#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - SDDM Theme Deployment Script
# Installs Hyprdark login theme to /usr/share/sddm/themes/ and activates it.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_SRC="${SCRIPT_DIR}/hyprdark"
THEME_DEST="/usr/share/sddm/themes/hyprdark"
CONF_DEST="/etc/sddm.conf.d/hyprdark.conf"

if [ "$(id -u)" -ne 0 ]; then
    echo "[ERR] This script requires root permissions. Run with: sudo ./install-sddm-theme.sh"
    exit 1
fi

echo "[INFO] Copying SDDM theme to ${THEME_DEST}..."
mkdir -p "${THEME_DEST}"
cp -a "${THEME_SRC}"/* "${THEME_DEST}/"

echo "[INFO] Activating theme in ${CONF_DEST}..."
mkdir -p "$(dirname "${CONF_DEST}")"
cat << CONF > "${CONF_DEST}"
[Theme]
Current=hyprdark

[General]
InputMethod=
CONF

echo "[OK] Hyprdark SDDM theme installed and activated."
