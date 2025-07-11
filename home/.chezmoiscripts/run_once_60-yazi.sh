#!/usr/bin/env zsh
set -eufo pipefail

# install themes for yazi
if [ -d "$(HOME)/.config/yazi/flavors/catppuccin-latte.yazi" ]; then
	ya pack -a yazi-rs/flavors:catppuccin-mocha
	ya pack -a yazi-rs/flavors:catppuccin-latte
fi
