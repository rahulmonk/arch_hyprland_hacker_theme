#!/bin/bash

# ██╗  ██╗██╗   ██╗██████╗ ██████╗  ██████╗ ██╗  ██╗███████╗██████╗     ██████╗  ██████╗ ██╗     ███████╗
# ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██╔═══██╗██║  ██║██╔════╝██╔══██╗   ██╔════╝ ██╔═══██╗██║     ██╔════╝
# ███████║ ╚████╔╝ ██████╔╝██████╔╝██║   ██║███████║█████╗  ██████╔╝   ██║  ███╗██║   ██║██║     █████╗
# ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║   ██║██╔══██║██╔══╝  ██╔══██╗   ██║   ██║██║   ██║██║     ██╔══╝
# ██║  ██║   ██║   ██║     ██║  ██║╚██████╔╝██║  ██║███████╗██║  ██║██╗╚██████╔╝╚██████╔╝███████╗███████╗
# ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚══════╝
#
#               A R C H    L I N U X    +    H Y P R L A N D    E X P E R I E N C E  (v3)
#
#       Crafted by a veteran Arch developer for maximum style, efficiency, and "wow" factor.
#       This script installs and configures a complete, animation-heavy Hyprland desktop.
#
#       WARNING: This script will overwrite existing Hyprland, Kitty, Waybar, etc. configs.
#                Backup your ~/.config files before proceeding if you have existing setups.
#

# --- SCRIPT SETUP & SAFETY ---
set -e # Exit immediately if a command exits with a non-zero status.

# --- PREP & SAFETY CHECK ---
echo "=================================================================="
echo "ARCH + HYPRLAND HYPER-CUSTOMIZATION SCRIPT v3"
echo "=================================================================="
echo
echo "This script will install necessary packages and deploy a highly"
echo "customized configuration for Hyprland and related tools."
echo
read -p "HAVE YOU BACKED UP YOUR EXISTING ~/.config FILES? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborting. Please backup your configs and run the script again."
    exit 1
fi

# --- VARIABLE DEFINITIONS ---
INSTALL_CMD="sudo pacman -S --noconfirm --needed"
AUR_HELPER="yay" # Change to 'paru' or your preferred helper if needed

# --- ENSURE AUR HELPER IS INSTALLED ---
if ! command -v $AUR_HELPER &> /dev/null; then
    echo "$AUR_HELPER could not be found. Please install it first."
    echo "For example: sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
    exit 1
fi
AUR_CMD="$AUR_HELPER -S --noconfirm --needed"

# --- PACKAGE INSTALLATION (v3 - Corrected Lists) ---
echo "--- Installing Packages... This may take a moment. ---"
echo "--- You might be prompted for your password for sudo. ---"

# List of packages from official Arch repositories
PACMAN_PACKAGES=(
    hyprland kitty waybar wofi swaync swaybg swayidle
    ttf-jetbrains-mono-nerd noto-fonts-emoji polkit-kde-agent dunst
    grim slurp pamixer brightnessctl playerctl gvfs thunar
    qt5-wayland qt6-wayland xdg-desktop-portal-hyprland kvantum
    zsh tmux neovim ranger zathura zathura-pdf-mupdf bat eza fzf ripgrep lazygit
    ttf-font-awesome
)

# List of packages from the Arch User Repository (AUR)
AUR_PACKAGES=(
    papirus-icon-theme
    swaylock-effects
    nwg-look-bin
    wlogout
)

# Install packages
echo "--- Installing official repository packages... ---"
$INSTALL_CMD "${PACMAN_PACKAGES[@]}"

echo "--- Installing AUR packages... ---"
$AUR_CMD "${AUR_PACKAGES[@]}"

echo "--- Package installation complete. ---"


# --- CONFIGURATION DIRECTORY SETUP ---
echo "--- Setting up configuration directories... ---"
CONFIG_DIR="$HOME/.config"
mkdir -p $CONFIG_DIR/{hypr,kitty,waybar,swaync,wofi,cava,wlogout}

# --- ZSH & OH-MY-ZSH SETUP (for a better shell experience) ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "--- Installing Oh My Zsh for a superior terminal experience ---"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    # Set Zsh as default shell
    chsh -s $(which zsh)
else
    echo "--- Oh My Zsh already installed, skipping. ---"
fi


# --- HYPRLAND CONFIGURATION (FIXED) ---
echo "--- Deploying Hyprland Configuration ---"
cat << 'EOF' > $CONFIG_DIR/hypr/hyprland.conf
# ╭───────────────────────────────────────────────────────────╮
# │  ██╗  ██╗██╗   ██╗██████╗ ██████╗  ██████╗ ██╗  ██╗███████╗ │
# │  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██╔═══██╗██║  ██║██╔════╝ │
# │  ███████║ ╚████╔╝ ██████╔╝██████╔╝██║   ██║███████║█████╗   │
# │  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║   ██║██╔══██║██╔══╝   │
# │  ██║  ██║   ██║   ██║     ██║  ██║╚██████╔╝██║  ██║███████╗ │
# │  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝ │
# │                                                             │
# │ >> Arch-Veteran Hyprland Config v3 | Corrected & Enhanced <<│
# ╰───────────────────────────────────────────────────────────╯

# -----------------------------------------------------
# MONITORS & ENVIRONMENT
# -----------------------------------------------------
monitor=,preferred,auto,auto
env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORMTHEME,qt5ct

# -----------------------------------------------------
# AUTOSTART
# -----------------------------------------------------
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = swaybg -i ~/.config/hypr/wallpaper.jpg -m fill # Wallpaper
exec-once = waybar &
exec-once = swaync &
exec-once = swayidle -w timeout 300 'swaylock -f -c 000000' timeout 600 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on'

# -----------------------------------------------------
# INPUT
# -----------------------------------------------------
input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = no
    }
    sensitivity = 0
}

# -----------------------------------------------------
# AESTHETICS & ANIMATIONS
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
    rounding = 10
    
    blur {
        enabled = true
        size = 7
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

master {
    new_on_top = true
}

gestures {
    workspace_swipe = on
}

# -----------------------------------------------------
# KEYBINDINGS
# -----------------------------------------------------
$mainMod = SUPER

# --- Apps & Utilities ---
bind = $mainMod, RETURN, exec, kitty
bind = $mainMod, D, exec, wofi --show drun
bind = $mainMod, E, exec, thunar
bind = $mainMod, L, exec, swaylock -f -c 000000
bind = $mainMod, X, exec, wlogout --protocol layer-shell # Power Menu

# --- Screenshots ---
bind = , Print, exec, grim -g "$(slurp)" - | wl-copy
bind = SHIFT, Print, exec, grim - | wl-copy

# --- Window Management ---
bind = $mainMod, Q, killactive,
bind = $mainMod, F, fullscreen,
bind = $mainMod, SPACE, togglefloating,
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,

# --- Focus ---
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

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

# --- Mouse Bindings ---
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1
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

# -----------------------------------------------------
# WINDOW RULES
# -----------------------------------------------------
windowrulev2 = float, class:^(pavucontrol)$
windowrulev2 = float, class:^(blueman-manager)$
windowrulev2 = float, class:^(nm-connection-editor)$
windowrulev2 = float, title:^(File Operation Progress)$
windowrulev2 = float, class:^(org.kde.polkit-kde-authentication-agent-1)$

EOF

# --- KITTY TERMINAL CONFIGURATION ---
echo "--- Deploying Kitty Terminal Configuration ---"
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

# --- WAYBAR CONFIGURATION & STYLE ---
echo "--- Deploying Waybar Configuration ---"
cat << 'EOF' > $CONFIG_DIR/waybar/config
{
    "layer": "top",
    "position": "top",
    "height": 38,
    "modules-left": ["hyprland/workspaces", "hyprland/window"],
    "modules-center": ["clock"],
    "modules-right": ["tray", "pulseaudio", "network", "cpu", "memory", "battery", "custom-power"],

    "hyprland/workspaces": {
        "format": "{icon}", "on-click": "activate",
        "format-icons": { "default": "", "active": "", "urgent": "" }
    },
    "hyprland/window": { "format": "{} - ", "max-length": 50 },
    "clock": { "format": "{:%a %d %b  %H:%M}", "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>" },
    "cpu": { "format": " {usage}%", "tooltip": true },
    "memory": { "format": " {}%" },
    "network": {
        "format-wifi": "  {essid}", "format-ethernet": "� {ifname}", "format-disconnected": "󰖪",
        "tooltip-format": "{ifname} via {gwaddr} ", "on-click": "nm-connection-editor"
    },
    "pulseaudio": {
        "format": "{icon} {volume}%", "format-muted": " Muted",
        "format-icons": { "default": ["", ""] }, "on-click": "pavucontrol"
    },
    "battery": {
        "states": { "good": 95, "warning": 30, "critical": 15 },
        "format": "{icon} {capacity}%", "format-charging": " {capacity}%",
        "format-icons": ["", "", "", "", ""]
    },
    "tray": { "icon-size": 18, "spacing": 10 },
    "custom-power": { "format": "", "on-click": "wlogout --protocol layer-shell" }
}
EOF
cat << 'EOF' > $CONFIG_DIR/waybar/style.css
* { border: none; border-radius: 0; font-family: JetBrainsMono Nerd Font, FontAwesome; font-size: 14px; min-height: 0; }
window#waybar { background: rgba(26, 27, 38, 0.8); color: #cdd6f4; border-bottom: 2px solid rgba(49, 50, 68, 0.9); }
#workspaces button { padding: 0 10px; background: transparent; color: #a6adc8; border-radius: 10px; }
#workspaces button.active { color: #cba6f7; background: #45475a; }
#workspaces button.urgent { color: #f38ba8; }
#window, #clock, #battery, #pulseaudio, #network, #cpu, #memory, #tray, #custom-power { padding: 0 10px; margin: 5px 3px; color: #cdd6f4; background-color: #313244; border-radius: 8px; }
#clock { color: #fab387; }
#battery.charging, #battery.plugged { color: #a6e3a1; }
#battery.critical:not(.charging) { color: #f38ba8; animation-name: blink; animation-duration: 0.5s; animation-timing-function: linear; animation-iteration-count: infinite; animation-direction: alternate; }
#pulseaudio { color: #89b4fa; }
#network { color: #a6e3a1; }
#cpu { color: #f9e2af; }
#memory { color: #f5c2e7; }
#custom-power { color: #f38ba8; margin-right: 6px; }
@keyframes blink { to { background-color: #f38ba8; color: #1e1e2e; } }
EOF

# --- WLOGOUT (Power Menu) CONFIGURATION ---
echo "--- Deploying wlogout (Power Menu) Configuration ---"
cat << 'EOF' > $CONFIG_DIR/wlogout/layout
{
  "label" : "shutdown", "action" : "systemctl poweroff"
}
{
  "label" : "reboot", "action" : "systemctl reboot"
}
{
  "label" : "lock", "action" : "swaylock -f -c 000000"
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
#lock { margin: 10px; }
#logout { margin: 10px; }
#reboot { margin: 10px; }
#shutdown { margin: 10px; }
EOF

# --- WOFI (Launcher) CONFIGURATION ---
echo "--- Deploying Wofi (Launcher) Configuration ---"
cat << 'EOF' > $CONFIG_DIR/wofi/style.css
window { border: 2px solid #cba6f7; border-radius: 15px; background-color: rgba(30, 30, 46, 0.85); font-family: JetBrainsMono Nerd Font; }
#input { margin: 10px; border: none; border-bottom: 2px solid #585b70; color: #cdd6f4; background-color: #1e1e2e; padding: 5px; border-radius: 5px; }
#inner-box { margin: 5px; }
#outer-box { margin: 20px; }
#scroll { margin-top: 5px; }
#text { padding: 5px; color: #bac2de; }
#entry:selected { background-color: #cba6f7; color: #1e1e2e; border-radius: 5px; }
EOF

# --- SWAYNC (Notification Center) CONFIGURATION ---
echo "--- Deploying SwayNC (Notification Center) Configuration ---"
cp /etc/swaync/config.json $CONFIG_DIR/swaync/
sed -i -e 's/"positionX": "right"/"positionX": "right"/' -e 's/"positionY": "top"/"positionY": "top"/' $CONFIG_DIR/swaync/config.json

# --- WALLPAPER ---
echo "--- Fetching a more suitable 'hacker' wallpaper... ---"
curl -s -L -o $CONFIG_DIR/hypr/wallpaper.jpg "https://images.unsplash.com/photo-1550745165-9bc0b252726a?q=80&w=1920&auto=format&fit=crop"

# --- FINAL VERIFICATION & MESSAGE ---
echo ""
echo "--- Verifying installation... ---"
for pkg in hyprland waybar kitty wofi wlogout; do
    if ! command -v $pkg &> /dev/null; then
        echo "ERROR: Command '$pkg' not found after installation. Something went wrong."
        exit 1
    fi
done
echo "--- Verification successful. All key components are installed. ---"

echo ""
echo "=================================================================="
echo "      🚀 HYPER-CUSTOMIZATION v3 COMPLETE 🚀"
echo "=================================================================="
echo ""
echo "What's done:"
echo "  - Package lists have been corrected (Official Repos vs AUR)."
echo "  - All packages should now install correctly."
echo "  - A verification step was added to ensure success."
echo ""
echo "Important Keybindings:"
echo "  - SUPER + RETURN: Open Kitty Terminal"
echo "  - SUPER + D:      Open Wofi Application Launcher"
echo "  - SUPER + X:      Open Power Menu (Logout, Shutdown, etc.)"
echo "  - SUPER + Q:      Close active window"
echo "  - SUPER + L:      Lock screen"
echo ""
echo "To finish setup:"
echo "  1. Log out and log back in to a Hyprland session."
echo "  2. Your system should now look and feel amazing."
echo ""
echo "Third time's the charm! This should resolve all the errors."
echo ""

�
