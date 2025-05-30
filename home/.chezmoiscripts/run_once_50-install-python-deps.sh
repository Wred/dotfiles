#!/usr/bin/env zsh
set -eufo pipefail

[ -d ~/.pyenv ] || git clone https://github.com/pyenv/pyenv.git ~/.pyenv
[ -d ~/.pyenv/plugins/pyenv-virtualenv ] || git clone https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv

# add pipx's path
pipx ensurepath

# install uv
pipx install uv
# the install will add this to bashrc but in case we don't have it yet
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$PATH:/home/andre/.local/bin"
fi

# LSPs for neovim
# linter: https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/ruff.lua
uv tool install ruff@latest
# the rest (like 'go to definition'): pyright.  See: https://github.com/astral-sh/ruff-lsp/issues/23
sudo npm install -g pyright

