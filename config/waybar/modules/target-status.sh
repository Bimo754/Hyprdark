#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - Waybar Target IP Monitor
# Displays active penetration test target. Left click copies, right click sets.
# ==============================================================================

TARGET_FILE="${HOME}/.local/share/hyprdark/target_ip"

if [ -f "${TARGET_FILE}" ] && [ -s "${TARGET_FILE}" ]; then
    TARGET_IP=$(cat "${TARGET_FILE}" | tr -d '[:space:]')
    printf '{"text": "󰓾 %s", "tooltip": "Target: %s\\nLeft-click: Copy to clipboard\\nRight-click: Change target", "class": "set"}\n' "${TARGET_IP}" "${TARGET_IP}"
else
    printf '{"text": "󰓾 None", "tooltip": "Click to set target IP", "class": "unset"}\n'
fi
