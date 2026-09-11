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
INSTALL_GRUB=false
INSTALL_SDDM=false
PHASE=""

show_help() {
    cat << HELP
Hyprdark Automated Installer

Usage: ./install.sh [OPTIONS]

Options:
  -h, --help        Show this help message and exit
  -b, --backup-only Run configuration backup only and exit
  -n, --no-deps     Skip dependency checks and package installations
  -d, --dry-run     Simulate actions without modifying the filesystem
  -p, --phase <1-6> Deploy only a specific phase for incremental testing
      --no-shell    Skip Zsh and Oh My Zsh configuration
      --grub        Deploy custom Hyprdark GRUB theme (requires sudo)
      --sddm        Deploy custom Hyprdark SDDM theme (requires sudo)
      --all         Deploy dotfiles, shell, GRUB theme, and SDDM theme

Phases:
  1: Safety backup snapshot
  2: Core Hyprland configuration (hypr)
  3: Shell, Terminal & File Management (kitty, zsh, yazi, thunar, gtk)
  4: Quickshell UI & Top-Left Island (quickshell)
  5: Menus & Session Controls (rofi, wlogout)
  6: System Themes (GRUB bootloader & SDDM login screen)

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
        -p|--phase)
            PHASE="$2"
            shift 2
            ;;
        --no-shell)
            SETUP_SHELL=false
            shift
            ;;
        --grub)
            INSTALL_GRUB=true
            shift
            ;;
        --sddm)
            INSTALL_SDDM=true
            shift
            ;;
        --all)
            INSTALL_GRUB=true
            INSTALL_SDDM=true
            shift
            ;;
        *)
            log_err "Unknown argument: $1"
            show_help
            exit 1
            ;;
    esac
done

if [ "${PHASE}" = "1" ]; then
    BACKUP_ONLY=true
fi
if [ "${PHASE}" = "6" ]; then
    INSTALL_GRUB=true
    INSTALL_SDDM=true
fi

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
        "hyprpaper"
        "quickshell"
        "kitty"
        "zsh"
        "zsh-completions"
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
        "rofi"
        "thunar"
        "thunar-archive-plugin"
        "yazi"
        "grim"
        "slurp"
        "swappy"
        "wl-clipboard"
        "cliphist"
        "brightnessctl"
        "ttf-jetbrains-mono-nerd"
        "fastfetch"
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
        "wlogout"
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
        log_warn "yay AUR helper is not installed. Skipping AUR packages (wlogout)."
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

        # Filter by phase if specified
        if [ -n "${PHASE}" ]; then
            case "${PHASE}" in
                2) [ "${name}" != "hypr" ] && continue ;;
                3) [[ ! "${name}" =~ ^(kitty|yazi|gtk-3.0|Thunar)$ ]] && continue ;;
                4) [ "${name}" != "quickshell" ] && continue ;;
                5) [[ ! "${name}" =~ ^(rofi|wlogout)$ ]] && continue ;;
                *) continue ;;
            esac
        fi

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
# 4. Wallpaper Library Setup (~/Pictures/Wallpapers)
# ------------------------------------------------------------------------------
log_step "Step 4: Deploying Wallpaper Library (~/Pictures/Wallpapers)"

WALLPAPERS_TARGET="${HOME}/Pictures/Wallpapers"
if [ "${DRY_RUN}" = false ]; then
    mkdir -p "${WALLPAPERS_TARGET}"
    if [ -d "${REPO_DIR}/Background" ]; then
        cp -u "${REPO_DIR}/Background"/* "${WALLPAPERS_TARGET}/" 2>/dev/null || cp -n "${REPO_DIR}/Background"/* "${WALLPAPERS_TARGET}/" 2>/dev/null || cp "${REPO_DIR}/Background"/* "${WALLPAPERS_TARGET}/" 2>/dev/null || true
        log_success "Wallpapers synchronized from Background/ -> ~/Pictures/Wallpapers"
    fi
else
    log_info "[DRY-RUN] Would create ~/Pictures/Wallpapers and copy wallpapers from Background/"
fi

# ------------------------------------------------------------------------------
# 5. Zsh & Oh My Zsh Setup
# ------------------------------------------------------------------------------
if [ "${SETUP_SHELL}" = true ] && { [ -z "${PHASE}" ] || [ "${PHASE}" = "3" ]; }; then
    log_step "Step 5: Configuring Zsh & Oh My Zsh Environment"

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
# 6. Make helper scripts executable
# ------------------------------------------------------------------------------
log_step "Step 6: Setting Script Permissions"
if [ "${DRY_RUN}" = false ]; then
    find "${SCRIPTS_DIR}" -type f -name "*.sh" -exec chmod +x {} +
    find "${CONFIG_DIR}" -type f -name "*.sh" -exec chmod +x {} +
    find "${REPO_DIR}/themes" -type f -name "*.sh" -exec chmod +x {} +
    log_success "Executable permissions verified for all helper and theme scripts."
fi

# ------------------------------------------------------------------------------
# 7. Optional GRUB Theme Deployment
# ------------------------------------------------------------------------------
if [ "${INSTALL_GRUB}" = true ]; then
    log_step "Step 7: Deploying Hyprdark GRUB Theme"
    if [ "${DRY_RUN}" = false ]; then
        sudo "${REPO_DIR}/themes/grub/install-grub-theme.sh"
    else
        log_info "[DRY-RUN] Would execute sudo ${REPO_DIR}/themes/grub/install-grub-theme.sh"
    fi
fi

# ------------------------------------------------------------------------------
# 8. Optional SDDM Theme Deployment
# ------------------------------------------------------------------------------
if [ "${INSTALL_SDDM}" = true ]; then
    log_step "Step 8: Deploying Hyprdark SDDM Theme"
    if [ "${DRY_RUN}" = false ]; then
        sudo "${REPO_DIR}/themes/sddm/install-sddm-theme.sh"
    else
        log_info "[DRY-RUN] Would execute sudo ${REPO_DIR}/themes/sddm/install-sddm-theme.sh"
    fi
fi

log_step "Hyprdark Deployment Complete!"
log_info "Restart Hyprland or reload config with: hyprctl reload"
log_info "To change default shell to zsh: chsh -s \$(which zsh)"
