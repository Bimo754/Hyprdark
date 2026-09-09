#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - Target IP & Domain Controller
# Sets active penetration testing target IP and domain/subdomain telemetry.
# ==============================================================================

set -euo pipefail

DATA_DIR="${HOME}/.local/share/hyprdark"
TARGET_FILE="${DATA_DIR}/target_ip"
DOMAINS_FILE="${DATA_DIR}/target_domains"
mkdir -p "${DATA_DIR}"
touch "${DOMAINS_FILE}"

usage() {
    echo "Usage: $(basename "$0") [options] [IP|domain]"
    echo ""
    echo "Options:"
    echo "  <IP>                  Set the active target IP"
    echo "  -a, -d, --add <dom>   Add a domain or subdomain to the target list"
    echo "  -r, --rm <dom>        Remove a specific domain/subdomain from the list"
    echo "  --clear-ip            Clear target IP only"
    echo "  --clear-domains       Clear all domains/subdomains only"
    echo "  clear, reset          Clear target IP and all domains"
    echo "  -l, --list            List current target IP and all domains"
    echo "  -h, --help            Show this help message"
}

if [ $# -eq 0 ]; then
    # Interactive GUI prompt if in graphical session
    if [ -n "${WAYLAND_DISPLAY:-}" ] && command -v rofi >/dev/null 2>&1; then
        CURRENT_IP=""
        [ -f "${TARGET_FILE}" ] && CURRENT_IP="$(cat "${TARGET_FILE}")"
        INPUT=$(rofi -dmenu -theme ~/.config/rofi/theme.rasi -p "SET TARGET" -mesg "IP: ${CURRENT_IP:-None} (Syntax: IP, +domain, -domain, 'clear')")
        if [ -n "${INPUT}" ]; then
            if [ "${INPUT}" = "clear" ] || [ "${INPUT}" = "reset" ]; then
                rm -f "${TARGET_FILE}" "${DOMAINS_FILE}"
                notify-send "Hyprdark" "Target IP & domains cleared" -u low
            elif [[ "${INPUT}" =~ ^\+(.+) ]]; then
                DOM="${BASH_REMATCH[1]}"
                if ! grep -Fxq "${DOM}" "${DOMAINS_FILE}" 2>/dev/null; then
                    echo "${DOM}" >> "${DOMAINS_FILE}"
                    notify-send "Hyprdark" "Added domain: ${DOM}" -u normal
                fi
            elif [[ "${INPUT}" =~ ^\-(.+) ]]; then
                DOM="${BASH_REMATCH[1]}"
                grep -Fxv "${DOM}" "${DOMAINS_FILE}" > "${DOMAINS_FILE}.tmp" 2>/dev/null && mv "${DOMAINS_FILE}.tmp" "${DOMAINS_FILE}"
                notify-send "Hyprdark" "Removed domain: ${DOM}" -u normal
            else
                echo "${INPUT}" > "${TARGET_FILE}"
                notify-send "Hyprdark" "Target set to: ${INPUT}" -u normal
            fi
        fi
        exit 0
    else
        usage
        exit 0
    fi
fi

case "$1" in
    clear|reset)
        rm -f "${TARGET_FILE}" "${DOMAINS_FILE}"
        echo "[OK] Target IP and all domains cleared."
        exit 0
        ;;
    --clear-ip)
        rm -f "${TARGET_FILE}"
        echo "[OK] Target IP cleared."
        exit 0
        ;;
    --clear-domains)
        > "${DOMAINS_FILE}"
        echo "[OK] Target domains cleared."
        exit 0
        ;;
    -a|-d|--add|--add-domain)
        shift
        if [ $# -eq 0 ]; then
            echo "Error: Domain name required." >&2
            exit 1
        fi
        DOM="$1"
        if grep -Fxq "${DOM}" "${DOMAINS_FILE}" 2>/dev/null; then
            echo "[INFO] Domain '${DOM}' is already in the list."
        else
            echo "${DOM}" >> "${DOMAINS_FILE}"
            echo "[OK] Added domain: ${DOM}"
        fi
        exit 0
        ;;
    -r|--rm|--rm-domain|--delete-domain)
        shift
        if [ $# -eq 0 ]; then
            echo "Error: Domain name required." >&2
            exit 1
        fi
        DOM="$1"
        if [ -f "${DOMAINS_FILE}" ]; then
            grep -Fxv "${DOM}" "${DOMAINS_FILE}" > "${DOMAINS_FILE}.tmp" && mv "${DOMAINS_FILE}.tmp" "${DOMAINS_FILE}"
            echo "[OK] Removed domain: ${DOM}"
        fi
        exit 0
        ;;
    -l|--list)
        echo "=== Target Telemetry ==="
        if [ -f "${TARGET_FILE}" ] && [ -s "${TARGET_FILE}" ]; then
            echo "IP: $(cat "${TARGET_FILE}")"
        else
            echo "IP: None (Unset)"
        fi
        echo "Domains:"
        if [ -f "${DOMAINS_FILE}" ] && [ -s "${DOMAINS_FILE}" ]; then
            cat "${DOMAINS_FILE}" | nl -w2 -s'. '
        else
            echo "  (None)"
        fi
        exit 0
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        # Default argument is treated as IP or target
        NEW_IP="$1"
        echo "${NEW_IP}" > "${TARGET_FILE}"
        echo "[OK] Active target set to: ${NEW_IP}"
        exit 0
        ;;
esac
