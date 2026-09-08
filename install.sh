#!/usr/bin/env bash
# ==============================================================================
# Hyprdark - Master Installation & Deployment Engine
# Idempotent deployment of Hyprland, Zsh, Waybar, Rofi, Kitty & Cyber Tools.
# ==============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${REPO_DIR}/scripts"
CONFIG_DIR="${REPO_DIR}/config"

# Strict ANSI colors (no emojis)
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_GREEN="\033[1;32m"
C_CYAN="\033[1;36m"
C_YELLOW="\033[1;33m"
C_RED="\033[1;31m"
C_GRAY="\033[0;90m"

log_info()    { printf "${C_CYAN}[INFO]${C_RESET} %s\n" "$1"; }
log_success() { printf "${C_GREEN}[OK]${C_RESET}   %s\n" "$1"; }
log_warn()    { printf "${C_YELLOW}[WARN]${C_RESET} %s\n" "$1"; }
log_err()     { printf "${C_RED}[ERR]${C_RESET}  %s\n" "$1" >&2; }
log_step()    { printf "\n${C_BOLD}${C_CYAN}>>> %s${C_RESET}\n" "$1"; }

DRY_RUN=false
SKIP_DEPS=false
BACKUP_ONLY=false
SETUP_SHELL=true

show_help() {
    cat << HELP
Hyprdark Automated Installer

Usage: ./install.sh [OPTIONS]

Options:
  -h, --help        Show this help message and exit
  -b, --backup-only Run configuration backup only and exit
  -n, --no-deps     Skip dependency checks and package installations
  -d, --dry-run     Simulate actions without modifying the filesystem
      --no-shell    Skip Zsh and Oh My Zsh configuration

HELP
}

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -b|--backup-only)
            BACKUP_ONLY=true
            shift
            ;;
        -n|--no-deps)
            SKIP_DEPS=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        --no-shell)
            SETUP_SHELL=false
            shift
            ;;
        *)
            log_err "Unknown argument: $1"
            show_help
            exit 1
            ;;
    esac
done

# ------------------------------------------------------------------------------
# 1. Safety Backup
# ------------------------------------------------------------------------------
log_step "Step 1: Running Safety Backup"
if [ -f "${SCRIPTS_DIR}/backup.sh" ]; then
    bash "${SCRIPTS_DIR}/backup.sh"
else
    log_warn "Backup script not found at ${SCRIPTS_DIR}/backup.sh. Skipping snapshot."
fi

if [ "${BACKUP_ONLY}" = true ]; then
    log_info "Backup-only flag specified. Exiting."
    exit 0
fi

# ------------------------------------------------------------------------------
# 2. Dependency Verification & Installation
# ------------------------------------------------------------------------------
if [ "${SKIP_DEPS}" = false ]; then
    log_step "Step 2: Checking Core Dependencies"

    PACMAN_DEPS=(
        "hyprland"
        "hyprpolkitagent"
        "hyprcursor"
        "hyprlock"
        "hypridle"
        "kitty"
        "zsh"
        "zsh-completions"
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
        "waybar"
        "rofi"
        "thunar"
        "thunar-archive-plugin"
        "yazi"
        "grim"
        "slurp"
        "swappy"
        "wl-clipboard"
        "cliphist"
        "ttf-jetbrains-mono-nerd"
        "fastfetch"
        "mpv"
    )

    MISSING_PACMAN=()
    for pkg in "${PACMAN_DEPS[@]}"; do
        if ! pacman -Q "${pkg}" &>/dev/null; then
            MISSING_PACMAN+=("${pkg}")
        fi
    done

    if [ ${#MISSING_PACMAN[@]} -gt 0 ]; then
        log_info "The following official packages need installation:"
        for pkg in "${MISSING_PACMAN[@]}"; do
            printf "  ${C_GRAY}-${C_RESET} %s\n" "${pkg}"
        done
        if [ "${DRY_RUN}" = false ]; then
            log_info "Installing official dependencies via sudo pacman..."
            sudo pacman -S --needed --noconfirm "${MISSING_PACMAN[@]}"
            log_success "Official dependencies installed successfully."
        else
            log_info "[DRY-RUN] Would install: ${MISSING_PACMAN[*]}"
        fi
    else
        log_success "All official pacman dependencies are already installed."
    fi

    # Check AUR dependencies (yay)
    AUR_DEPS=(
        "mpvpaper"
        "wlogout"
        "swaync"
    )

    if command -v yay &>/dev/null; then
        MISSING_AUR=()
        for pkg in "${AUR_DEPS[@]}"; do
            if ! pacman -Q "${pkg}" &>/dev/null; then
                MISSING_AUR+=("${pkg}")
            fi
        done

        if [ ${#MISSING_AUR[@]} -gt 0 ]; then
            log_info "The following AUR packages need installation:"
            for pkg in "${MISSING_AUR[@]}"; do
                printf "  ${C_GRAY}-${C_RESET} %s\n" "${pkg}"
            done
            if [ "${DRY_RUN}" = false ]; then
                log_info "Installing AUR packages via yay..."
                yay -S --needed --noconfirm "${MISSING_AUR[@]}"
                log_success "AUR packages installed successfully."
            else
                log_info "[DRY-RUN] Would install AUR packages: ${MISSING_AUR[*]}"
            fi
        else
            log_success "All AUR dependencies are already installed."
        fi
    else
        log_warn "yay AUR helper is not installed. Skipping AUR packages (mpvpaper, wlogout, swaync)."
    fi
else
    log_info "Skipping dependency installation (--no-deps)."
fi

# ------------------------------------------------------------------------------
# 3. Deploy Dotfile Symlinks
# ------------------------------------------------------------------------------
log_step "Step 3: Deploying Modular Dotfiles"

mkdir -p "${HOME}/.config"

for config_item in "${CONFIG_DIR}"/*; do
    if [ -d "${config_item}" ]; then
        name="$(basename "${config_item}")"
        target="${HOME}/.config/${name}"

        # If it already points to our repo, skip
        if [ -L "${target}" ] && [ "$(readlink -f "${target}")" = "$(readlink -f "${config_item}")" ]; then
            log_success "~/.config/${name} already symlinked to repository."
            continue
        fi

        if [ "${DRY_RUN}" = false ]; then
            # If target exists and is not our symlink, remove it (it was already backed up in Step 1)
            if [ -e "${target}" ] || [ -L "${target}" ]; then
                rm -rf "${target}"
            fi
            ln -snf "${config_item}" "${target}"
            log_success "Linked: ${config_item} -> ~/.config/${name}"
        else
            log_info "[DRY-RUN] Would link: ${config_item} -> ~/.config/${name}"
        fi
    fi
done

# ------------------------------------------------------------------------------
# 4. Zsh & Oh My Zsh Setup
# ------------------------------------------------------------------------------
if [ "${SETUP_SHELL}" = true ]; then
    log_step "Step 4: Configuring Zsh & Oh My Zsh Environment"

    ZSH_DIR="${HOME}/.oh-my-zsh"
    if [ ! -d "${ZSH_DIR}" ]; then
        if [ "${DRY_RUN}" = false ]; then
            log_info "Cloning Oh My Zsh..."
            git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "${ZSH_DIR}"
            log_success "Oh My Zsh installed to ${ZSH_DIR}"
        else
            log_info "[DRY-RUN] Would clone Oh My Zsh to ${ZSH_DIR}"
        fi
    else
        log_success "Oh My Zsh is already present at ${ZSH_DIR}"
    fi

    # Deploy custom .zshrc
    ZSHRC_SOURCE="${REPO_DIR}/config/zsh/.zshrc"
    ZSHRC_TARGET="${HOME}/.zshrc"
    if [ -f "${ZSHRC_SOURCE}" ]; then
        if [ "${DRY_RUN}" = false ]; then
            ln -sf "${ZSHRC_SOURCE}" "${ZSHRC_TARGET}"
            log_success "Linked: ${ZSHRC_SOURCE} -> ~/.zshrc"
        else
            log_info "[DRY-RUN] Would link: ${ZSHRC_SOURCE} -> ~/.zshrc"
        fi
    fi
fi

# ------------------------------------------------------------------------------
# 5. Make helper scripts executable
# ------------------------------------------------------------------------------
log_step "Step 5: Setting Script Permissions"
if [ "${DRY_RUN}" = false ]; then
    find "${SCRIPTS_DIR}" -type f -name "*.sh" -exec chmod +x {} +
    log_success "Executable permissions verified for all helper scripts in scripts/"
fi

log_step "Hyprdark Deployment Complete!"
log_info "Restart Hyprland or reload config with: hyprctl reload"
log_info "To change default shell to zsh: chsh -s \$(which zsh)"
