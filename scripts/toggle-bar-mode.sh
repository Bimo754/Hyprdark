#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - Bar Mode Switcher (Pinned vs Dynamic Island)
# Toggles between Pinned (Waybar-like) mode and Floating Dynamic Island mode.
# ==============================================================================

set -euo pipefail

REAL_SCRIPT="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "${REAL_SCRIPT}")" && pwd)"
if [[ -d "${SCRIPT_DIR}/../../quickshell" ]]; then
    CONFIG_DIR="$(cd "${SCRIPT_DIR}/../../quickshell" && pwd)"
elif [[ -d "${SCRIPT_DIR}/../quickshell" ]]; then
    CONFIG_DIR="$(cd "${SCRIPT_DIR}/../quickshell" && pwd)"
else
    CONFIG_DIR="$(cd "${SCRIPT_DIR}/../config/quickshell" && pwd)"
fi

# If Quickshell is not running, start it
if ! pgrep -x quickshell >/dev/null 2>&1; then
    "${SCRIPT_DIR}/quickshell-launcher.sh"
    sleep 0.5
fi

# Dispatch mode toggle via native Quickshell IPC
quickshell -p "${CONFIG_DIR}" ipc call barMode toggle
