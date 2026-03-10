#!/usr/bin/env zsh

formulae=(
	bat
	bottom
	coreutils
	curl
	direnv
	dive
	dockutil
	dust
	fd
	ffmpeg
	gh
	git-lfs
	gnu-units
	gnupg
	go
	golangci-lint
	gpg2
	gradle
	htop
	hugo
	imagemagick
	jq
	lazygit
	lsd
	mike-engel/jwt-cli/jwt-cli
	neovim
	nvm
	packer
	pinentry-mac
	pkg-config
	poppler
	pulumi
	python3
	resvg
	ripgrep
	sad
	sevenzip
	tlrc
	tmux
	tree
	watch
	wget
	xz
	yazi
	yq
	zoxide
)

casks=(
	## docker
	## google-chrome
	## nikitabobko/tap/aerospace
	## visual-studio-code
	alt-tab
	apptivate
	audacity
	beekeeper-studio
	font-jetbrains-mono-nerd-font
	hammerspoon
	handy
	jordanbaird-ice
	karabiner-elements
	rectangle
	wezterm
	zed
)

brew upgrade
brew install ${formulae[@]}
brew install --cask ${casks[@]}

