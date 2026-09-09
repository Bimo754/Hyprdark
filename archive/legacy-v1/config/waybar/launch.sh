#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - Waybar Launcher with Hyprland v0.56+ Lua Compatibility Shim
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHIM="$SCRIPT_DIR/libwaybar_hyprfix.so"

if [ -f "$SHIM" ]; then
    export LD_PRELOAD="$SHIM${LD_PRELOAD:+:$LD_PRELOAD}"
elif [ -f "$HOME/.config/waybar/libwaybar_hyprfix.so" ]; then
    export LD_PRELOAD="$HOME/.config/waybar/libwaybar_hyprfix.so${LD_PRELOAD:+:$LD_PRELOAD}"
fi

exec /usr/bin/waybar "$@"
