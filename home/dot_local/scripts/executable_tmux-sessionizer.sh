#!/usr/bin/env zsh

if [[ $# -eq 1 ]]; then
	selected=$1
else
	directories=${TMUX_SESSIONIZER_SEARCH_DIRS:-"$HOME/work"}
	extra_dirs=${TMUX_SESSIONIZER_EXTRA_DIRS:-"$HOME/.local/share/chezmoi"}
	selected=$({ find $directories -mindepth 2 -maxdepth 2 -type d; echo $extra_dirs; } \
		| awk -F/ '{print $0 "\t" $(NF-1) "/" $NF}' \
		| fzf --delimiter='\t' --with-nth=2 \
		| cut -f1)
fi

if [[ -z $selected ]]; then
	exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
	tmux new-session -s $selected_name -c $selected
	exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
	tmux new-session -ds $selected_name -c $selected
fi

tmux switch-client -t $selected_name
