#!/usr/bin/env zsh

packages=(
	make
	curl
	vim
	bat
	direnv
	git-lfs
	jq
	units
	zsh
	htop
	golang-go
	lsd
	tmux
	fd-find
	nodejs
	pipx
	luarocks
	imagemagick
	ripgrep
	gh
)

packages_remove=(
	npm
)

snaps=(
	doctl
)

classic_snaps=(
	nvim
)


################################
# Now install

sudo apt update
sudo apt --yes dist-upgrade
sudo apt purge --auto-remove -y ${packages_remove[@]}
sudo apt install -y ${packages[@]}

for snap in ${snaps[@]}; do
	sudo snap install $snap
done

for classic_snap in ${classic_snaps[@]}; do
	sudo snap install $classic_snap --classic
done

# fix bat
mkdir -p ~/.local/bin
[ -L ~/.local/bin/bat ] || ln -s /usr/bin/batcat ~/.local/bin/bat

# flarectl
go install github.com/cloudflare/cloudflare-go/cmd/flarectl@latest
