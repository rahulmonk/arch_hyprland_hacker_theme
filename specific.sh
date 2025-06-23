#!/bin/bash

#  ██╗  ██╗██╗   ██╗██████╗ ██████╗  ██████╗ ██╗  ██╗███████╗
#  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██╔═══██╗██║  ██║██╔════╝
#  ███████║ ╚████╔╝ ██████╔╝██████╔╝██║   ██║███████║█████╗
#  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║   ██║██╔══██║██╔══╝
#  ██║  ██║   ██║   ██║     ██║  ██║╚██████╔╝██║  ██║███████╗
#  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
#
#     F O U N D A T I O N    S C R I P T   (Phase 1)
#
#   This script installs and configures a bespoke Hyprland environment
#   with a focus on aesthetics, performance, and core functionality.
#

# --- PREP & SAFETY CHECK ---
echo "==========================================================="
echo "  HYPRLAND FOUNDATION INSTALLER  "
echo "==========================================================="
echo
echo "This script will install a specific set of packages and"
echo "overwrite any existing configs for:"
echo "-> hypr, hyprlock, hypridle, hyprpaper"
echo "-> kitty, waybar, wofi, wlogout"
echo
read -p "HAVE YOU BACKED UP YOUR EXISTING ~/.config FILES? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborting. Please backup your configs and run the script again."
    exit 1
fi

# --- SCRIPT SETUP ---
set -e # Exit immediately if a command exits with a non-zero status.

# --- VARIABLE DEFINITIONS ---
INSTALL_CMD="sudo pacman -S --noconfirm --needed"
AUR_HELPER="yay" # Change to 'paru' or your preferred helper if needed
CONFIG_DIR="$HOME/.config"

# --- ENSURE AUR HELPER IS INSTALLED ---
if ! command -v $AUR_HELPER &> /dev/null; then
    echo "AUR Helper ($AUR_HELPER) not found. Please install it first."
    echo "e.g., sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
    exit 1
fi
AUR_CMD="$AUR_HELPER -S --noconfirm --needed"

# --- PACKAGE INSTALLATION ---
echo "--- Installing Core Packages & Tools ---"

# Official Repo Packages
PACMAN_PACKAGES=(
    hyprland waybar wofi kitty # Core UI
    lazygit fzf # Productivity tools
    bash # Ensure bash is the shell
    thunar # File Manager
    ttf-jetbrains-mono-nerd noto-fonts-emoji ttf-font-awesome # Fonts & Icons
    polkit-kde-agent # Auth agent for privileges
    swaync # Notification daemon
    wlogout # Logout menu
    # Dependencies for functionality
    grim slurp # For screenshots
    pamixer brightnessctl playerctl # For media/system keys
)

# AUR Packages
AUR_PACKAGES=(
    hyprlock hypridle hyprpaper hyprshot-git # Hyprland Ecosystem
)

echo "--- Installing official repository packages... ---"
$INSTALL_CMD "${PACMAN_PACKAGES[@]}"

echo "--- Installing AUR packages... ---"
$AUR_CMD "${AUR_PACKAGES[@]}"

echo "--- Package installation complete. ---"

# --- CONFIGURATION DIRECTORY SETUP ---
echo "--- Setting up configuration directories... ---"
mkdir -p $CONFIG_DIR/{hypr,kitty,waybar,wofi,wlogout,swaync}

# --- DEPLOYING CONFIGURATION FILES ---

# --- Hyprland ---
echo "--- Deploying Hyprland Config ---"
cat << 'EOF' > $CONFIG_DIR/hypr/hyprland.conf
#   __  __           _                  _       _
#  |  \/  | __ _  __| | ___ _ __   __ _| | __ _| |__
#  | |\/| |/ _` |/ _` |/ _ \ '_ \ / _` | |/ _` | '_ \
#  | |  | | (_| | (_| |  __/ | | | (_| | | (_| | |_) |
#  |_|  |_|\__,_|\__,_|\___|_| |_|\__, |_|\__,_|_.__/
#                                |___/
#   >> Foundation v1 | by an Arch Veteran

# -----------------------------------------------------
# MONITORS & ENVIRONMENT
# -----------------------------------------------------
monitor=,preferred,auto,auto
env = XCURSOR_SIZE,24
env = HYPRCURSOR_THEME,Catppuccin-Mocha-Dark
env = HYPRCURSOR_SIZE,24

# -----------------------------------------------------
# AUTOSTART - Daemons and services
# -----------------------------------------------------
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = hyprpaper
exec-once = waybar
exec-once = hypridle
exec-once = swaync

# -----------------------------------------------------
# INPUT
# -----------------------------------------------------
input {
    kb_layout = us
    follow_mouse = 1
    touchpad { natural_scroll = no }
    sensitivity = 0
}

# -----------------------------------------------------
# AESTHETICS & ANIMATIONS - The "Glassmorphism" Core
# -----------------------------------------------------
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(cba6f7aa) rgba(89b4faaa) 45deg
    col.inactive_border = rgba(585b70aa)
    layout = dwindle
    resize_on_border = true
}

decoration {
    rounding = 12
    blur {
        enabled = true
        size = 8
        passes = 3
        new_optimizations = on
        xray = true
    }
    drop_shadow = yes
    shadow_range = 15
    shadow_render_power = 3
    shadow_color = rgba(1a1a1aee)
}

animations {
    enabled = yes
    bezier = wind, 0.05, 0.9, 0.1, 1.05
    bezier = winIn, 0.1, 1.1, 0.1, 1.1
    bezier = winOut, 0.3, -0.3, 0, 1
    animation = windows, 1, 6, wind, slide
    animation = windowsIn, 1, 5, winIn, slide
    animation = windowsOut, 1, 5, winOut, slide
    animation = border, 1, 10, default
    animation = fade, 1, 5, default
    animation = workspaces, 1, 6, wind, slide
}

dwindle {
    pseudotile = yes
    preserve_split = yes
}

master { new_on_top = true }
gestures { workspace_swipe = on }

# -----------------------------------------------------
# KEYBINDINGS - Phase 1 Foundation
# -----------------------------------------------------
$mainMod = SUPER

# --- Applications & System ---
bind = $mainMod, RETURN, exec, kitty
bind = $mainMod, D, exec, wofi --show drun
bind = $mainMod, E, exec, thunar
bind = $mainMod, Q, killactive,
bind = CTRL, ALT, L, exec, hyprlock
bind = CTRL, ALT, P, exec, wlogout

# --- Window Management ---
bind = $mainMod, F, fullscreen,
bind = $mainMod, SPACE, togglefloating,
bind = $mainMod, J, togglesplit, # Dwindle layout

# --- Focus & Move Windows ---
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

bind = $mainMod SHIFT, left, movewindow, l
bind = $mainMod SHIFT, right, movewindow, r
bind = $mainMod SHIFT, up, movewindow, u
bind = $mainMod SHIFT, down, movewindow, d

# --- Workspaces ---
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# --- Move window to workspace ---
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# --- Screenshots (via Hyprshot) ---
bind = , Print, exec, hyprshot -m output
bind = $mainMod, Print, exec, hyprshot -m window
bind = SHIFT, Print, exec, hyprshot -m region

# --- Mouse Bindings ---
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# --- Media and Volume Keys ---
binde=, XF86AudioRaiseVolume, exec, pamixer -i 5
binde=, XF86AudioLowerVolume, exec, pamixer -d 5
bind=, XF86AudioMute, exec, pamixer -t
binde=, XF86MonBrightnessUp, exec, brightnessctl s +5%
binde=, XF86MonBrightnessDown, exec, brightnessctl s 5%-
bind=, XF86AudioPlay, exec, playerctl play-pause
bind=, XF86AudioNext, exec, playerctl next
bind=, XF86AudioPrev, exec, playerctl previous
EOF

# --- Hypr-ecosystem configs ---
echo "--- Deploying Hypr Ecosystem Configs (Lock, Idle, Paper) ---"
# Hyprlock
cat << 'EOF' > $CONFIG_DIR/hypr/hyprlock.conf
background {
    path = ~/.config/hypr/wallpaper.jpg
    blur_passes = 3
    blur_size = 8
}

input-field {
    size = 200, 50
    outline_thickness = 3
    dots_size = 0.33
    dots_spacing = 0.15
    dots_center = true
    dots_rounding = -1
    fade_on_empty = true
    font_color = rgb(cdd6f4)
    inner_color = rgb(1e1e2e)
    outer_color = rgb(cba6f7)
    rounding = -1
    check_color = rgb(a6e3a1)
    fail_color = rgb(f38ba8)
    placeholder_text = <i>Password...</i>
}

label {
    text = Hi, $USER
    color = rgba(205, 214, 244, 1.0)
    font_size = 24
    font_family = JetBrainsMono Nerd Font
    position = 0, 80
    halign = center
    valign = center
}

label {
    text = cmd[update:1000] echo "$(date +"%R")"
    color = rgba(205, 214, 244, 1.0)
    font_size = 80
    font_family = JetBrainsMono Nerd Font
    position = 0, -50
    halign = center
    valign = center
}
EOF

# Hypridle
cat << 'EOF' > $CONFIG_DIR/hypr/hypridle.conf
general {
    lock_cmd = pidof hyprlock || hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
}

listener {
    timeout = 300
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
}

listener {
    timeout = 600
    on-timeout = systemctl suspend
}
EOF

# Hyprpaper
mkdir -p $CONFIG_DIR/hypr/
curl -s -L -o $CONFIG_DIR/hypr/wallpaper.jpg "https://images.unsplash.com/photo-1511447333015-45b65e60f6d5?q=80&w=1920&auto=format&fit=crop"
cat << 'EOF' > $CONFIG_DIR/hypr/hyprpaper.conf
preload = ~/.config/hypr/wallpaper.jpg
wallpaper = ,~/.config/hypr/wallpaper.jpg
splash = false
EOF

# --- Kitty Terminal ---
echo "--- Deploying Kitty Config ---"
cat << 'EOF' > $CONFIG_DIR/kitty/kitty.conf
font_family JetBrainsMono Nerd Font
bold_font auto
italic_font auto
bold_italic_font auto
font_size 11.0
remember_window_size  no
initial_window_width  900
initial_window_height 600
window_padding_width 15
background_opacity 0.85
background_blur 50
# Catppuccin-Mocha Theme
include current-theme.conf
EOF
curl -s -o $CONFIG_DIR/kitty/current-theme.conf https://raw.githubusercontent.com/catppuccin/kitty/main/mocha.conf

# --- Waybar ---
echo "--- Deploying Waybar Config ---"
cat << 'EOF' > $CONFIG_DIR/waybar/config
{
    "layer": "top", "position": "top", "height": 38,
    "modules-left": ["hyprland/workspaces", "hyprland/window"],
    "modules-center": ["clock"],
    "modules-right": ["tray", "pulseaudio", "network", "cpu", "memory", "battery"],
    "hyprland/workspaces": { "format": "{icon}", "on-click": "activate", "format-icons": { "default": "", "active": "", "urgent": "" }},
    "hyprland/window": { "format": "{} - ", "max-length": 50 },
    "clock": { "format": "{:%a %d %b  %H:%M}", "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>" },
    "cpu": { "format": " {usage}%", "tooltip": true },
    "memory": { "format": " {}%" },
    "network": { "format-wifi": "  {essid}", "format-ethernet": "󰈀", "format-disconnected": "󰖪" },
    "pulseaudio": { "format": "{icon} {volume}%", "format-muted": "", "format-icons": { "default": ["", ""] }},
    "battery": { "states": { "warning": 30, "critical": 15 }, "format": "{icon} {capacity}%", "format-charging": " {capacity}%", "format-icons": ["", "", "", "", ""]}
}
EOF
cat << 'EOF' > $CONFIG_DIR/waybar/style.css
* { border: none; border-radius: 0; font-family: JetBrainsMono Nerd Font, FontAwesome; font-size: 14px; min-height: 0; }
window#waybar { background: rgba(26, 27, 38, 0.8); color: #cdd6f4; border-bottom: 2px solid rgba(49, 50, 68, 0.9); }
#workspaces button { padding: 0 10px; background: transparent; color: #a6adc8; border-radius: 10px; }
#workspaces button.active { color: #cba6f7; background: #45475a; }
#window, #clock, #battery, #pulseaudio, #network, #cpu, #memory, #tray { padding: 0 10px; margin: 5px 3px; color: #cdd6f4; background-color: #313244; border-radius: 8px; }
#battery.critical:not(.charging) { color: #f38ba8; }
EOF

# --- Wofi & Wlogout ---
echo "--- Deploying Wofi & Wlogout Configs ---"
# Wofi
cat << 'EOF' > $CONFIG_DIR/wofi/style.css
window { border: 2px solid #cba6f7; border-radius: 15px; background-color: rgba(30, 30, 46, 0.85); font-family: JetBrainsMono Nerd Font; }
#input { margin: 10px; border: none; border-bottom: 2px solid #585b70; color: #cdd6f4; background-color: #1e1e2e; padding: 5px; border-radius: 5px; }
#inner-box { margin: 5px; } #outer-box { margin: 20px; } #scroll { margin-top: 5px; }
#text { padding: 5px; color: #bac2de; }
#entry:selected { background-color: #cba6f7; color: #1e1e2e; border-radius: 5px; }
EOF
# Wlogout
cat << 'EOF' > $CONFIG_DIR/wlogout/layout
{
  "label" : "shutdown", "action" : "systemctl poweroff"
}
{
  "label" : "reboot", "action" : "systemctl reboot"
}
{
  "label" : "lock", "action" : "hyprlock"
}
{
  "label" : "logout", "action" : "hyprctl dispatch exit"
}
EOF
cat << 'EOF' > $CONFIG_DIR/wlogout/style.css
* { font-family: FontAwesome; background-image: none; }
window { background-color: rgba(30, 30, 46, 0.85); }
button { color: #cdd6f4; background-color: #1e1e2e; border: 2px solid #585b70; border-radius: 15px; }
button:focus, button:hover { background-color: #cba6f7; color: #1e1e2e; border: 2px solid #cba6f7; }
EOF

# --- FINAL VERIFICATION & MESSAGE ---
echo ""
echo "--- Verifying installation... ---"
for pkg in hyprland waybar kitty wofi wlogout hyprlock; do
    if ! command -v $pkg &> /dev/null; then
        echo "ERROR: Command '$pkg' not found after installation. Something went wrong."
        exit 1
    fi
done
echo "--- Verification successful. All key components are installed. ---"

echo ""
echo "==========================================================="
echo "      ✅ PHASE 1: FOUNDATION COMPLETE"
echo "==========================================================="
echo ""
echo "The core system is installed and configured."
echo ""
echo "Next Step:"
echo "  1. Reboot your system: 'sudo reboot'"
echo "  2. At the login screen, select the 'Hyprland' session."
echo "  3. Log in and enjoy your new desktop."
echo ""
echo "Once you confirm everything is working, we can proceed to"
echo "Phase 2: adding advanced scripts and keybindings."
echo ""
