#!/usr/bin/env bash

sudo pacman -S --needed --noconfirm zsh
chsh -s /usr/bin/zsh

xdg-mime default org.wezfurlong.wezterm.desktop x-scheme-handler/terminal
