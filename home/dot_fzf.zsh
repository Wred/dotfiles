# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/andre.milton/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/andre.milton/.fzf/bin"
fi

# Auto-completion
# ---------------
source "/Users/andre.milton/.fzf/shell/completion.zsh"

# Key bindings
# ------------
source "/Users/andre.milton/.fzf/shell/key-bindings.zsh"
