#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - Dynamic Wallpaper Daemon
# Uses lightweight hyprpaper for static wallpapers (0% CPU / silent fans)
# with fallback to mpvpaper only if explicitly requested.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd -P)"
REPO_DIR="$(cd "${SCRIPT_DIR}/../../.." && pwd -P)"
BG_DIR="${REPO_DIR}/Background"
if [ ! -d "${BG_DIR}" ] && [ -d "/home/diamond/Desktop/Github/Hyprdark/Background" ]; then
    BG_DIR="/home/diamond/Desktop/Github/Hyprdark/Background"
fi

STATIC_IMG="${BG_DIR}/red-skull-glitch.png"

# Kill existing wallpaper daemons
pkill -f "mpvpaper" 2>/dev/null || true
pkill -f "hyprpaper" 2>/dev/null || true

# Prioritize hyprpaper for silent operation and 0% CPU footprint
if command -v hyprpaper >/dev/null 2>&1; then
    exec hyprpaper
fi

# Fallback to mpvpaper if hyprpaper is missing
DEFAULT_VIDEO="${BG_DIR}/red-skull-glitch-moewalls-com.mp4"
if command -v mpvpaper >/dev/null 2>&1 && [ -f "${DEFAULT_VIDEO}" ]; then
    exec mpvpaper -vs -o "no-audio --loop" '*' "${DEFAULT_VIDEO}"
fi
