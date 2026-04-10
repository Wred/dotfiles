#!/usr/bin/env bash
# Usage: focus-or-open.sh <window-class> <launch-command...>
# Focuses the first window matching the class, or launches the command if none exists.
class=$1
shift

if hyprctl clients -j | jq -e ".[] | select(.class == \"$class\")" > /dev/null 2>&1; then
    hyprctl dispatch focuswindow "class:$class"
else
    exec "$@"
fi
