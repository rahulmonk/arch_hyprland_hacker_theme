#!/bin/bash

# ██╗  ██╗██╗   ██╗██████╗ ██████╗  ██████╗ ██╗  ██╗███████╗██████╗     ██████╗  ██████╗ ██╗     ███████╗
# ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██╔═══██╗██║  ██║██╔════╝██╔══██╗   ██╔════╝ ██╔═══██╗██║     ██╔════╝
# ███████║ ╚████╔╝ ██████╔╝██████╔╝██║   ██║███████║█████╗  ██████╔╝   ██║  ███╗██║   ██║██║     █████╗
# ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║   ██║██╔══██║██╔══╝  ██╔══██╗   ██║   ██║██║   ██║██║     ██╔══╝
# ██║  ██║   ██║   ██║     ██║  ██║╚██████╔╝██║  ██║███████╗██║  ██║██╗╚██████╔╝╚██████╔╝███████╗███████╗
# ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚══════╝
#
#               A R C H    L I N U X    +    H Y P R L A N D    E X P E R I E N C E
#
#       Crafted by a veteran Arch developer for maximum style, efficiency, and "wow" factor.
#       This script installs and configures a complete, animation-heavy Hyprland desktop.
#
#       WARNING: This script will overwrite existing Hyprland, Kitty, Waybar, etc. configs.
#                Backup your ~/.config files before proceeding if you have existing setups.
#

# --- PREP & SAFETY CHECK ---
echo "=================================================================="
echo "ARCH + HYPRLAND HYPER-CUSTOMIZATION SCRIPT"
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

# --- PACKAGE INSTALLATION ---
echo "--- Installing Core Hyprland Components & Dependencies ---"
$INSTALL_CMD hyprland kitty waybar wofi swaync swaybg swayidle swaylock-effects ttf-jetbrains-mono-nerd noto-fonts-emoji polkit-kde-agent dunst grim slurp pamixer brightnessctl playerctl gvfs thunar

echo "--- Installing Styling & Theming Tools ---"
$INSTALL_CMD qt5-wayland qt6-wayland xdg-desktop-portal-hyprland nwg-look-bin kvantum

echo "--- Installing Super-Productivity Tools ---"
$INSTALL_CMD zsh tmux neovim ranger zathura zathura-pdf-mupdf bat eza fzf ripgrep lazygit

echo "--- Installing Fonts & Icons for that Hacker Look ---"
$AUR_CMD ttf-font-awesome papirus-icon-theme

# --- CONFIGURATION DIRECTORY SETUP ---
echo "--- Setting up configuration directories... ---"
CONFIG_DIR="$HOME/.config"
mkdir -p $CONFIG_DIR/{hypr,kitty,waybar,swaync,wofi,cava}

# --- ZSH & OH-MY-ZSH SETUP (for a better shell experience) ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "--- Installing Oh My Zsh for a superior terminal experience ---"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    # Set Zsh as default shell
    chsh -s $(which zsh)
else
    echo "--- Oh My Zsh already installed, skipping. ---"
fi


# --- HYPRLAND CONFIGURATION ---
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
# │    >> Arch-Veteran Hyprland Config | Unleash the Beast <<   │
# ╰───────────────────────────────────────────────────────────╯

# -----------------------------------------------------
# MONITORS & ENVIRONMENT
# -----------------------------------------------------
monitor=,preferred,auto,auto
env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORMTHEME,qt5ct # Env vars for theming

# -----------------------------------------------------
# AUTOSTART - Daemons and essential background services
# -----------------------------------------------------
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = swaybg -i ~/.config/hypr/wallpaper.png -m fill # Set your wallpaper here
exec-once = waybar &
exec-once = swaync &
exec-once = swayidle -w timeout 300 'swaylock -f' timeout 600 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on'

# -----------------------------------------------------
# INPUT - Keyboard, Mouse, Touchpad
# -----------------------------------------------------
input {
    kb_layout = us
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =

    follow_mouse = 1
    touchpad {
        natural_scroll = no
    }
    sensitivity = 0 # -1.0 to 1.0, 0 means no modification.
}

# -----------------------------------------------------
# AESTHETICS & ANIMATIONS - The "Wow" Factor
# -----------------------------------------------------
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(cba6f7aa) rgba(89b4faaa) 45deg
    col.inactive_border = rgba(585b70aa)

    layout = dwindle # master | dwindle
    resize_on_border = true
}

decoration {
    rounding = 10
    blur {
        enabled = true
        size = 8
        passes = 3
        new_optimizations = on
        xray = true
    }

    drop_shadow = yes
    shadow_range = 12
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

animations {
    enabled = yes

    # Animation curves - for that buttery smooth feel
    bezier = wind, 0.05, 0.9, 0.1, 1.05
    bezier = winIn, 0.1, 1.1, 0.1, 1.1
    bezier = winOut, 0.3, -0.3, 0, 1
    bezier = liner, 1, 1, 1, 1

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
    new_is_master = true
}

gestures {
    workspace_swipe = on
}

# -----------------------------------------------------
# KEYBINDINGS - Efficiency is King
# -----------------------------------------------------
$mainMod = SUPER # Sets the Super (Windows) key as the main modifier

# --- Application Launchers ---
bind = $mainMod, RETURN, exec, kitty # The one true terminal
bind = $mainMod, D, exec, wofi --show drun # App launcher
bind = $mainMod, E, exec, thunar # File manager

# --- Window Management ---
bind = $mainMod, Q, killactive,
bind = $mainMod, F, fullscreen,
bind = $mainMod, SPACE, togglefloating,
bind = $mainMod, P, pseudo, # dwindle
bind = $mainMod, J, togglesplit, # dwindle

# --- Move focus with mainMod + arrow keys ---
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# --- Switch workspaces with mainMod + [0-9] ---
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

# --- Move active window to a workspace with mainMod + SHIFT + [0-9] ---
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

# --- Scroll through existing workspaces with mainMod + scroll ---
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# --- Move/resize windows with mainMod + LMB/RMB and dragging ---
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# --- System & Utility Controls ---
bind = $mainMod, L, exec, swaylock
bind = , Print, exec, grim -g "$(slurp)" - | wl-copy # Screenshot selection
bind = SHIFT, Print, exec, grim - | wl-copy # Screenshot full screen

# --- Media and Volume Keys (requires pamixer, brightnessctl, playerctl) ---
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
# -----------------------------------------------------
# KITTY - The GPU-accelerated Terminal
# -----------------------------------------------------
font_family JetBrainsMono Nerd Font
bold_font auto
italic_font auto
bold_italic_font auto
font_size 11.0

# Window layout
remember_window_size  no
initial_window_width  900
initial_window_height 600
window_padding_width 15

# Theme (Catppuccin Mocha) & Transparency
background_opacity 0.85
background_blur 50

# BEGIN_KITTY_THEME
# Catppuccin-Mocha
include current-theme.conf
# END_KITTY_THEME
EOF

# Download Catppuccin theme for Kitty
curl -o $CONFIG_DIR/kitty/current-theme.conf https://raw.githubusercontent.com/catppuccin/kitty/main/mocha.conf

# --- WAYBAR CONFIGURATION ---
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
        "format": "{icon}",
        "on-click": "activate",
        "format-icons": {
            "1": "",
            "2": "",
            "3": "",
            "4": "",
            "5": "",
            "urgent": "",
            "focused": "",
            "default": ""
        }
    },
    "hyprland/window": {
        "format": "{} - ",
        "max-length": 50
    },
    "clock": {
        "format": "{:%a %d %b  %H:%M}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
    },
    "cpu": {
        "format": " {usage}%",
        "tooltip": true
    },
    "memory": {
        "format": " {}%"
    },
    "network": {
        "format-wifi": "  {essid}",
        "format-ethernet": "󰈀 {ifname}",
        "format-disconnected": "󰖪 Disconnected",
        "tooltip-format": "{ifname} via {gwaddr} ",
        "on-click": "nm-connection-editor"
    },
    "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-muted": " Muted",
        "format-icons": {
            "headphone": "",
            "hands-free": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["", ""]
        },
        "on-click": "pavucontrol"
    },
    "battery": {
        "states": {
            "good": 95,
            "warning": 30,
            "critical": 15
        },
        "format": "{icon} {capacity}%",
        "format-charging": " {capacity}%",
        "format-plugged": " {capacity}%",
        "format-alt": "{icon} {time}",
        "format-icons": ["", "", "", "", ""]
    },
    "tray": {
        "icon-size": 18,
        "spacing": 10
    },
    "custom-power": {
      "format": "",
      "on-click": "wofi --show power"
    }
}
EOF

# --- WAYBAR STYLE ---
echo "--- Deploying Waybar Style ---"
cat << 'EOF' > $CONFIG_DIR/waybar/style.css
* {
    border: none;
    border-radius: 0;
    font-family: JetBrainsMono Nerd Font, FontAwesome;
    font-size: 14px;
    min-height: 0;
}

window#waybar {
    background: rgba(26, 27, 38, 0.8);
    color: #cdd6f4; /* Text */
    border-bottom: 2px solid rgba(49, 50, 68, 0.9);
}

#workspaces button {
    padding: 0 10px;
    background: transparent;
    color: #a6adc8; /* Subtext1 */
    border-radius: 10px;
}

#workspaces button.focused {
    color: #cba6f7; /* Mauve */
    background: #45475a; /* Surface2 */
}

#workspaces button.urgent {
    color: #f38ba8; /* Red */
}

#window, #clock, #battery, #pulseaudio, #network, #cpu, #memory, #tray, #custom-power {
    padding: 0 10px;
    margin: 5px 3px;
    color: #cdd6f4;
    background-color: #313244; /* Surface1 */
    border-radius: 8px;
}

#clock {
    color: #fab387; /* Peach */
}

#battery.charging, #battery.plugged {
    color: #a6e3a1; /* Green */
}

#battery.critical:not(.charging) {
    color: #f38ba8; /* Red */
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

#pulseaudio {
    color: #89b4fa; /* Blue */
}

#network {
    color: #a6e3a1; /* Green */
}

#cpu {
    color: #f9e2af; /* Yellow */
}

#memory {
    color: #f5c2e7; /* Pink */
}

#custom-power {
    color: #f38ba8; /* Red */
    margin-right: 6px;
}

@keyframes blink {
    to {
        background-color: #f38ba8;
        color: #1e1e2e;
    }
}
EOF

# --- WOFI (Launcher) CONFIGURATION ---
echo "--- Deploying Wofi (Launcher) Configuration ---"
mkdir -p $CONFIG_DIR/wofi
cat << 'EOF' > $CONFIG_DIR/wofi/config
{
	"show": "drun",
	"prompt": "Launch:",
	"allow_images": true,
	"width": "40%",
	"height": "50%",
	"style": "style.css",
	"halign": "center",
	"valign": "center"
}
EOF

cat << 'EOF' > $CONFIG_DIR/wofi/style.css
/* --- Wofi Style - Hacker Vibes --- */
window {
    margin: 0px;
    border: 2px solid #cba6f7; /* Mauve */
    border-radius: 15px;
    background-color: rgba(30, 30, 46, 0.85);
    font-family: JetBrainsMono Nerd Font;
}

#input {
    margin: 10px;
    border: none;
    border-bottom: 2px solid #585b70; /* Surface0 */
    color: #cdd6f4; /* Text */
    background-color: #1e1e2e; /* Base */
    padding: 5px;
    border-radius: 5px;
}

#inner-box {
    margin: 5px;
    border: none;
    background-color: transparent;
}

#outer-box {
    margin: 20px;
    border: none;
    background-color: transparent;
}

#scroll {
    margin-top: 5px;
    border: none;
}

#text {
    padding: 5px;
    color: #bac2de; /* Subtext0 */
}

#entry:selected {
    background-color: #cba6f7; /* Mauve */
    color: #1e1e2e; /* Base */
    border-radius: 5px;
}
EOF

# --- SWAYNC (Notification Center) CONFIGURATION ---
echo "--- Deploying SwayNC (Notification Center) Configuration ---"
# We will use the default config and just tweak the style for now.
# You can customize it further by editing the files.
cp /etc/swaync/config.json $CONFIG_DIR/swaync/
cp /etc/swaync/style.css $CONFIG_DIR/swaync/

# --- WALLPAPER ---
echo "--- Fetching a suitable wallpaper... ---"
# Using a placeholder image generator for a cool, abstract wallpaper
curl -o $CONFIG_DIR/hypr/wallpaper.png https://placehold.co/1920x1080/1e1e2e/cdd6f4?text=A+R+C+H

# --- FINAL MESSAGE ---
echo ""
echo "=================================================================="
echo "      🚀 HYPER-CUSTOMIZATION COMPLETE 🚀"
echo "=================================================================="
echo ""
echo "What's done:"
echo "  - Hyprland, Waybar, Kitty, Wofi, SwayNC installed and configured."
echo "  - A full suite of productivity tools is ready."
echo "  - Zsh with Oh-My-Zsh is set up."
echo "  - Keybindings are set in ~/.config/hypr/hyprland.conf"
echo ""
echo "Important Keybindings:"
echo "  - SUPER + RETURN: Open Kitty Terminal"
echo "  - SUPER + D:      Open Wofi Application Launcher"
echo "  - SUPER + Q:      Close active window"
echo "  - SUPER + F:      Toggle fullscreen"
echo "  - SUPER + SPACE:  Toggle floating window"
echo "  - SUPER + [1-9]:  Switch workspace"
echo "  - SUPER + SHIFT + [1-9]: Move window to workspace"
echo "  - SUPER + L:      Lock screen"
echo ""
echo "To finish setup:"
echo "  1. Log out and log back in to a Hyprland session."
echo "  2. The default shell is now Zsh. Enjoy!"
echo "  3. Explore and modify the config files in ~/.config to your heart's content."
echo ""
echo "Welcome to the next level of desktop experience."
echo ""

