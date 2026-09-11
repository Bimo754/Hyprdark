#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - Unified Video & Static Wallpaper Manager
# Seamlessly switches between static images (hyprpaper) and hardware-accelerated
# video loops (mpvpaper with auto-pause & zero-overhead GPU decoding).
# Supports auto-cycling wallpapers at configurable intervals (default: 5m).
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BG_DIR="${REPO_DIR}/Background"

STATE_DIR="${HOME}/.local/share/hyprdark"
STATE_FILE="${STATE_DIR}/current_wallpaper"
PID_FILE="${STATE_DIR}/wallpaper_daemon.pid"
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

get_all_wallpapers() {
    find "${BG_DIR}" -maxdepth 1 -type f \( \
        -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" -o \
        -name "*.mp4" -o -name "*.webm" \
    \) | sort
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

    # Fallback to first available wallpaper in Background/
    mapfile -t ALL_WP < <(get_all_wallpapers)
    if [ ${#ALL_WP[@]} -gt 0 ]; then
        log_info "Applying initial wallpaper fallback: ${ALL_WP[0]}"
        apply_wallpaper "${ALL_WP[0]}"
    fi
}

cycle_wallpaper() {
    local direction="${1:-next}"
    mapfile -t ALL_WP < <(get_all_wallpapers)
    local total=${#ALL_WP[@]}

    if [ "${total}" -eq 0 ]; then
        log_err "No wallpapers found in ${BG_DIR}"
        return 1
    fi

    local current=""
    [ -f "${STATE_FILE}" ] && current="$(cat "${STATE_FILE}")"

    local current_idx=-1
    for i in "${!ALL_WP[@]}"; do
        if [ "${ALL_WP[$i]}" = "${current}" ]; then
            current_idx=$i
            break
        fi
    done

    local next_idx=0
    if [ "${current_idx}" -ge 0 ]; then
        if [ "${direction}" = "next" ]; then
            next_idx=$(( (current_idx + 1) % total ))
        elif [ "${direction}" = "prev" ]; then
            next_idx=$(( (current_idx - 1 + total) % total ))
        elif [ "${direction}" = "random" ]; then
            if [ "${total}" -gt 1 ]; then
                next_idx=$(( RANDOM % total ))
                while [ "${next_idx}" -eq "${current_idx}" ]; do
                    next_idx=$(( RANDOM % total ))
                done
            else
                next_idx=0
            fi
        fi
    fi

    apply_wallpaper "${ALL_WP[$next_idx]}"
}

run_daemon() {
    local interval="${1:-300}" # Default 5 minutes (300s)

    # Stop any existing daemon instance
    if [ -f "${PID_FILE}" ]; then
        local old_pid
        old_pid="$(cat "${PID_FILE}")"
        if [ -n "${old_pid}" ] && kill -0 "${old_pid}" 2>/dev/null; then
            log_info "Stopping existing wallpaper daemon (PID: ${old_pid})"
            kill "${old_pid}" 2>/dev/null || true
        fi
    fi

    echo "$$" > "${PID_FILE}"
    trap 'rm -f "${PID_FILE}"; exit 0' SIGTERM SIGINT SIGHUP EXIT

    log_info "Starting wallpaper rotation daemon (Interval: ${interval}s / $((interval / 60))m)"
    restore_wallpaper

    while true; do
        sleep "${interval}"
        cycle_wallpaper "next" || true
    done
}

# CLI Argument parsing
if [ $# -gt 0 ]; then
    case "$1" in
        -d|--daemon)
            shift
            run_daemon "${1:-300}"
            exit 0
            ;;
        -n|--next)
            cycle_wallpaper "next"
            exit 0
            ;;
        -p|--prev)
            cycle_wallpaper "prev"
            exit 0
            ;;
        --random)
            cycle_wallpaper "random"
            exit 0
            ;;
        -r|--restore)
            restore_wallpaper
            exit 0
            ;;
        -h|--help)
            echo "Hyprdark Wallpaper Manager"
            echo "Usage: $0 [OPTIONS | path/to/wallpaper]"
            echo ""
            echo "Options:"
            echo "  -d, --daemon [seconds]  Run rotation daemon (default: 300s / 5m)"
            echo "  -n, --next              Switch to next wallpaper"
            echo "  -p, --prev              Switch to previous wallpaper"
            echo "      --random            Switch to a random wallpaper"
            echo "  -r, --restore           Restore last saved wallpaper"
            echo "  -h, --help              Show this help message"
            exit 0
            ;;
        *)
            apply_wallpaper "$1"
            exit 0
            ;;
    esac
fi

# Interactive Selection Mode (Rofi or CLI)
if [ -n "${WAYLAND_DISPLAY:-}" ] && command -v rofi >/dev/null 2>&1; then
    ITEMS=()
    while IFS= read -r file; do
        [ -z "${file}" ] && continue
        bname="$(basename "${file}")"
        if is_video "${file}"; then
            ITEMS+=("[VIDEO]  ${bname}")
        elif is_image "${file}"; then
            ITEMS+=("[IMAGE]  ${bname}")
        fi
    done < <(get_all_wallpapers)

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
        SELECTED_NAME="$(echo "${CHOICE}" | sed -E 's/^\[(IMAGE|VIDEO)\][[:space:]]+//')"
        apply_wallpaper "${BG_DIR}/${SELECTED_NAME}"
    fi
else
    echo "Available Wallpapers & Videos in ${BG_DIR}:"
    mapfile -t FILES < <(get_all_wallpapers)
    select file in "${FILES[@]}"; do
        if [ -n "${file}" ] && [ -f "${file}" ]; then
            apply_wallpaper "${file}"
            break
        fi
    done
fi
