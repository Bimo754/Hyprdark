# ==============================================================================
# Hyprdark - Zsh & Oh My Zsh Configuration
# High-contrast cyber prompt, cybersecurity workflow aliases, and auto-completions.
# ==============================================================================

# Oh My Zsh Path
export ZSH="${HOME}/.oh-my-zsh"

# Set Theme (Minimalist cyber two-line prompt, zero emojis)
ZSH_THEME=""

# Plugins definition
plugins=(git sudo history)

# Load Oh My Zsh if installed
if [ -f "${ZSH}/oh-my-zsh.sh" ]; then
    source "${ZSH}/oh-my-zsh.sh"
fi

# Load Arch Linux packaged zsh plugins if present
[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- Custom High-Contrast Cyber Prompt ---
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' [%F{196}git:%F{039}%b%F{240}]'

setopt PROMPT_SUBST
PROMPT='%F{240}┌──[%F{196}%n%F{240}@%F{045}%m%F{240}]─[%F{039}%~%F{240}]${vcs_info_msg_0_}%f
%F{240}└──╼ %F{196}%#%f '

# --- History Configuration ---
HISTSIZE=50000
SAVEHIST=50000
HISTFILE="${HOME}/.zsh_history"
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY

# --- Cybersecurity & Workflow Aliases ---
alias ll='ls -lah --color=auto --group-directories-first'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'

# Quick Pentest Helpers
alias serve='python3 -m http.server 8000'
alias ports='ss -tulpn'
alias myip='echo -n "LAN: "; ip -4 addr show scope global | grep -oP "(?<=inet\s)\d+(\.\d+){3}" | head -n 1 ; echo -n "VPN (tun0): "; ip -4 addr show tun0 2>/dev/null | grep -oP "(?<=inet\s)\d+(\.\d+){3}" || echo "Disconnected"'

# Target IP & Domains Controller
set-target() {
    local script_path="${HOME}/Desktop/Github/Hyprdark/scripts/set-target.sh"
    if [ -f "${script_path}" ]; then
        bash "${script_path}" "$@"
    elif [ -f "${HOME}/.config/hyprdark/scripts/set-target.sh" ]; then
        bash "${HOME}/.config/hyprdark/scripts/set-target.sh" "$@"
    else
        echo "$1" > "${HOME}/.local/share/hyprdark/target_ip"
        echo "[OK] Target set to: $1"
    fi
}

target() {
    if [ $# -gt 0 ]; then
        set-target "$@"
        return $?
    fi

    local target_file="${HOME}/.local/share/hyprdark/target_ip"
    if [ -f "${target_file}" ] && [ -s "${target_file}" ]; then
        local ip
        ip="$(cat "${target_file}")"
        echo "${ip}"
        if command -v wl-copy >/dev/null 2>&1; then
            echo -n "${ip}" | wl-copy
            echo "(Copied to clipboard)"
        fi
    else
        echo "No target currently set. Use: target <IP> or set-target <IP>"
    fi
}

# Package Management Shortcuts
alias update='sudo pacman -Syu && yay -Sua'
alias p-in='sudo pacman -S'
alias p-rm='sudo pacman -Rns'
alias y-in='yay -S'

# Fast CLI File Manager
alias y='yazi'

# Fastfetch on interactive shell launch
if [[ -o interactive ]] && command -v fastfetch >/dev/null 2>&1; then
    fastfetch --structure Title:Separator:OS:Host:Kernel:Uptime:Packages:Shell:DE:WM:Terminal:CPU:Memory
fi
