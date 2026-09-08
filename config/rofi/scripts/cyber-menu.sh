#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - Cybersecurity Quick Ops Menu (Rofi Dmenu)
# Rapid access to pentesting targets, tools, servers, and system security controls.
# ==============================================================================

set -euo pipefail

TARGET_FILE="${HOME}/.local/share/hyprdark/target_ip"
CURRENT_TARGET="NONE"
[ -f "${TARGET_FILE}" ] && CURRENT_TARGET="$(cat "${TARGET_FILE}")"

OPTIONS=(
    "[1] Set Target IP (Current: ${CURRENT_TARGET})"
    "[2] Copy Target IP to Clipboard"
    "[3] Network & VPN Interface Status"
    "[4] Launch Python HTTP Server (Port 8000)"
    "[5] Quick Nmap Scan on Target (${CURRENT_TARGET})"
    "[6] Switch Wallpaper / Video Background"
    "[7] Lock Workstation (Hyprlock)"
    "[8] Dropdown Quake Terminal"
)

CHOICE=$(printf '%s\n' "${OPTIONS[@]}" | rofi -dmenu -theme ~/.config/rofi/theme.rasi -p "CYBER OPS")

case "${CHOICE}" in
    "[1]"*)
        ~/.config/hyprdark/scripts/set-target.sh 2>/dev/null || ~/Desktop/Github/Hyprdark/scripts/set-target.sh
        ;;
    "[2]"*)
        if [ "${CURRENT_TARGET}" != "NONE" ]; then
            echo -n "${CURRENT_TARGET}" | wl-copy
            notify-send "Hyprdark" "Copied ${CURRENT_TARGET} to clipboard" -u low
        else
            notify-send "Hyprdark" "No target IP currently configured." -u normal
        fi
        ;;
    "[3]"*)
        LAN_IP=$(ip -4 addr show scope global | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1 || echo "None")
        VPN_IP=$(ip -4 addr show tun0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || echo "Disconnected")
        notify-send "Network Status" "LAN: ${LAN_IP}\nVPN (tun0): ${VPN_IP}" -u normal
        ;;
    "[4]"*)
        kitty --title "Python HTTP Server :8000" bash -c 'echo "Serving on port 8000..."; python3 -m http.server 8000' &
        notify-send "Hyprdark" "HTTP server listening on :8000" -u low
        ;;
    "[5]"*)
        if [ "${CURRENT_TARGET}" != "NONE" ]; then
            kitty --title "Nmap Scan: ${CURRENT_TARGET}" bash -c "echo 'Scanning ${CURRENT_TARGET}...'; sudo nmap -sC -sV -Pn ${CURRENT_TARGET}; echo ''; read -p 'Press Enter to exit...'" &
        else
            notify-send "Hyprdark" "Please set a target IP first!" -u critical
        fi
        ;;
    "[6]"*)
        ~/.config/hyprdark/scripts/wallpaper-ctl.sh 2>/dev/null || ~/Desktop/Github/Hyprdark/scripts/wallpaper-ctl.sh
        ;;
    "[7]"*)
        hyprlock
        ;;
    "[8]"*)
        hyprctl dispatch togglespecialworkspace scratchpad
        ;;
esac
