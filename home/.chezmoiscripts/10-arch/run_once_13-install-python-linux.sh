#!/usr/bin/env zsh

sudo pacman -S --needed --noconfirm python python-pip

# install poetry
curl -sSL https://install.python-poetry.org | python3 -
