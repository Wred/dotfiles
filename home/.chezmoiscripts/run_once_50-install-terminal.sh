#!/usr/bin/env zsh
set -eufo pipefail

# install tmux plugin manager
if [ ! -d ~/.tmux/plugins/tpm ] ; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# install syntax highlighting
[ -d ~/.zsh/zsh-syntax-highlighting ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting

# install autosuggestions
[ -d ~/.zsh/zsh-autosuggestions ] || git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

# install fzf
if [ ! -d ~/.fzf ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --completion --key-bindings --no-fish --no-bash --no-update-rc
fi

