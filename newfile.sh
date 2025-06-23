#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Script Configuration ---
# You can change the username if you are running this as a different user
USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
CONFIG_DIR="$USER_HOME/.config"
WALLPAPER_DIR="$USER_HOME/Pictures/Wallpapers"
ROFI_SCRIPTS_DIR="$CONFIG_DIR/rofi/scripts"

# --- Functions ---

# Function to print messages
msg() {
    echo -e "\n\e[1;32m[INFO]\e[0m $1"
}

# Function to backup existing files
backup_file() {
    if [ -e "$1" ]; then
        msg "Backing up existing $1 to $1.bak"
        mv "$1" "$1.bak"
    fi
}

# --- Check for Sudo ---
if [ "$EUID" -ne 0 ]; then
    msg "This script needs to be run with sudo."
    exit 1
fi

# --- START ---
msg "Starting the Ultimate Hyprland Environment Setup..."
msg "This script will install and configure your desktop."

# --- 1. System Update ---
msg "Updating system packages..."
pacman -Syu --noconfirm

# --- 2. Install Packages ---
msg "Installing core packages and dependencies..."
PACKAGES=(
    # --- Hyprland Ecosystem ---
    hyprland waybar hyprlock hypridle swww
    
    # --- UI & Utilities ---
    kitty thunar rofi swaync wlogout polkit-kde-agent
    
    # --- Shell & Tools ---
    bash lazygit fzf exa bat
    
    # --- Screenshotting ---
    grim slurp swappy
    
    # --- System & Backend ---
    pipewire wireplumber xdg-desktop-portal-hyprland qt5-wayland qt6-wayland
    
    # --- Fonts ---
    ttf-jetbrains-mono-nerd noto-fonts-emoji
    
    # --- Dependencies for Keybinds ---
    cliphist qalculate-gtk mpv yt-dlp playerctl
    
    # --- Build tools for AUR ---
    git base-devel
)

pacman -S --needed --noconfirm "${PACKAGES[@]}"

# --- 3. Create Configuration Directories ---
msg "Creating configuration directories..."
mkdir -p "$CONFIG_DIR"/{hypr,waybar,rofi,kitty,swaync,wlogout,fastfetch}
mkdir -p "$WALLPAPER_DIR"
mkdir -p "$ROFI_SCRIPTS_DIR"
chown -R "$SUDO_USER":"$SUDO_USER" "$USER_HOME"

# --- 4. Install RofiBeats ---
msg "Installing RofiBeats..."
if [ ! -d "$USER_HOME/Tools/RofiBeats" ]; then
    git clone https://github.com/g-p-g/RofiBeats.git "$USER_HOME/Tools/RofiBeats"
    chown -R "$SUDO_USER":"$SUDO_USER" "$USER_HOME/Tools"
else
    msg "RofiBeats directory already exists. Skipping clone."
fi


# --- 5. Download a Default Wallpaper ---
msg "Downloading a default wallpaper..."
curl -o "$WALLPAPER_DIR/default.jpg" https://images.unsplash.com/photo-1536329583941-14287ec6fc4e

# --- 6. Configuration File Setup ---

# --- Hyprland Config ---
msg "Configuring Hyprland (hyprland.conf)..."
backup_file "$CONFIG_DIR/hypr/hyprland.conf"
cat <<'EOF' > "$CONFIG_DIR/hypr/hyprland.conf"
# See https://wiki.hyprland.org/Configuring/Monitors/
monitor=,preferred,auto,1

# See https://wiki.hyprland.org/Configuring/Keywords/ for more

# Execute your favorite apps at launch
exec-once = waybar &
exec-once = swaync &
exec-once = hypridle &
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = cliphist wipe && wl-paste --watch cliphist store
exec-once = swww init && swww img ~/Pictures/Wallpapers/default.jpg --transition-type any

# Source a file (multi-file configs)
# source = ~/.config/hypr/myColors.conf

# Set programs that you use
$terminal = kitty
$fileManager = thunar
$menu = rofi -show drun
$web_search = ~/.config/rofi/scripts/rofi-google-search
$clipboard = ~/.config/rofi/scripts/rofi-clipboard
$emoji_menu = ~/.config/rofi/scripts/rofi-emoji
$calc_menu = rofi -show calc -modi calc -no-show-match -no-sort
$music_menu = ~/Tools/RofiBeats/RofiBeats.sh
$wallpaper_menu = ~/.config/rofi/scripts/rofi-wallpaper
$keybind_viewer = ~/.config/rofi/scripts/rofi-keybind-viewer

# Some default env vars.
env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORMTHEME,qt5ct # change to qt6ct if you have that

# For all categories, see https://wiki.hyprland.org/Configuring/Variables/
input {
    kb_layout = us
    kb_variant =
    kb_model =
    kb_options = grp:alt_shift_toggle
    kb_rules =

    follow_mouse = 1

    touchpad {
        natural_scroll = no
    }

    sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
}

general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)

    layout = dwindle

    allow_tearing = false
}

decoration {
    rounding = 10
    
    blur {
        enabled = true
        size = 3
        passes = 1
    }

    drop_shadow = yes
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

animations {
    enabled = yes

    bezier = myBezier, 0.05, 0.9, 0.1, 1.05

    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

dwindle {
    pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
    preserve_split = yes # you probably want this
}

master {
    new_is_master = true
}

gestures {
    workspace_swipe = off
}

misc {
    force_default_wallpaper = 0 # Set to 0 to disable the anime mascot wallpapers
}

# Example windowrule v1
# windowrule = float, ^(kitty)$
# Example windowrule v2
# windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
# See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
windowrulev2 = float,class:^(thunar)$,title:^(File Operation Progress)$
windowrulev2 = float,class:^(org.kde.polkit-kde-authentication-agent-1)$

# See https://wiki.hyprland.org/Configuring/Binds/ for more
$mainMod = SUPER

# --- Core Keybinds ---
bind = $mainMod, RETURN, exec, $terminal
bind = $mainMod, Q, killactive, 
bind = $mainMod SHIFT, Q, exit, 
bind = $mainMod, E, exec, $fileManager
bind = $mainMod, D, exec, $menu
bind = $mainMod, SPACE, togglefloating, 
bind = $mainMod SHIFT, F, fullscreen, 
bind = CTRL ALT, L, exec, hyprlock

# --- Application & Rofi Script Keybinds ---
bind = $mainMod, S, exec, $web_search
bind = $mainMod ALT, V, exec, $clipboard
bind = $mainMod ALT, E, exec, $emoji_menu
bind = $mainMod ALT, C, exec, $calc_menu
bind = $mainMod SHIFT, M, exec, $music_menu
bind = $mainMod, W, exec, $wallpaper_menu
# bind = $mainMod SHIFT, O, exec, ... # ZSH specific keybind removed as requested
bind = $mainMod SHIFT, K, exec, $keybind_viewer

# --- Window & Workspace Management ---
# Move focus with mainMod + arrow keys
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Switch workspaces with mainMod + [0-9]
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

# Move active window to a workspace with mainMod + SHIFT + [0-9]
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

# Scroll through existing workspaces with mainMod + scroll
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Dwindle layout specific
bind = $mainMod SHIFT, I, togglesplit, # dwindle

# --- Screenshot Keybinds ---
bind = , Print, exec, grim - | swappy -f - # Whole screen to swappy
bind = $mainMod, Print, exec, grim -g "$(slurp)" - | swappy -f - # Region to swappy
bind = SHIFT, Print, exec, grim -g "$(slurp)" - | wl-copy # Region to clipboard

# --- UI Toggles ---
bind = $mainMod ALT, O, toggleblur,
bind = $mainMod SHIFT, G, exec, hyprctl keyword animation "enabled, no" && hyprctl keyword decoration:drop_shadow no # Gamemode off
bind = $mainMod ALT, G, exec, hyprctl keyword animation "enabled, yes" && hyprctl keyword decoration:drop_shadow yes # Gamemode on

# --- Logout Menu ---
bind = CTRL ALT, P, exec, wlogout -p layer-shell

EOF

# --- hyprlock Config ---
msg "Configuring Hyprlock..."
backup_file "$CONFIG_DIR/hypr/hyprlock.conf"
cat <<'EOF' > "$CONFIG_DIR/hypr/hyprlock.conf"
background {
    path = ~/Pictures/Wallpapers/default.jpg
    blur_passes = 3
    blur_size = 8
}

input-field {
    monitor =
    size = 250, 60
    outline_thickness = 2
    dots_size = 0.2 # Scale of dots relative to font size
    dots_spacing = 0.2 # Scale of dots relative to font size
    dots_center = true
    fade_on_empty = false
    font_color = rgb(200, 200, 200)
    inner_color = rgb(50, 50, 50)
    outer_color = rgb(20, 20, 20)
    rounding = -1 # -1 means full rounding
    placeholder_text = <i>Password...</i>
    hide_input = false
}

label {
    monitor =
    text = Hi $USER
    color = rgba(255, 255, 255, 0.9)
    font_size = 25
    font_family = JetBrains Mono Nerd Font
    position = 0, 80
    halign = center
    valign = center
}

label {
    monitor =
    text = $TIME
    color = rgba(255, 255, 255, 0.9)
    font_size = 90
    font_family = JetBrains Mono Nerd Font
    position = 0, -100
    halign = center
    valign = center
}
EOF

# --- hypridle Config ---
msg "Configuring Hypridle..."
backup_file "$CONFIG_DIR/hypr/hypridle.conf"
cat <<'EOF' > "$CONFIG_DIR/hypr/hypridle.conf"
general {
    lock_cmd = pidof hyprlock || hyprlock           # lock before suspend
    before_sleep_cmd = loginctl lock-session        # lock before suspend
    after_sleep_cmd = hyprctl dispatch dpms on      # to avoid having to wiggle the mouse to see the lock screen.
}

listener {
    timeout = 300                                   # 5min
    on-timeout = hyprlock                           # lock screen when timeout has passed
}

listener {
    timeout = 330                                   # 5.5min
    on-timeout = hyprctl dispatch dpms off          # screen off
    on-resume = hyprctl dispatch dpms on            # screen on
}

listener {
    timeout = 600                                   # 10min
    on-timeout = systemctl suspend                  # suspend system
}
EOF

# --- Waybar Config ---
msg "Configuring Waybar..."
backup_file "$CONFIG_DIR/waybar/config"
backup_file "$CONFIG_DIR/waybar/style.css"

cat <<'EOF' > "$CONFIG_DIR/waybar/config"
{
    "layer": "top",
    "position": "top",
    "height": 38,
    "modules-left": ["hyprland/workspaces", "hyprland/window"],
    "modules-center": ["clock"],
    "modules-right": ["tray", "pulseaudio", "network", "cpu", "memory", "hyprland/language", "custom/power"],

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
            "default": ""
        }
    },
    "hyprland/window": {
        "format": " {}"
    },
    "clock": {
        "format": " {:%I:%M %p   %a, %b %d}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
    },
    "tray": {
        "icon-size": 20,
        "spacing": 10
    },
    "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-muted": " Muted",
        "on-click": "pavucontrol",
        "format-icons": {
            "headphone": "🎧",
            "hands-free": "🎧",
            "headset": "🎧",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["", "", ""]
        }
    },
    "network": {
        "format-wifi": "  {essid}",
        "format-ethernet": "󰈀 {ifname}",
        "format-disconnected": "󰖪 Disconnected",
        "on-click": "nm-connection-editor"
    },
    "cpu": {
        "format": "  {usage}%"
    },
    "memory": {
        "format": " {}%"
    },
    "hyprland/language": {
        "format": " {}"
    },
    "custom/power": {
        "format": "",
        "on-click": "wlogout -p layer-shell",
        "tooltip": false
    }
}
EOF

cat <<'EOF' > "$CONFIG_DIR/waybar/style.css"
* {
    border: none;
    border-radius: 0;
    font-family: JetBrains Mono Nerd Font;
    font-size: 16px;
    min-height: 0;
}

window#waybar {
    background-color: rgba(26, 27, 38, 0.8);
    color: #cdd6f4;
    transition-property: background-color;
    transition-duration: .5s;
}

#workspaces button {
    padding: 0 10px;
    background-color: transparent;
    color: #a6adc8;
}

#workspaces button.active {
    color: #89b4fa;
}

#workspaces button:hover {
    background: rgba(0, 0, 0, 0.2);
}

#workspaces button.urgent {
    color: #f38ba8;
}

#clock,
#pulseaudio,
#network,
#cpu,
#memory,
#language,
#custom-power {
    padding: 0 10px;
    color: #cdd6f4;
}

#window, #tray {
    padding: 0 10px;
}
EOF

# --- Rofi Config & Scripts ---
msg "Configuring Rofi and helper scripts..."
cat <<'EOF' > "$CONFIG_DIR/rofi/config.rasi"
@theme "/usr/share/rofi/themes/gruvbox-dark-hard.rasi"
configuration {
    modi: "drun,run,calc,window";
    show-icons: true;
    font: "JetBrains Mono Nerd Font 12";
}
EOF

cat <<'EOF' > "$ROFI_SCRIPTS_DIR/rofi-google-search"
#!/bin/bash
QUERY=$(rofi -dmenu -p "Search Google")
if [ -n "$QUERY" ]; then
    xdg-open "https://www.google.com/search?q=$QUERY"
fi
EOF

cat <<'EOF' > "$ROFI_SCRIPTS_DIR/rofi-clipboard"
#!/bin/bash
cliphist list | rofi -dmenu -p "Clipboard" | cliphist decode | wl-copy
EOF

cat <<'EOF' > "$ROFI_SCRIPTS_DIR/rofi-emoji"
#!/bin/bash
rofimoji --action copy
EOF

cat <<'EOF' > "$ROFI_SCRIPTS_DIR/rofi-wallpaper"
#!/bin/bash
WALL_DIR=~/Pictures/Wallpapers
cd "$WALL_DIR"
SELECTED=$(ls | rofi -dmenu -p "Select Wallpaper")
if [ -n "$SELECTED" ]; then
    swww img "$WALL_DIR/$SELECTED" --transition-type any
fi
EOF

cat <<'EOF' > "$ROFI_SCRIPTS_DIR/rofi-keybind-viewer"
#!/bin/bash
# A simple script to show keybinds from hyprland.conf in rofi
CONFIG_FILE=~/.config/hypr/hyprland.conf
(
    echo "SUPER + RETURN  -> Terminal"
    echo "SUPER + Q       -> Close Active Window"
    echo "SUPER + D       -> Application Launcher"
    echo "SUPER + E       -> File Manager"
    echo "SUPER + SPACE   -> Toggle Float"
    echo "SUPER + S       -> Google Search"
    echo "SUPER + W       -> Change Wallpaper"
    echo "SUPER + SHIFT+F -> Toggle Fullscreen"
    echo "SUPER + ALT+V   -> Clipboard History"
    echo "CTRL + ALT + P  -> Logout Menu"
    echo "PrintScreen     -> Screenshot (Region)"
) | rofi -dmenu -i -p "Keybindings"
EOF

# Make scripts executable
chmod +x "$ROFI_SCRIPTS_DIR"/*

# --- Kitty Terminal Config ---
msg "Configuring Kitty..."
backup_file "$CONFIG_DIR/kitty/kitty.conf"
cat <<'EOF' > "$CONFIG_DIR/kitty/kitty.conf"
font_family      JetBrains Mono Nerd Font
bold_font        auto
italic_font      auto
bold_italic_font auto

font_size 11.0

background_opacity 0.85

# BEGIN_KITTY_THEME
# Catppuccin-Mocha
include current-theme.conf
# END_KITTY_THEME
EOF
# Add Catppuccin theme for kitty
cat <<'EOF' > "$CONFIG_DIR/kitty/current-theme.conf"
foreground            #CDD6F4
background            #1E1E2E
selection_foreground  #1E1E2E
selection_background  #F5E0DC

cursor                #F5E0DC
cursor_text_color     #1E1E2E

url_color             #F5E0DC

active_border_color   #B4BEFE
inactive_border_color #45475A
bell_border_color     #F9E2AF

active_tab_foreground   #11111B
active_tab_background   #CBA6F7
inactive_tab_foreground #CDD6F4
inactive_tab_background #181825
tab_bar_background      #11111B

mark1_foreground #1E1E2E
mark1_background #B4BEFE

mark2_foreground #1E1E2E
mark2_background #CBA6F7

mark3_foreground #1E1E2E
mark3_background #74C7EC


# black
color0 #45475A
color8 #585B70

# red
color1 #F38BA8
color9 #F38BA8

# green
color2  #A6E3A1
color10 #A6E3A1

# yellow
color3  #F9E2AF
color11 #F9E2AF

# blue
color4  #89B4FA
color12 #89B4FA

# magenta
color5  #F5C2E7
color13 #F5C2E7

# cyan
color6  #94E2D5
color14 #94E2D5

# white
color7  #BAC2DE
color15 #A6ADC8
EOF

# --- wlogout Config ---
msg "Configuring wlogout..."
backup_file "$CONFIG_DIR/wlogout/layout"
cat <<'EOF' > "$CONFIG_DIR/wlogout/layout"
{
  "label" : "shutdown",
  "action" : "systemctl poweroff",
  "text" : "Shutdown",
  "keybind" : "s"
},
{
  "label" : "reboot",
  "action" : "systemctl reboot",
  "text" : "Reboot",
  "keybind" : "r"
},
{
  "label" : "suspend",
  "action" : "systemctl suspend",
  "text" : "Suspend",
  "keybind" : "u"
},
{
  "label" : "logout",
  "action" : "hyprctl dispatch exit",
  "text" : "Logout",
  "keybind" : "l"
},
{
  "label" : "lock",
  "action" : "hyprlock",
  "text" : "Lock",
  "keybind" : "k"
}
EOF

# --- Set ownership of all created files ---
chown -R "$SUDO_USER":"$SUDO_USER" "$CONFIG_DIR"
chown -R "$SUDO_USER":"$SUDO_USER" "$WALLPAPER_DIR"

# --- Final Message ---
msg "-----------------------------------------------------"
msg "Setup Complete!"
msg "Please REBOOT your system now."
msg "At the login screen, choose the 'Hyprland' session."
msg "-----------------------------------------------------"
