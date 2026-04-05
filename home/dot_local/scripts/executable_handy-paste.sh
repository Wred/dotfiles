#!/usr/bin/env zsh

# Handy passes transcribed text either as first argument or via stdin
text="${1:-$(cat)}"
printf '%s' "$text" | wtype -
