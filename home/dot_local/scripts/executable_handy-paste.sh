#!/usr/bin/env zsh

# Handy passes transcribed text either as first argument or via stdin.
# WezTerm runs as XWayland (enable_wayland=false required for Hyprland), so we
# need different paste strategies per window type:
#   XWayland (WezTerm): xclip + xdotool ctrl+shift+v
#   Native Wayland (Firefox etc): wl-copy + wtype ctrl+v
#
# Both clipboard tools are setsid'd to detach from Handy's FDs — otherwise they
# block Handy's event loop and prevent subsequent PTT calls.
# Paste key is sent in a background subshell so the script returns immediately,
# letting Handy dismiss the "transcribing" overlay before the key fires.
text="${1:-$(cat)}"

sig=$(ls /run/user/1000/hypr/ 2>/dev/null | head -1)
xwayland=$(HYPRLAND_INSTANCE_SIGNATURE=$sig hyprctl activewindow -j 2>/dev/null | grep -o '"xwayland": true')

if [[ -n "$xwayland" ]]; then
    pkill xclip 2>/dev/null
    printf '%s' "$text" | setsid xclip -selection clipboard -loops 1 >/dev/null 2>&1 &
    ( sleep 0.5; xdotool key --clearmodifiers ctrl+shift+v ) &
else
    pkill wl-copy 2>/dev/null
    printf '%s' "$text" | setsid wl-copy >/dev/null 2>&1 &
    ( sleep 0.5; wtype -M ctrl -k v -m ctrl ) &
fi
