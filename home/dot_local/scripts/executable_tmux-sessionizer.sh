#!/usr/bin/env zsh

if [[ $# -eq 1 ]]; then
	selected=$1
else
	directories=${TMUX_SESSIONIZER_SEARCH_DIRS:-"$HOME/work"}
	extra_dirs=${TMUX_SESSIONIZER_EXTRA_DIRS:-"$HOME/.local/share/chezmoi"}
	active_sessions=$(tmux list-sessions -F '#S' 2>/dev/null || true)
	selected=$({ find $directories -mindepth 2 -maxdepth 2 -type d; echo $extra_dirs; } \
		| while IFS= read -r dir; do
			name=$(basename "$dir" | tr . _)
			label="${dir:h:t}/${dir:t}"
			if echo "$active_sessions" | grep -qx "$name" 2>/dev/null; then
				printf '%s\t\033[33m%s\033[0m\n' "$dir" "$label"
			else
				printf '%s\t%s\n' "$dir" "$label"
			fi
		  done \
		| fzf --delimiter='\t' --with-nth=2 --ansi \
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
	else
		tmux new-session -ds "$name" -c "$dir"
	fi
}

add_claude_pane() {
	local name="$1" dir="$2"
	is_git_repo "$dir" || return
	tmux split-window -t "$name" -h -p 40 -c "$dir" "zsh -ic 'claude --continue || claude'"
	tmux select-pane -t "$name" -L
}

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
	new_session "$selected_name" "$selected"
	add_claude_pane "$selected_name" "$selected"
	tmux attach-session -t $selected_name
	exit 0
fi

newly_created=false
if ! tmux has-session -t=$selected_name 2> /dev/null; then
	new_session "$selected_name" "$selected"
	newly_created=true
fi

tmux switch-client -t $selected_name

if $newly_created; then
	add_claude_pane "$selected_name" "$selected"
fi
