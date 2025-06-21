#!/bin/bash

set -e

# === CONFIG ===
WALLPAPER_PATH="$HOME/wallpapers/hacker.jpg"

echo "==> Installing dependencies..."

yay -S --needed --noconfirm \
  hyprland kitty waybar wofi hyprpaper \
  polkit-kde-agent pipewire wireplumber \
  grim slurp swappy cliphist wl-clipboard \
  rofi rofi-emoji playerctl brightnessctl \
  xdg-desktop-portal-hyprland pamixer fastfetch \
  starship cava ttf-hack-nerd thunar nm-connection-editor

echo "==> Creating directories..."
mkdir -p ~/.config/hypr/scripts
mkdir -p ~/.config/waybar
mkdir -p ~/wallpapers

echo "==> Creating placeholder wallpaper..."
curl -L https://i.imgur.com/1YQ9Z5F.jpeg -o "$WALLPAPER_PATH"

echo "==> Setting up Hyprland config..."
cat > ~/.config/hypr/hyprland.conf <<'EOF'
# Hyprland config (Hacker/Programming vibe)

monitor=,preferred,auto,1

exec-once = hyprpaper &
exec-once = waybar &
exec-once = nm-applet &
exec-once = polkit-kde-authentication-agent-1 &
exec-once = wl-paste --watch cliphist store &
exec-once = kitty &

input {
  kb_layout = us
  follow_mouse = 1
  touchpad {
    natural_scroll = yes
  }
}

general {
  gaps_in = 8
  gaps_out = 20
  border_size = 3
  col.active_border = rgba(33ccffee) rgba(8811ffaa) 45deg
  col.inactive_border = rgba(111111aa)
  layout = dwindle
  no_cursor_warps = false
}

decoration {
  rounding = 10
  blur = yes
  blur_size = 8
  blur_passes = 3
  drop_shadow = yes
  shadow_range = 10
  shadow_render_power = 3
  col.shadow = rgba(00000099)
}

animations {
  enabled = yes
  animation = windows, 1, 7, default
  animation = fade, 1, 6, default
  animation = workspaces, 1, 6, slide
  bezier = myBezier, 0.25, 1, 0.5, 1
  animation = windowsOut, 1, 7, myBezier
}

misc {
  disable_hyprland_logo = true
  mouse_move_enables_dpms = true
}

env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORM,wayland;xcb
env = MOZ_ENABLE_WAYLAND,1

exec-once = ~/.config/hypr/scripts/wallpaper.sh

bind = SUPER, RETURN, exec, kitty
bind = SUPER SHIFT, RETURN, exec, kitty --class floatterm -o 'window.opacity=0.95'
bind = SUPER, D, exec, wofi --show drun
bind = SUPER, E, exec, thunar
bind = SUPER, B, exec, firefox
bind = SUPER, V, togglefloating,
bind = SUPER, F, fullscreen
bind = SUPER, Q, killactive,
bind = SUPER, SPACE, exec, rofi -modi emoji -show emoji
bind = SUPER, P, exec, grim -g "$(slurp)" - | swappy -f -

bind = , XF86AudioRaiseVolume, exec, pamixer -i 5
bind = , XF86AudioLowerVolume, exec, pamixer -d 5
bind = , XF86AudioMute, exec, pamixer -t
bind = , XF86AudioPlay, exec, playerctl play-pause

bind = , XF86MonBrightnessUp, exec, brightnessctl s +10%
bind = , XF86MonBrightnessDown, exec, brightnessctl s 10%-

bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER, 3, workspace, 3
bind = SUPER, 4, workspace, 4
bind = SUPER, 5, workspace, 5
bind = SUPER SHIFT, 1, movetoworkspace, 1
bind = SUPER SHIFT, 2, movetoworkspace, 2
bind = SUPER SHIFT, 3, movetoworkspace, 3
bind = SUPER SHIFT, 4, movetoworkspace, 4

bind = SUPER, left, movefocus, l
bind = SUPER, right, movefocus, r
bind = SUPER, up, movefocus, u
bind = SUPER, down, movefocus, d

bind = SUPER CTRL, right, resizeactive, 20 0
bind = SUPER CTRL, left, resizeactive, -20 0
bind = SUPER CTRL, up, resizeactive, 0 -20
bind = SUPER CTRL, down, resizeactive, 0 20
bind = SUPER SHIFT, left, movewindow, l
bind = SUPER SHIFT, right, movewindow, r
bind = SUPER SHIFT, up, movewindow, u
bind = SUPER SHIFT, down, movewindow, d

bind = SUPER SHIFT, S, exec, grim -g "$(slurp)" - | wl-copy
bind = SUPER, R, exec, hyprctl reload
EOF

echo "==> Adding wallpaper script..."
cat > ~/.config/hypr/scripts/wallpaper.sh <<EOF
#!/bin/bash
hyprpaper &
swaybg -i "$WALLPAPER_PATH" -m fill
EOF

chmod +x ~/.config/hypr/scripts/wallpaper.sh

echo "==> Setup complete. Reboot, log in to TTY1, and Hyprland will auto-start if configured."
echo "Or run: Hyprland"
