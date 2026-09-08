#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - Screenshot & Security Evidence Capture Pipeline
# Uses grim, slurp, and swappy for rapid screen recording and annotation.
# ==============================================================================

set -euo pipefail

SAVE_DIR="${HOME}/Pictures/Screenshots"
mkdir -p "${SAVE_DIR}"

TIMESTAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
OUTPUT_FILE="${SAVE_DIR}/screenshot_${TIMESTAMP}.png"

MODE="${1:-area}"

case "${MODE}" in
    full)
        grim "${OUTPUT_FILE}"
        wl-copy < "${OUTPUT_FILE}"
        notify-send "Hyprdark Capture" "Fullscreen captured & copied to clipboard.\nSaved to: ${OUTPUT_FILE}" -u low
        ;;
    area)
        GEOMETRY=$(slurp 2>/dev/null || true)
        if [ -n "${GEOMETRY}" ]; then
            grim -g "${GEOMETRY}" "${OUTPUT_FILE}"
            wl-copy < "${OUTPUT_FILE}"
            notify-send "Hyprdark Capture" "Selected area captured & copied.\nSaved to: ${OUTPUT_FILE}" -u low
        fi
        ;;
    edit)
        GEOMETRY=$(slurp 2>/dev/null || true)
        if [ -n "${GEOMETRY}" ]; then
            grim -g "${GEOMETRY}" - | swappy -f -
        fi
        ;;
    *)
        echo "Usage: $0 [full|area|edit]"
        exit 1
        ;;
esac
