#!/bin/bash

set -e
set -o pipefail

### === ARCH HACKERLAND: FRESH START SCRIPT === ###
# WARNING: This nukes Hyprland configs and reinstalls everything from scratch.

### === USER CONFIG === ###
USER_HOME="$HOME"
HYPR_CONFIG_DIR="$USER_HOME/.config/hypr"
WAYBAR_CONFIG_DIR="$USER_HOME/.config/waybar"
ROFI_CONFIG_DIR="$USER_HOME/.config/rofi"

### === 1. WIPE OLD CONFIGS === ###
echo "[+] Removing old configs..."
rm -rf \
  "$HYPR_CONFIG_DIR" \
  "$WAYBAR_CONFIG_DIR" \
  "$ROFI_CONFIG_DIR" \
  "$USER_HOME/.config/swaync" \
  "$USER_HOME/.config/wofi" \
  "$USER_HOME/.config/kitty" \
  "$USER_HOME/.config/rofi-beats" \
  "$USER_HOME/.config/swappy" \
  "$USER_HOME/.config/wlogout" \
  "$USER_HOME/.bash_profile"

### === 2. INSTALL AUR HELPER IF NEEDED === ###
echo "[+] Installing paru if not present..."
if ! command -v paru &>/dev/null; then
  sudo pacman -S --noconfirm --needed base-devel git
  git clone https://aur.archlinux.org/paru.git /tmp/paru
  pushd /tmp/paru
  makepkg -si --noconfirm
  popd
fi

### === 3. INSTALL SYSTEM PACKAGES === ###
echo "[+] Installing core packages..."
sudo paru -S --noconfirm --needed \
  hyprland \
  waybar \
  rofi \
  kitty \
  thunar thunar-volman gvfs udisks2 polkit-gnome \
  swww swappy hyprshot \
  swaync cliphist wl-clipboard \
  hyprlock hypridle wlogout \
  qalculate-gtk \
  mpv yt-dlp \
  fzf lazygit \
  pavucontrol pipewire wireplumber \
  networkmanager network-manager-applet \
  upower acpi acpid tlp \
  lxappearance papirus-icon-theme catppuccin-gtk-theme bibata-cursor-theme \
  ttf-jetbrains-mono-nerd noto-fonts-emoji ttf-font-awesome \
  grim slurp hyprpicker \
  starship bat exa zoxide btop neofetch \
  xdg-desktop-portal xdg-desktop-portal-hyprland xdg-user-dirs \
  greetd tuigreet

### === 4. ENABLE SYSTEM SERVICES === ###
echo "[+] Enabling required services..."
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now tlp.service
sudo systemctl enable --now acpid.service

### === 5. CONFIGURE AUTOSTART (TTY login) === ###
echo "[+] Setting up Hyprland to launch from TTY..."
cat <<EOF > "$USER_HOME/.bash_profile"
if [[ -z \$DISPLAY ]] && [[ \$(tty) = /dev/tty1 ]]; then
  exec Hyprland
fi
EOF

### === 6. SETUP XDG USER DIRS === ###
xdg-user-dirs-update

### === 7. DONE === ###
echo "[✓] Fresh Hyprland environment installed. Now configure your dotfiles and reboot."
echo "[!] Don’t forget to copy your Hyprland config into ~/.config/hypr after reboot."
