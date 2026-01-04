#!/usr/bin/env zsh


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
	yazi
	ffmpeg
	sevenzip
	poppler
	zoxide
	resvg
	imagemagick
	hugo
	tree
	dust
	tlrc
	bottom
	gh
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
	jordanbaird-ice
)

brew upgrade
brew install ${formulae[@]}
brew install --cask ${casks[@]} --no-quarantine

