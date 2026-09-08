# Important apps
sudo pacman -S git gcc vlc nano os-prober fastfetch xorg-xhost

# Hyprland dependecies
sudo pacman -S hyprpolkitagent
sudo pacman -S hyprpaper
sudo pacman -S waybar
sudo pacman -S wl-clipboard
sudo pacman -S hyprlauncher
sudo pacman -S --needed base-devel

# Authentication agent startup
~/.config/hypr/hyprland.lua
```lua
hl.on("hyprland.start", function () 
  hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
end)
```

# Yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -dfr yay

# User apps
yay -S brave-browser sublime-text antigravity timeshift github-desktop windscribe-cli
sudo pacman -Syu docker docker-compose docker-buildx

# Fixing the Grub duplicate entry

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