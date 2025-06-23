#!/bin/bash

set -e
set -o pipefail

### === HACKERLAND CONFIG SETUP === ###
# Hyprland, Waybar, Rofi, Kitty, and utilities

CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR"

### === 1. Hyprland Config === ###
echo "[+] Setting up Hyprland config..."
mkdir -p "$CONFIG_DIR/hypr"
cat <<'EOF' > "$CONFIG_DIR/hypr/hyprland.conf"
source = ~/.config/hypr/animations.conf
source = ~/.config/hypr/keybindings.conf
monitor = ,preferred,auto,1
exec-once = swww init
exec-once = swww img ~/.config/hypr/wallpapers/hackwave.png
exec-once = waybar &
exec-once = nm-applet &
exec-once = swaync &
exec-once = cliphist daemon &
exec-once = hypridle &
exec-once = hyprlock &
exec-once = wl-paste --type text --watch cliphist store &
exec-once = wl-paste --type image --watch cliphist store &
EOF

mkdir -p "$CONFIG_DIR/hypr/wallpapers"
wget -qO "$CONFIG_DIR/hypr/wallpapers/hackwave.png" https://hypr.land/imgs/blog/contestWinners/srev.png

cat <<'EOF' > "$CONFIG_DIR/hypr/animations.conf"
animations {
  enabled = yes
  bezier = myBezier, 0.05, 0.9, 0.1, 1.0
  animation = windows, 1, 7, myBezier, slide
  animation = windowsOut, 1, 7, default, popin 80%
  animation = border, 1, 10, default
  animation = fade, 1, 7, default
  animation = workspaces, 1, 6, default
}
EOF

cat <<'EOF' > "$CONFIG_DIR/hypr/keybindings.conf"
# App launching
bind = SUPER, RETURN, exec, kitty
bind = SUPER, D, exec, rofi -show drun
bind = SUPER, W, exec, wlogout
bind = SUPER, B, exec, rofi-beats

# Screenshot
bind = ,Print, exec, hyprshot -m output
bind = SHIFT, Print, exec, hyprshot -m region

# Clipboard
bind = SUPER, V, exec, rofi -modi "clipboard:cliphist list" -show clipboard -run-command 'cliphist decode {} | wl-copy'

# Volume
bindle = , XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%
bindle = , XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%
bindle = , XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle

# Brightness (for laptops)
bindle = , XF86MonBrightnessUp, exec, brightnessctl set +10%
bindle = , XF86MonBrightnessDown, exec, brightnessctl set 10%-

# Workspaces
bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER, 3, workspace, 3
bind = SUPER, 4, workspace, 4
bind = SUPER, 5, workspace, 5
bind = SUPER, 6, workspace, 6
bind = SUPER, 7, workspace, 7
bind = SUPER, 8, workspace, 8
bind = SUPER, 9, workspace, 9
bind = SUPER, 0, workspace, 10

bind = SUPER_SHIFT, left, movefocus, l
bind = SUPER_SHIFT, right, movefocus, r
bind = SUPER_SHIFT, up, movefocus, u
bind = SUPER_SHIFT, down, movefocus, d
EOF

### === 2. Waybar Config === ###
echo "[+] Setting up Waybar config..."
mkdir -p "$CONFIG_DIR/waybar"
cat <<'EOF' > "$CONFIG_DIR/waybar/config.json"
{
  "layer": "top",
  "position": "top",
  "modules-left": ["workspaces", "clock"],
  "modules-center": ["pulseaudio"],
  "modules-right": ["network", "battery", "tray"],
  "clock": {
    "format": "  %I:%M %p  %a %d %b"
  },
  "pulseaudio": {
    "format": "  {volume}%"
  },
  "battery": {
    "format": "  {capacity}%"
  },
  "network": {
    "format": "  {essid}"
  }
}
EOF

cat <<'EOF' > "$CONFIG_DIR/waybar/style.css"
* {
  font-family: 'JetBrainsMono Nerd Font';
  font-size: 13px;
  color: #ffffff;
  background-color: #1e1e2e;
}
#workspaces button.focused {
  background-color: #89b4fa;
  color: #000000;
}
EOF

### === 3. Rofi Theme === ###
echo "[+] Setting up Rofi theme..."
mkdir -p "$CONFIG_DIR/rofi"
cat <<'EOF' > "$CONFIG_DIR/rofi/config.rasi"
configuration {
  font: "JetBrainsMono Nerd Font 12";
  show-icons: true;
  icon-theme: "Papirus";
}
EOF

### === 4. Kitty Config === ###
echo "[+] Setting up Kitty..."
mkdir -p "$CONFIG_DIR/kitty"
cat <<'EOF' > "$CONFIG_DIR/kitty/kitty.conf"
font_family      JetBrainsMono Nerd Font
font_size        12.0
background_opacity 0.9
cursor_shape     beam
enable_audio_bell no
EOF

### === 5. Starship Prompt for Bash === ###
echo "[+] Configuring Starship for bash..."
echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"

### === 6. Final Touches === ###
echo "[✓] Hyprland configuration deployed. Aesthetic productivity now enabled."
echo "[!] Reboot and log into TTY to launch Hyprland."
