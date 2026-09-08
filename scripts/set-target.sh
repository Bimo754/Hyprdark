#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - Target IP Controller
# Sets the active penetration testing target IP for Waybar and shell environment.
# ==============================================================================

set -euo pipefail

DATA_DIR="${HOME}/.local/share/hyprdark"
TARGET_FILE="${DATA_DIR}/target_ip"
mkdir -p "${DATA_DIR}"

if [ $# -gt 0 ]; then
    NEW_IP="$1"
    if [ "${NEW_IP}" = "clear" ] || [ "${NEW_IP}" = "reset" ]; then
        rm -f "${TARGET_FILE}"
        echo "[INFO] Target IP cleared."
        exit 0
    fi
    echo "${NEW_IP}" > "${TARGET_FILE}"
    echo "[OK] Active target set to: ${NEW_IP}"
    exit 0
fi

# If interactive in GUI
if [ -n "${WAYLAND_DISPLAY:-}" ] && command -v rofi >/dev/null 2>&1; then
    CURRENT=""
    [ -f "${TARGET_FILE}" ] && CURRENT="$(cat "${TARGET_FILE}")"
    INPUT=$(rofi -dmenu -theme ~/.config/rofi/theme.rasi -p "SET TARGET IP" -mesg "Current: ${CURRENT:-None} (Type 'clear' to reset)")
    if [ -n "${INPUT}" ]; then
        if [ "${INPUT}" = "clear" ] || [ "${INPUT}" = "reset" ]; then
            rm -f "${TARGET_FILE}"
            notify-send "Hyprdark" "Target IP cleared" -u low
        else
            echo "${INPUT}" > "${TARGET_FILE}"
            notify-send "Hyprdark" "Target set to: ${INPUT}" -u normal
        fi
    fi
else
    if [ -f "${TARGET_FILE}" ]; then
        echo "Current Target: $(cat "${TARGET_FILE}")"
    else
        echo "No target currently set."
    fi
    read -rp "Enter new target IP (or 'clear'): " VAL
    if [ -n "${VAL}" ]; then
        if [ "${VAL}" = "clear" ]; then
            rm -f "${TARGET_FILE}"
            echo "[INFO] Target IP cleared."
        else
            echo "${VAL}" > "${TARGET_FILE}"
            echo "[OK] Active target set to: ${VAL}"
        fi
    fi
fi
