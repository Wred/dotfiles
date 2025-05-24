#!/usr/bin/env zsh
set -eufo pipefail

sed -i 's/Pale Moon.desktop/google-chrome.desktop/' ~/.config/mimeapps.list
sed -i 's/palemoon/google-chrome-stable/' ~/.i3/config
sed -i 's/palemoon/google-chrome-stable/' ~/.profile
# need to temporarily unset BROWSER env var in order to use xdg-settings
unset BROWSER
xdg-settings set default-web-browser google-chrome.desktop
