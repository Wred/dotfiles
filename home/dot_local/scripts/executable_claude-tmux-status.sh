#!/bin/bash
# Called by Claude Code hooks to signal active-working state per tmux session.
[ -z "$TMUX" ] && exit 0
session=$(tmux display-message -p '#S' 2>/dev/null) || exit 0
case "$1" in
  set)   tmux set-option -t "$session" @claude_working 1 ;;
  clear) tmux set-option -u -t "$session" @claude_working 2>/dev/null || true ;;
esac
tmux list-clients -F '#{client_name}' | xargs -n1 tmux refresh-client -S -t
