#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - GRUB Theme Deployment Script
# Deploys high-contrast dark theme and updates GRUB configuration safely.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DEST="/boot/grub/themes/hyprdark"

if [ "$(id -u)" -ne 0 ]; then
    echo "[ERR] This script requires root permissions. Run with: sudo ./install-grub-theme.sh"
    exit 1
fi

echo "[INFO] Creating GRUB theme destination: ${THEME_DEST}"
mkdir -p "${THEME_DEST}"
cp -a "${SCRIPT_DIR}/theme.txt" "${THEME_DEST}/"

# Generate simple 1x1 dark background if no image exists
if [ ! -f "${THEME_DEST}/background.png" ] && command -v convert >/dev/null 2>&1; then
    convert -size 1920x1080 xc:"#0d0e15" "${THEME_DEST}/background.png"
fi

# Backup /etc/default/grub
GRUB_DEFAULT="/etc/default/grub"
BACKUP="${GRUB_DEFAULT}.bak.$(date +%Y%m%d_%H%M%S)"
echo "[INFO] Backing up ${GRUB_DEFAULT} to ${BACKUP}"
cp -a "${GRUB_DEFAULT}" "${BACKUP}"

# Update GRUB_THEME in /etc/default/grub
if grep -q "^GRUB_THEME=" "${GRUB_DEFAULT}"; then
    sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"${THEME_DEST}/theme.txt\"|" "${GRUB_DEFAULT}"
elif grep -q "^#GRUB_THEME=" "${GRUB_DEFAULT}"; then
    sed -i "s|^#GRUB_THEME=.*|GRUB_THEME=\"${THEME_DEST}/theme.txt\"|" "${GRUB_DEFAULT}"
else
    echo "GRUB_THEME=\"${THEME_DEST}/theme.txt\"" >> "${GRUB_DEFAULT}"
fi

# Set GFXMODE to 1920x1080,auto
if grep -q "^GRUB_GFXMODE=" "${GRUB_DEFAULT}"; then
    sed -i 's|^GRUB_GFXMODE=.*|GRUB_GFXMODE=1920x1080,auto|' "${GRUB_DEFAULT}"
fi

# Ensure OS prober is enabled for multi-boot
if ! grep -q "^GRUB_DISABLE_OS_PROBER=false" "${GRUB_DEFAULT}"; then
    echo "GRUB_DISABLE_OS_PROBER=false" >> "${GRUB_DEFAULT}"
fi

echo "[INFO] Regenerating GRUB config (/boot/grub/grub.cfg)..."
grub-mkconfig -o /boot/grub/grub.cfg

echo "[OK] Hyprdark GRUB theme installed successfully."
