#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - Dynamic Island Notification Test Utility
# ==============================================================================

set -euo pipefail

TYPE="${1:-random}"
TITLE="${2:-}"
BODY="${3:-}"
ICON="${4:-}"

send_noti() {
    local app="$1"
    local summary="$2"
    local text="$3"
    local icon="${4:-}"
    local urgency="${5:-normal}"

    if [[ -n "$icon" ]]; then
        notify-send -a "$app" -i "$icon" -u "$urgency" "$summary" "$text"
    else
        notify-send -a "$app" -u "$urgency" "$summary" "$text"
    fi
    echo "[OK] Sent notification: [$app] $summary - $text"
}

case "$TYPE" in
    --music|music)
        send_noti "Spotify" "Now Playing: Night City" "Cyberpunk 2077 Soundtrack • 02:45" "spotify"
        ;;
    --chat|discord)
        send_noti "Discord" "s0mbra: Breach Protocol Ready" "Payload uploaded to 10.10.11.45" "discord"
        ;;
    --github|git)
        send_noti "GitHub" "Pull Request #42 Merged" "Hyprdark / dynamic-island-notifications into main" "github"
        ;;
    --sys|system)
        send_noti "System" "VPN Tunnel Connected" "Interface tun0 active (10.10.14.128)" "network-vpn"
        ;;
    --warn|warning|critical)
        send_noti "Security Alert" "Port Scan Detected" "Blocked 37 incoming SYN packets from 192.168.1.99" "dialog-warning" "critical"
        ;;
    --custom|custom)
        send_noti "${TITLE:-Test App}" "${BODY:-Hello from dynamic island!}" "${ICON:-}"
        ;;
    *)
        if [[ $# -ge 2 ]]; then
            send_noti "${1}" "${2}" "${3:-}" "${4:-}"
        else
            # Random sample
            SAMPLES=(
                "Spotify|Now Playing: Resonance|HOME • Odyssey|spotify|normal"
                "Discord|diamond: Check the new island animations!|Dynamic Island 2.0 is buttery smooth|discord|normal"
                "GitHub|Hyprdark Repository Update|Commit 7f9a1b: Add notification morph physics|github|normal"
                "Terminal|Compilation Finished|Build succeeded in 1.42s (0 errors, 0 warnings)|utilities-terminal|normal"
                "VPN Manager|Cyber Security Alert|WireGuard tunnel encrypted (10.10.14.200)|network-vpn|normal"
            )
            INDEX=$(( RANDOM % ${#SAMPLES[@]} ))
            IFS="|" read -r r_app r_sum r_body r_icon r_urg <<< "${SAMPLES[$INDEX]}"
            send_noti "$r_app" "$r_sum" "$r_body" "$r_icon" "$r_urg"
        fi
        ;;
esac
