#!/usr/bin/env zsh

# change max mouse speed
defaults write -g com.apple.mouse.scaling 5.0

# set to solid black
osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/System/Library/Desktop Pictures/Solid Colors/Black.png"'
