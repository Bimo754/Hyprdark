#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - Unified Video & Static Wallpaper Manager
# Seamlessly switches between static images (hyprpaper) and hardware-accelerated
# video loops (mpvpaper with auto-pause & zero-overhead GPU decoding).
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BG_DIR="${REPO_DIR}/Background"

STATE_DIR="${HOME}/.local/share/hyprdark"
STATE_FILE="${STATE_DIR}/current_wallpaper"
HYPRPAPER_CONF="${HOME}/.config/hypr/hyprpaper.conf"

mkdir -p "${STATE_DIR}" "$(dirname "${HYPRPAPER_CONF}")"

# Terminal ANSI colors
C_RESET="\033[0m"
C_CYAN="\033[1;36m"
C_GREEN="\033[1;32m"
C_RED="\033[1;31m"
C_YELLOW="\033[1;33m"

log_info() { printf "${C_CYAN}[INFO]${C_RESET} %s\n" "$1"; }
log_ok()   { printf "${C_GREEN}[OK]${C_RESET}   %s\n" "$1"; }
log_warn() { printf "${C_YELLOW}[WARN]${C_RESET} %s\n" "$1"; }
log_err()  { printf "${C_RED}[ERR]${C_RESET}  %s\n" "$1" >&2; }

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Hyprdark Wallpaper" "$1" -u low 2>/dev/null || true
    fi
}

is_video() {
    local file="$1"
    local ext="${file##*.}"
    ext="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"
    case "$ext" in
        mp4|webm|mkv|mov|avi) return 0 ;;
        *) return 1 ;;
    esac
}

is_image() {
    local file="$1"
    local ext="${file##*.}"
    ext="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"
    case "$ext" in
        png|jpg|jpeg|webp|bmp) return 0 ;;
        *) return 1 ;;
    esac
}

apply_static_wallpaper() {
    local target="$1"
    log_info "Applying static wallpaper: $(basename "${target}")"

    # Terminate video engine if running
    killall mpvpaper 2>/dev/null || true

    # Write modern hyprpaper v0.8+ configuration
    cat << EOF > "${HYPRPAPER_CONF}"
ipc = on

wallpaper {
    monitor = 
    path = ${target}
    fit_mode = cover
}
EOF

    # Ensure hyprpaper is running
    if ! pgrep -x "hyprpaper" >/dev/null 2>&1; then
        hyprpaper >/dev/null 2>&1 &
    else
        # Restart hyprpaper to cleanly apply updated config
        killall hyprpaper 2>/dev/null || true
        hyprpaper >/dev/null 2>&1 &
    fi

    echo "${target}" > "${STATE_FILE}"
    log_ok "Static wallpaper active: $(basename "${target}")"
    notify "Static wallpaper active: $(basename "${target}")"
}

apply_video_wallpaper() {
    local target="$1"
    if ! command -v mpvpaper >/dev/null 2>&1; then
        log_err "mpvpaper is not installed. Video wallpaper cannot be played."
        return 1
    fi

    log_info "Applying video wallpaper: $(basename "${target}")"

    # Terminate static and existing video wallpaper engines
    killall hyprpaper mpvpaper 2>/dev/null || true

    # Launch mpvpaper with hardware acceleration and auto-pause on fullscreen/maximized windows
    # -p: auto-pause when hidden
    # -a MAX: pause when window is fullscreen/maximized
    # -o "no-audio loop hwdec=auto --framedrop=vo": zero CPU overhead & HW decoding
    mpvpaper -p -a MAX -o "no-audio loop hwdec=auto --framedrop=vo" '*' "${target}" >/dev/null 2>&1 &

    echo "${target}" > "${STATE_FILE}"
    log_ok "Video wallpaper active: $(basename "${target}")"
    notify "Video wallpaper active: $(basename "${target}")"
}

apply_wallpaper() {
    local target="$1"
    if [ ! -f "${target}" ]; then
        log_err "File not found: ${target}"
        exit 1
    fi

    if is_video "${target}"; then
        apply_video_wallpaper "${target}"
    elif is_image "${target}"; then
        apply_static_wallpaper "${target}"
    else
        log_err "Unsupported wallpaper format: ${target}"
        exit 1
    fi
}

restore_wallpaper() {
    if [ -f "${STATE_FILE}" ]; then
        local saved
        saved="$(cat "${STATE_FILE}")"
        if [ -f "${saved}" ]; then
            log_info "Restoring saved wallpaper: ${saved}"
            apply_wallpaper "${saved}"
            return 0
        fi
    fi

    # Fallback to default in Background/
    local fallback="${BG_DIR}/red-skull-glitch.png"
    if [ -f "${fallback}" ]; then
        log_info "Applying default wallpaper fallback: ${fallback}"
        apply_wallpaper "${fallback}"
    fi
}

# CLI Argument parsing
if [ $# -gt 0 ]; then
    case "$1" in
        -r|--restore)
            restore_wallpaper
            exit 0
            ;;
        -h|--help)
            echo "Usage: $0 [path/to/wallpaper | --restore]"
            exit 0
            ;;
        *)
            apply_wallpaper "$1"
            exit 0
            ;;
    esac
fi

# Interactive Selection Mode
if [ -n "${WAYLAND_DISPLAY:-}" ] && command -v rofi >/dev/null 2>&1; then
    # Generate list of available wallpapers and videos
    ITEMS=()
    while IFS= read -r file; do
        [ -z "${file}" ] && continue
        bname="$(basename "${file}")"
        if is_video "${file}"; then
            ITEMS+=("[VIDEO]  ${bname}")
        elif is_image "${file}"; then
            ITEMS+=("[IMAGE]  ${bname}")
        fi
    done < <(find "${BG_DIR}" -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" -o -name "*.mp4" -o -name "*.webm" \) | sort)

    if [ ${#ITEMS[@]} -eq 0 ]; then
        log_err "No wallpapers found in ${BG_DIR}"
        notify "No wallpapers found in ${BG_DIR}"
        exit 1
    fi

    ROFI_THEME="${HOME}/.config/rofi/theme.rasi"
    ROFI_ARGS=(-dmenu -p "WALLPAPER")
    if [ -f "${ROFI_THEME}" ]; then
        ROFI_ARGS+=(-theme "${ROFI_THEME}")
    fi

    CHOICE=$(printf '%s\n' "${ITEMS[@]}" | rofi "${ROFI_ARGS[@]}")
    if [ -n "${CHOICE}" ]; then
        # Strip prefix tag [IMAGE] or [VIDEO]
        SELECTED_NAME="$(echo "${CHOICE}" | sed -E 's/^\[(IMAGE|VIDEO)\][[:space:]]+//')"
        apply_wallpaper "${BG_DIR}/${SELECTED_NAME}"
    fi
else
    echo "Available Wallpapers & Videos in ${BG_DIR}:"
    mapfile -t FILES < <(find "${BG_DIR}" -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" -o -name "*.mp4" -o -name "*.webm" \) | sort)
    select file in "${FILES[@]}"; do
        if [ -n "${file}" ] && [ -f "${file}" ]; then
            apply_wallpaper "${file}"
            break
        fi
    done
fi
