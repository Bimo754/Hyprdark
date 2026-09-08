#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - Waybar Target IP Monitor
# Displays active penetration test target. Left click copies.
# Only configurable from the terminal (set-target <IP>).
# ==============================================================================

TARGET_FILE="${HOME}/.local/share/hyprdark/target_ip"

if [ -f "${TARGET_FILE}" ] && [ -s "${TARGET_FILE}" ]; then
    TARGET_IP=$(cat "${TARGET_FILE}" | tr -d '[:space:]')
    printf '{"text": "󰓾 %s", "tooltip": "Target: %s\\nLeft-click: Copy to clipboard", "class": "set"}\n' "${TARGET_IP}" "${TARGET_IP}"
else
    printf '{"text": "󰓾 None", "tooltip": "No target configured\\nSet via terminal: set-target <IP>", "class": "unset"}\n'
fi
