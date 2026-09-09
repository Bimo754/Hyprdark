#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - Tide Island Desktop Shell Launcher
# Handles launching Tide Island from system install or local build
# ==============================================================================

# Kill conflicting bars/daemons
pkill -f "waybar" 2>/dev/null || true
pkill -f "calendar-service.py" 2>/dev/null || true

# Ensure ~/.config/quickshell points to Tide-island for standard default IPC routing
TIDE_DIR="/home/diamond/Desktop/Github/Tide-island"
if [ ! -e "${HOME}/.config/quickshell" ]; then
    ln -s "${TIDE_DIR}" "${HOME}/.config/quickshell"
fi

export QML_IMPORT_PATH="${TIDE_DIR}/build:${QML_IMPORT_PATH:-}"
export QUICKSHELL_LYRICS_BACKEND="${TIDE_DIR}/build/lyricsmpris"
export MALLOC_CONF="${MALLOC_CONF:-narenas:2,background_thread:true,dirty_decay_ms:2000,muzzy_decay_ms:2000}"

exec /usr/bin/quickshell "$@"
