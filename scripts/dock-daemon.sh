#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - GNOME-Style Auto-Hiding Bottom Dock Daemon (nwg-dock-hyprland)
# ==============================================================================

if ! command -v nwg-dock-hyprland >/dev/null 2>&1; then
    exit 0
fi

pkill -f "nwg-dock-hyprland" 2>/dev/null || true
sleep 0.2

STYLE_FILE="${HOME}/.config/nwg-dock-hyprland/style.css"
if [ ! -f "${STYLE_FILE}" ]; then
    STYLE_FILE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../config/nwg-dock-hyprland" && pwd)/style.css"
fi

exec nwg-dock-hyprland -d -p bottom -i 46 -mb 8 -hd 20 -s "${STYLE_FILE}"
