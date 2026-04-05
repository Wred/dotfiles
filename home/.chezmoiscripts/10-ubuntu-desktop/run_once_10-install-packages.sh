#!/usr/bin/env zsh

repositories=(
	ppa:keyd-team/ppa
)

packages=(
	krita
	skanlite
	xclip
	xcape
	wl-clipboard
	keyd
	peek
	hyprland
	wofi
	libgtk-layer-shell0 # required for handy
	xclip # required for handy paste (XWayland clipboard)
	xdotool # required for handy paste (XWayland key simulation)
)

snaps=(
	spotify
	signal-desktop
	standard-notes
)

classic_snaps=(
	code
)


################################
# Now install

for repository in ${repositories[@]}; do
	sudo add-apt-repository --yes $repository
done

sudo apt update
sudo apt install -y ${packages[@]}

for snap in ${snaps[@]}; do
	sudo snap install $snap
done

for classic_snap in ${classic_snaps[@]}; do
	sudo snap install $classic_snap --classic
done

# zed
curl -f https://zed.dev/install.sh | sh

# handy
HANDY_VERSION=$(curl -s "https://api.github.com/repos/cjpais/handy/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo /tmp/handy.deb "https://github.com/cjpais/handy/releases/download/v${HANDY_VERSION}/Handy_${HANDY_VERSION}_amd64.deb"
sudo apt install -y /tmp/handy.deb
rm /tmp/handy.deb
