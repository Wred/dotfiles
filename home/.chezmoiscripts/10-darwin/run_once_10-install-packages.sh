#!/usr/bin/env zsh

set -eufo pipefail

formulae=(
	curl
	dockutil
	git-lfs
	gnu-units
	gpg2
	gnupg
	pinentry-mac
	go
	jq
	yq
	pkg-config
	ripgrep
	tmux
	xz
	python3
	pipx
	packer
	bat
	direnv
	watch
	wget
	coreutils
	mike-engel/jwt-cli/jwt-cli
	gradle
	lsd
	neovim
	fd
	lazygit
	htop
	golangci-lint
	dive
	sad
	nvm
	pulumi
)

casks=(
	## docker
	## google-chrome
	hammerspoon
	## visual-studio-code
	alt-tab
	apptivate
	audacity
	wezterm
	rectangle
	karabiner-elements
	font-jetbrains-mono-nerd-font
	## nikitabobko/tap/aerospace
	zed
	beekeeper-studio
)

brew upgrade
brew install ${formulae[@]}
brew install --force --cask ${casks[@]} --no-quarantine

echo "pinentry-program $(brew --prefix)/bin/pinentry-mac" > ~/.gnupg/gpg-agent.conf
echo "use-agent" > ~/.gnupg/gpg.conf
