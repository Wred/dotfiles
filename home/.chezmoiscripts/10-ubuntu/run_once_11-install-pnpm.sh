#!/usr/bin/env zsh

curl -fsSL https://get.pnpm.io/install.sh | sh -

# Change the global node modules dir to local so we don't use sudo
mkdir -p ~/.local/share/pnpm
pnpm config set global-bin-dir ~/.local/share/pnpm
