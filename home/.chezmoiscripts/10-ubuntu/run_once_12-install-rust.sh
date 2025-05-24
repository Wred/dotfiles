#!/usr/bin/env zsh
set -efuo pipefail

curl --proto '=https' --tlsv1.3 -sSf https://sh.rustup.rs | sh -s -- -y
