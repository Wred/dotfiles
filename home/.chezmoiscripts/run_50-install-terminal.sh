#!/usr/bin/env zsh

# install tmux plugin manager
if [ ! -d ~/.tmux/plugins/tpm ] ; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    git -C ~/.tmux/plugins/tpm pull
fi

# install syntax highlighting
if [ ! -d ~/.zsh/zsh-syntax-highlighting ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
else
    git -C ~/.zsh/zsh-syntax-highlighting pull
fi

# install autosuggestions
if [ ! -d ~/.zsh/zsh-autosuggestions ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
else
    git -C ~/.zsh/zsh-autosuggestions pull
fi

# install fzf
if [ ! -d ~/.fzf ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --completion --key-bindings --no-fish --no-bash --no-update-rc
else
    git -C ~/.fzf pull
fi

