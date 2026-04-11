#!/usr/bin/env zsh

sudo add-apt-repository --yes ppa:deadsnakes/ppa
sudo apt install python3.11
sudo apt install python-is-python3

# install poetry
curl -sSL https://install.python-poetry.org | python3 -

# need to remove repo because it won't update properly:
#   E: The repository 'http://ppa.launchpad.net/deadsnakes/ppa/ubuntu groovy Release' does not have a Release file.
#   N: Updating from such a repository can't be done securely, and is therefore disabled by default.
#   N: See apt-secure(8) manpage for repository creation and user configuration details.

sudo add-apt-repository --yes --remove ppa:deadsnakes/ppa
