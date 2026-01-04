#!/usr/bin/env zsh

# install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# LSPs for neovim
# linter: https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/ruff.lua
uv tool install ruff@latest
# the rest (like 'go to definition'): pyright.  See: https://github.com/astral-sh/ruff-lsp/issues/23
sudo npm install -g pyright

