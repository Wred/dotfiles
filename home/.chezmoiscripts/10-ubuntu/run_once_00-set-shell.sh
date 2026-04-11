#!/usr/bin/env bash

# Ubuntu server defaults to bash and has no zsh. Install it here (this script
# sorts first by stripped basename) so every subsequent zsh-shebang script in
# .chezmoiscripts/ can actually execute.
sudo apt-get update
sudo apt-get install -y zsh
chsh -s /usr/bin/zsh
