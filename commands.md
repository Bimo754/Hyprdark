# Main things to install
Linux-zen kernel    [Main]
Nvidia open kernel module
Pipewire
Bluetooth
PowerManagement
NetworkManager

# Important apps
sudo pacman -S --needed git gcc vlc nano os-prober fastfetch man jq noto-fonts-emoji iptables unzip dnsmasq wget nftables linux-zen linux-zen-headers nvidia-open-dkms nvidia-utils dkms

# Hyprland dependecies
sudo pacman -S --needed \
    hyprland \
    hyprpolkitagent \
    hyprpaper \
    hypridle \
    hyprlock \
    rofi-wayland \
    wl-clipboard \
    cliphist \
    brightnessctl \
    wireplumber \
    grim \
    slurp \
    swappy \
    kitty \
    thunar \
    libnotify \
    python \
    qt6-declarative \
    qt6-connectivity \
    qt6-svg \
    qt6-5compat \
    ttf-jetbrains-mono-nerd \
    inter-font
yay -S --needed quickshell-git

<!-- Install.sh also downloads other things like oh my zsh -->

# Fixing the Grub duplicate entry (Must be changed since we are switching to Zen kerneln)

## Temp fix if kernel is not 7.2.4

```sh
sudo pacman -U --noconfirm \
  https://archive.archlinux.org/packages/l/linux-zen/linux-zen-7.2.4.zen2-1-x86_64.pkg.tar.zst \
  https://archive.archlinux.org/packages/l/linux-zen-headers/linux-zen-headers-7.2.4.zen2-1-x86_64.pkg.tar.zst
```

## 1. Install necessary boot packages
sudo pacman -S --needed grub efibootmgr os-prober intel-ucode

## 2. Fix mkinitcpio preset: enable traditional initramfs and disable UKI
sudo sed -i 's/^#default_image=/default_image=/' /etc/mkinitcpio.d/linux.preset
sudo sed -i 's/^default_uki=/#default_uki=/' /etc/mkinitcpio.d/linux.preset
sudo sed -i 's/^#fallback_image=/fallback_image=/' /etc/mkinitcpio.d/linux.preset
sudo sed -i 's/^fallback_uki=/#fallback_uki=/' /etc/mkinitcpio.d/linux.preset

## 3. Build the missing initramfs-linux.img
sudo mkinitcpio -p linux

## 4. Remove leftover UKI binary so GRUB stops creating the duplicate entry
sudo rm -f /boot/EFI/Linux/arch-linux.efi

## 5. Enable os-prober to detect Windows 11
echo "GRUB_DISABLE_OS_PROBER=false" | sudo tee -a /etc/default/grub

## 6. Regenerate the GRUB config
sudo grub-mkconfig -o /boot/grub/grub.cfg







# User apps

## Yay
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -dfr yay

## Brave
yay -S brave-browser

## Sublime
yay -S sublime-text

## Antigravity
yay -S antigravity

## Timeshift
yay -S timeshift

## GithubDesktop
yay -S github-desktop

## Windscribe
yay -S windscribe-v2-bin
sudo systemctl start windscribe-helper.service && systemctl --user start windscribe.service 2>&1

## Warp
yay -S cloudflare-warp-bin
sudo systemctl enable --now warp-svc

## CafeChameleon
<!-- You must modify the app to install.sh and use xorg-xhost -->

## Docker
sudo pacman -S docker docker-compose docker-buildx 

## Python
sudo pacman -S python python-pip

## Waydroid
sudo pacman -S waydroid
sudo systemctl enable --now waydroid-container

<!-- In the Waydroid dir -->

sudo ./Diagnostics/fix_binder_permissions.sh

sudo waydroid prop set ro.hardware.gralloc default
sudo waydroid prop set ro.hardware.egl swiftshader