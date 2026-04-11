#!/usr/bin/env zsh
set -efuo pipefail

if ! command -v rustup &>/dev/null; then
	RUSTUP_INIT_SKIP_PATH_CHECK=yes curl --proto '=https' -sSf https://sh.rustup.rs | sh -s -- -y
fi
~/.cargo/bin/rustup component add rust-analyzer
