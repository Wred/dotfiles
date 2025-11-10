#!/usr/bin/env bash
set -eufo pipefail

curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh | bash
curl -fsSL https://claude.ai/install.sh | bash
npm i -g @openai/codex

