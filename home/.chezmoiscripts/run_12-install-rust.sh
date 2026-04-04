#!/usr/bin/env zsh
set -efuo pipefail

curl --proto '=https' -sSf https://sh.rustup.rs | sh -s -- -y
~/.cargo/bin/rustup component add rust-analyzer
