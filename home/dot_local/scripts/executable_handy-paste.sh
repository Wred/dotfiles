#!/usr/bin/env zsh

# Handy passes transcribed text either as first argument or via stdin.
# Detach wl-copy from Handy's FDs to avoid blocking its event loop.
text="${1:-$(cat)}"

pkill wl-copy 2>/dev/null
printf '%s' "$text" | setsid wl-copy >/dev/null 2>&1 &
( sleep 0.5; wtype -M ctrl -k v -m ctrl ) &
