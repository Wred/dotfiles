#!/usr/bin/env zsh

# Handy passes transcribed text either as first argument or via stdin.
# Uses xclip + xdotool (X11) because WezTerm runs as XWayland (enable_wayland=false).
# - setsid detaches xclip from Handy's FDs so it doesn't block subsequent PTT calls
# - -loops 1 makes xclip exit after one paste
# - sleep 0.5 lets Handy release its keyboard grab before we send ctrl+shift+v
text="${1:-$(cat)}"
pkill xclip 2>/dev/null
printf '%s' "$text" | setsid xclip -selection clipboard -loops 1 >/dev/null 2>&1 &
sleep 0.5
xdotool key --clearmodifiers ctrl+shift+v
