#!/usr/bin/env zsh
set -eufo pipefail

#
# ANDRE: NOTE: this is only necessary until 25.10 is released.
# 	See:  https://github.com/jesseduffield/lazygit?tab=readme-ov-file#debian-and-ubuntu
#

LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/

