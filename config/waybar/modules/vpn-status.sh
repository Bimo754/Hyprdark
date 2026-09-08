#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - Waybar VPN Status Monitor (tun0 / wg0 / ppp0)
# Outputs JSON for Waybar custom module. Strictly no emojis.
# ==============================================================================

VPN_IP=$(ip -4 addr show dev tun0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)

if [ -z "${VPN_IP}" ]; then
    VPN_IP=$(ip -4 addr show dev wg0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)
fi

if [ -n "${VPN_IP}" ]; then
    printf '{"text": "[VPN: %s]", "tooltip": "Active interface: tun0/wg0\\nIP: %s", "class": "connected"}\n' "${VPN_IP}" "${VPN_IP}"
else
    printf '{"text": "[VPN: DISCONNECTED]", "tooltip": "No active VPN tunnel", "class": "disconnected"}\n'
fi
