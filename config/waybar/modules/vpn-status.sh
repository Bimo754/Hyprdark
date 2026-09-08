#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - Waybar VPN Status Monitor (tun0 / wg0 / ppp0)
# Outputs JSON for Waybar custom module. Strictly no emojis.
# ==============================================================================

DATA_DIR="${HOME}/.local/share/hyprdark"
mkdir -p "${DATA_DIR}"
VPN_FILE="${DATA_DIR}/vpn_ip"

VPN_IP=$(ip -4 addr show dev tun0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)

if [ -z "${VPN_IP}" ]; then
    VPN_IP=$(ip -4 addr show dev wg0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)
fi

if [ -z "${VPN_IP}" ]; then
    VPN_IP=$(ip -4 addr show 2>/dev/null | grep -E 'inet .* (tun|wg|tap|ppp|tailscale)' | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)
fi

if [ -n "${VPN_IP}" ]; then
    printf "%s" "${VPN_IP}" > "${VPN_FILE}"
    printf '{"text": "󰖂 %s", "tooltip": "VPN Connected: %s\\nLeft-click: Copy to clipboard", "class": "connected"}\n' "${VPN_IP}" "${VPN_IP}"
else
    rm -f "${VPN_FILE}"
    printf '{"text": "󰖂 Off", "tooltip": "VPN Disconnected", "class": "disconnected"}\n'
fi
