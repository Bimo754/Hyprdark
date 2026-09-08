#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - System & User Config Backup Utility
# Purpose: Safely snapshot existing dotfiles prior to linking Hyprdark components.
# ==============================================================================

set -euo pipefail

BACKUP_ROOT="${HOME}/.local/share/hyprdark/backups"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
TARGET_DIR="${BACKUP_ROOT}/backup_${TIMESTAMP}"

# Color codes (strict ANSI, no emojis)
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_GREEN="\033[1;32m"
C_CYAN="\033[1;36m"
C_YELLOW="\033[1;33m"
C_RED="\033[1;31m"

log_info() {
    printf "${C_CYAN}[INFO]${C_RESET} %s\n" "$1"
}

log_success() {
    printf "${C_GREEN}[OK]${C_RESET}   %s\n" "$1"
}

log_warn() {
    printf "${C_YELLOW}[WARN]${C_RESET} %s\n" "$1"
}

log_err() {
    printf "${C_RED}[ERR]${C_RESET}  %s\n" "$1" >&2
}

mkdir -p "${TARGET_DIR}"

log_info "Initiating Hyprdark configuration snapshot..."
log_info "Target backup directory: ${TARGET_DIR}"

CONFIG_ITEMS=(
    "hypr"
    "kitty"
    "waybar"
    "rofi"
    "dunst"
    "swaync"
    "wlogout"
    "yazi"
    "gtk-3.0"
)

BACKED_COUNT=0

for item in "${CONFIG_ITEMS[@]}"; do
    src_path="${HOME}/.config/${item}"
    if [ -e "${src_path}" ] || [ -L "${src_path}" ]; then
        dest_path="${TARGET_DIR}/config/${item}"
        mkdir -p "$(dirname "${dest_path}")"
        cp -a "${src_path}" "${dest_path}"
        log_success "Backed up ~/.config/${item} -> ${dest_path}"
        BACKED_COUNT=$((BACKED_COUNT + 1))
    fi
done

# Individual shell dotfiles
SHELL_FILES=(
    ".zshrc"
    ".bashrc"
    ".p10k.zsh"
)

for shfile in "${SHELL_FILES[@]}"; do
    src_sh="${HOME}/${shfile}"
    if [ -f "${src_sh}" ] || [ -L "${src_sh}" ]; then
        dest_sh="${TARGET_DIR}/shell/${shfile}"
        mkdir -p "$(dirname "${dest_sh}")"
        cp -a "${src_sh}" "${dest_sh}"
        log_success "Backed up ~/${shfile} -> ${dest_sh}"
        BACKED_COUNT=$((BACKED_COUNT + 1))
    fi
done

# Write backup manifest
cat << MANIFEST > "${TARGET_DIR}/MANIFEST.txt"
Hyprdark Backup Manifest
Timestamp: ${TIMESTAMP}
User: ${USER}
Host: $(hostname 2>/dev/null || echo "unknown")
Backed up items count: ${BACKED_COUNT}
MANIFEST

if [ "${BACKED_COUNT}" -eq 0 ]; then
    log_warn "No conflicting existing configurations were found to back up."
else
    log_success "Backup completed successfully. ${BACKED_COUNT} item(s) preserved in: ${TARGET_DIR}"
fi

exit 0
