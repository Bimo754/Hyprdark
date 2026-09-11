#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - Cyber Menu Dynamic Island Launcher
# Triggers the native Quickshell Dynamic Island Cyber Ops menu via IPC.
# ==============================================================================

set -euo pipefail

QS_DIR="${HOME}/Desktop/Github/Hyprdark/config/quickshell"
if [ ! -d "${QS_DIR}" ]; then
    QS_DIR="${HOME}/.config/quickshell"
fi

# Ensure Quickshell is running
if ! pgrep -x quickshell >/dev/null 2>&1; then
    ~/.config/hypr/scripts/quickshell-launcher.sh >/dev/null 2>&1 &
    sleep 0.4
fi

# Dispatch IPC toggle
quickshell ipc --any-display -p "${QS_DIR}" call cyber toggle 2>/dev/null || \
quickshell ipc --any-display -p "${HOME}/.config/quickshell" call cyber toggle 2>/dev/null || true
