#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - Video & Wallpaper Control Utility
# Allows interactive switching between video wallpapers or passing video via CLI.
# ==============================================================================

set -euo pipefail

BG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../Background" && pwd)"

# Strict ANSI colors
C_RESET="\033[0m"
C_CYAN="\033[1;36m"
C_GREEN="\033[1;32m"
C_RED="\033[1;31m"

log_info() { printf "${C_CYAN}[INFO]${C_RESET} %s\n" "$1"; }
log_ok()   { printf "${C_GREEN}[OK]${C_RESET}   %s\n" "$1"; }
log_err()  { printf "${C_RED}[ERR]${C_RESET}  %s\n" "$1" >&2; }

if ! command -v hyprpaper >/dev/null 2>&1; then
    log_err "hyprpaper is not installed. Please install hyprpaper."
    exit 1
fi

apply_wallpaper() {
    local target="$1"
    if [ ! -f "${target}" ]; then
        log_err "File not found: ${target}"
        exit 1
    fi

    log_info "Applying wallpaper: $(basename "${target}")"
    if ! pgrep -x "hyprpaper" >/dev/null; then
        hyprpaper &
        sleep 0.5
    fi

    hyprctl hyprpaper preload "${target}" || true
    hyprctl hyprpaper wallpaper ",${target}" || true
    log_ok "Wallpaper active: $(basename "${target}")"
}

if [ $# -gt 0 ]; then
    apply_wallpaper "$1"
    exit 0
fi

# Interactive menu via rofi if in GUI session, else CLI menu
if [ -n "${WAYLAND_DISPLAY:-}" ] && command -v rofi >/dev/null 2>&1; then
    CHOICE=$(find "${BG_DIR}" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" \) -printf "%f\n" | rofi -dmenu -theme ~/.config/rofi/theme.rasi -p "WALLPAPER")
    if [ -n "${CHOICE}" ]; then
        apply_wallpaper "${BG_DIR}/${CHOICE}"
    fi
else
    echo "Available Wallpapers in ${BG_DIR}:"
    select file in "${BG_DIR}"/*.png "${BG_DIR}"/*.jpg "${BG_DIR}"/*.jpeg "${BG_DIR}"/*.webp; do
        if [ -n "${file}" ] && [ -f "${file}" ]; then
            apply_wallpaper "${file}"
            break
        fi
    done
fi
