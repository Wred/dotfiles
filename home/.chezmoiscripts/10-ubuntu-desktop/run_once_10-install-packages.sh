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
