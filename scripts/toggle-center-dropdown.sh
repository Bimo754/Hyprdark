#!/usr/bin/env bash
# Hyprdark - Toggle Unified Calendar & Notification Center
PID_FILE="/tmp/hyprdark-calendar-service.pid"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE" 2>/dev/null)
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
        kill -USR1 "$PID"
        exit 0
    fi
fi

# Fallback if pid file is absent or stale
pkill -USR1 -f "calendar-service.py" || ~/.config/hypr/scripts/calendar-service.py &
