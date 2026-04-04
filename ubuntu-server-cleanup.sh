#!/usr/bin/env bash
set -euo pipefail

# Remove desktop packages
sudo apt remove --auto-remove -y \
    krita \
    skanlite \
    xclip \
    xcape \
    wl-clipboard \
    keyd \
    peek \
    hyprland \
    wofi

# Remove desktop snaps
sudo snap remove spotify
sudo snap remove signal-desktop
sudo snap remove standard-notes
sudo snap remove code

# Remove keyd PPA
sudo add-apt-repository --yes --remove ppa:keyd-team/ppa

# Remove zed
# Note: paths depend on zed's installer — verify with `which zed` and `ls ~/.local/share/zed` first
rm -f ~/.local/bin/zed
rm -rf ~/.local/share/zed
rm -rf ~/.config/zed

sudo apt update
