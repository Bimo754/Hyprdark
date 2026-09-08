#!/usr/bin/env bash
# Hyprdark - Toggle Unified Calendar & Notification Center
pkill -USR1 -f calendar-service.py || ~/.config/hypr/scripts/calendar-service.py &
