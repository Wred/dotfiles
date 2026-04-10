#!/usr/bin/env zsh

packages=(
	gcc
	base-devel
	git
	papirus-icon-theme
	curl
	vim
	neovim
	bat
	git-lfs
	jq
	pnpm
	go
	ripgrep
	tmux
	htop
	lsd
	fd
	nodejs
	python-pipx
	luarocks
	imagemagick
	github-cli
	lazygit
	keyd
	hyprland
	hyprpaper
	hyprpolkitagent
	xdg-desktop-portal-hyprland
	xdg-desktop-portal-gtk
	waybar
	wofi
	wl-clipboard
	wtype
	krita
	skanlite
	zed
	peek
	bottom
	dust
	ffmpeg
	golangci-lint
	poppler
	resvg
	sad
	tealdeer
	tree
	wget
	xz
	yazi
	yq
	zoxide
)

aur=(
	catppuccin-gtk-theme-mocha
	direnv
	sddm-sugar-candy-git
	xdg-user-dirs
	visual-studio-code-bin
	spotify
	google-chrome
	slack
	wezterm-git
	handy-bin
	doctl
	obsidian
	signal-desktop
	standardnotes-bin
)

sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm "${packages[@]}"

# Install yay if not present
if ! command -v yay &>/dev/null; then
	tmpdir=$(mktemp -d)
	git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
	(cd "$tmpdir/yay" && makepkg -si --noconfirm)
	rm -rf "$tmpdir"
fi

# wezterm-git conflicts with wezterm
sudo pacman -Rns --noconfirm wezterm 2>/dev/null || true

yay -Syu --noconfirm
yay -S --needed --noconfirm "${aur[@]}"

# flarectl
go install github.com/cloudflare/cloudflare-go/cmd/flarectl@latest
