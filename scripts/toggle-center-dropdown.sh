#!/usr/bin/env bash
# Hyprdark - Toggle Unified Calendar & Notification Center
QS_PATH="$HOME/.config/quickshell/shell.qml"
[ -L "$HOME/.config/quickshell" ] && QS_PATH="$(readlink -f "$HOME/.config/quickshell")/shell.qml"
[ ! -f "$QS_PATH" ] && QS_PATH="$HOME/Desktop/Github/Hyprdark/config/quickshell/shell.qml"

if command -v quickshell &>/dev/null; then
    quickshell ipc -p "$QS_PATH" call hyprdark toggleCenterDrawer 2>/dev/null && exit 0
fi
