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

is_git_repo() { git -C "$1" rev-parse --is-inside-work-tree &>/dev/null }

new_session() {
	local name="$1" dir="$2"
	if is_git_repo "$dir"; then
		tmux new-session -ds "$name" -c "$dir" "zsh -ic 'nvim'"
		tmux split-window -t "$name" -h -p 40 -c "$dir" "zsh -ic 'claude --continue || claude'"
	else
		tmux new-session -ds "$name" -c "$dir"
	fi
}

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
	new_session "$selected_name" "$selected"
	tmux attach-session -t $selected_name
	exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
	new_session "$selected_name" "$selected"
fi

tmux switch-client -t $selected_name
