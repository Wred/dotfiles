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

# obsidian
OBSIDIAN_VERSION=$(curl -s "https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo /tmp/obsidian.deb "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/obsidian_${OBSIDIAN_VERSION}_amd64.deb"
sudo apt install -y /tmp/obsidian.deb
rm /tmp/obsidian.deb
