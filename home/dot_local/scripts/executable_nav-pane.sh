#!/usr/bin/env bash
# nav-pane.sh -- unified directional navigation across vim/tmux/hyprland
# Usage: nav-pane.sh left|down|up|right
#
# Two entry points:
#   From tmux or neovim (Alt+hjkl) — $TMUX is set, handles edge detection
#   From Hyprland (Super+hjkl) — no $TMUX, checks if terminal and forwards Alt+hjkl

direction="$1"

# hyprctl needs HYPRLAND_INSTANCE_SIGNATURE; tmux may have a missing or stale value
if ! hyprctl monitors >/dev/null 2>&1; then
  for _sig in $(ls /run/user/$(id -u)/hypr/ 2>/dev/null); do
    if HYPRLAND_INSTANCE_SIGNATURE="$_sig" hyprctl monitors >/dev/null 2>&1; then
      export HYPRLAND_INSTANCE_SIGNATURE="$_sig"
      break
    fi
  done
fi

case "$direction" in
  left)  tmux_flag="-L"; at_edge="#{pane_at_left}"  ; hypr_dir="l"; alt_key="h" ;;
  down)  tmux_flag="-D"; at_edge="#{pane_at_bottom}"; hypr_dir="d"; alt_key="j" ;;
  up)    tmux_flag="-U"; at_edge="#{pane_at_top}"   ; hypr_dir="u"; alt_key="k" ;;
  right) tmux_flag="-R"; at_edge="#{pane_at_right}" ; hypr_dir="r"; alt_key="l" ;;
  *)     exit 1 ;;
esac

if [ -n "$TMUX" ]; then
  # If the pane is running SSH, forward the key so the remote tmux can handle it
  pane_tty=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}')
  if ps -o comm= -t "$pane_tty" 2>/dev/null | grep -iqE '^ssh$'; then
    tmux send-keys -t "$TMUX_PANE" "M-$alt_key"
    exit 0
  fi

  at_edge_val=$(tmux display-message -p "$at_edge")
  if [ "$at_edge_val" = "1" ]; then
    hyprctl dispatch movefocus "$hypr_dir" >/dev/null 2>&1
  else
    tmux select-pane "$tmux_flag"
  fi
else
  # Called from Hyprland — check if focused window is a terminal
  active_class=$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty')
  if [[ "$active_class" == *"wezterm"* ]] || [[ "$active_class" == *"foot"* ]] || [[ "$active_class" == *"kitty"* ]]; then
    # Terminal — send Alt+key so tmux handles the full chain
    hyprctl dispatch sendshortcut "ALT, $alt_key, activewindow" >/dev/null 2>&1
  else
    hyprctl dispatch movefocus "$hypr_dir" >/dev/null 2>&1
  fi
fi

exit 0
