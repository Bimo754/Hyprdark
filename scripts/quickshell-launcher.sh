#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - Quickshell High-Performance Shell Launcher & Supervisor
# ==============================================================================

set -euo pipefail

REAL_SCRIPT="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "${REAL_SCRIPT}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../config/quickshell" && pwd)"

# Ensure symlink in ~/.config/quickshell points to active Hyprdark quickshell config
mkdir -p "${HOME}/.config"
ln -sfn "${CONFIG_DIR}" "${HOME}/.config/quickshell"

# Terminate any conflicting or stale instances
pkill -x quickshell 2>/dev/null || true
pkill -x waybar 2>/dev/null || true
pkill -f calendar-service.py 2>/dev/null || true
sleep 0.3

# Launch Quickshell detached daemon
quickshell -d -p "${CONFIG_DIR}"

echo "[OK] Hyprdark Quickshell started successfully."
