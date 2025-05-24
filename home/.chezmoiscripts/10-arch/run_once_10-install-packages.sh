#!/usr/bin/env zsh
set -eufo pipefail

packages=(
	gcc
	yay
	bat
	git-lfs
	jq
	units
	terminator
	go
	ripgrep
)

aur=(
	direnv
	visual-studio-code-bin
	spotify
	google-chrome
	slack
)

sudo pacman-mirrors --country Canada && sudo pacman -Syyu
sudo pacman -S --needed --noconfirm ${packages[@]}

yay -Syu
yay -S --needed --noconfirm ${aur[@]}

