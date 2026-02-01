#!/usr/bin/env zsh

repositories=()
packages=()
snaps=()
classic_snaps=()


packages+=(
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
	krita
	lsd
	tmux
	xclip
	skanlite
	xcape
	fd-find
	nodejs
	npm
	pipx
	luarocks
	wl-clipboard
	imagemagick
	ripgrep
	fd-find
	keyd
	gh
	peek
)

snaps+=(
	spotify
	signal-desktop
	standard-notes
)

classic_snaps+=(
	code
	nvim
)


################################
# Now install

for repository in ${repositories[@]}; do
	sudo add-apt-repository --yes $repository
done

sudo apt update
sudo apt --yes dist-upgrade
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

