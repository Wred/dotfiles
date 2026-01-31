#!/usr/bin/env zsh

# install themes for yazi
if [ -d "${HOME}/.config/yazi/flavors" ]; then
	if [ ! -e "${HOME}/.config/yazi/flavors/catppuccin-latte.yazi" ]; then
		ya pkg add yazi-rs/flavors:catppuccin-mocha
		ya pkg add yazi-rs/flavors:catppuccin-latte
	fi
fi
