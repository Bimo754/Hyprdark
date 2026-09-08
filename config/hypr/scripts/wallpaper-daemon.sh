#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - Dynamic Wallpaper Daemon
# Supports MP4 video wallpapers via mpvpaper with fallback to solid dark background.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd -P)"
REPO_DIR="$(cd "${SCRIPT_DIR}/../../.." && pwd -P)"
BG_DIR="${REPO_DIR}/Background"
if [ ! -d "${BG_DIR}" ] && [ -d "/home/diamond/Desktop/Github/Hyprdark/Background" ]; then
    BG_DIR="/home/diamond/Desktop/Github/Hyprdark/Background"
fi
DEFAULT_VIDEO="${BG_DIR}/red-skull-glitch-moewalls-com.mp4"

# Kill existing wallpaper daemons
pkill -f "mpvpaper" 2>/dev/null || true
pkill -f "hyprpaper" 2>/dev/null || true

if command -v mpvpaper >/dev/null 2>&1 && [ -d "${BG_DIR}" ]; then
    # If default video exists, play it looping seamlessly with no audio
    if [ -f "${DEFAULT_VIDEO}" ]; then
        exec mpvpaper -vs -o "no-audio --loop" '*' "${DEFAULT_VIDEO}"
    else
        # Fallback to any mp4 in the directory
        FIRST_VIDEO="$(find "${BG_DIR}" -type f -name "*.mp4" | head -n 1)"
        if [ -n "${FIRST_VIDEO}" ]; then
            exec mpvpaper -vs -o "no-audio --loop" '*' "${FIRST_VIDEO}"
        fi
    fi
fi

# Fallback: hyprpaper or solid color
if command -v hyprpaper >/dev/null 2>&1; then
    exec hyprpaper
fi
