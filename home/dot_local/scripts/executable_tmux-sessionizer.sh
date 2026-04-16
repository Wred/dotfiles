#!/usr/bin/env zsh

_hist_file="${XDG_CACHE_HOME:-$HOME/.cache}/tmux/sessionizer-history"
mkdir -p "${_hist_file:h}"

_record_dir_history() {
	local path="$1"
	local -a lines=("$path")
	if [[ -f $_hist_file ]]; then
		while IFS= read -r line; do
			[[ $line == $path ]] && continue
			lines+=("$line")
			(( ${#lines} >= 10 )) && break
		done < "$_hist_file"
	fi
	printf '%s\n' "${lines[@]}" >| "$_hist_file"
}

if [[ $# -eq 1 ]]; then
	selected=$1
else
	directories=${TMUX_SESSIONIZER_SEARCH_DIRS:-"$HOME/work"}
	extra_dirs=${TMUX_SESSIONIZER_EXTRA_DIRS:-"$HOME/.local/share/chezmoi"}
	active_sessions=$(tmux list-sessions -F '#S' 2>/dev/null || true)

	hist_paths=$([[ -f $_hist_file ]] && cat "$_hist_file" || true)

	selected=$(
		{
			if [[ -n $hist_paths ]]; then
				echo "$hist_paths" | while IFS= read -r dir; do
					[[ -d $dir ]] || continue
					name=$(basename "$dir" | tr . _)
					label="↑ ${dir:h:t}/${dir:t}"
					if echo "$active_sessions" | grep -qx "$name" 2>/dev/null; then
						printf '%s\t\033[33m%s\033[0m\n' "$dir" "$label"
					else
						printf '%s\t\033[2m%s\033[0m\n' "$dir" "$label"
					fi
				done
			fi
			{ find $directories -mindepth 2 -maxdepth 2 -type d; echo $extra_dirs; } \
				| while IFS= read -r dir; do
					[[ -n $hist_paths ]] && echo "$hist_paths" | grep -qxF "$dir" && continue
					name=$(basename "$dir" | tr . _)
					label="${dir:h:t}/${dir:t}"
					if echo "$active_sessions" | grep -qx "$name" 2>/dev/null; then
						printf '%s\t\033[33m%s\033[0m\n' "$dir" "$label"
					else
						printf '%s\t%s\n' "$dir" "$label"
					fi
				done
		} | fzf --delimiter=$'\t' --with-nth=2 --ansi \
		  | cut -f1
	)
fi

if [[ -z $selected ]]; then
	exit 0
fi

_record_dir_history "$selected"

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
	tmux new-session -ds "$selected_name" -c "$selected"
	tmux attach-session -t $selected_name
	exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
	tmux new-session -ds "$selected_name" -c "$selected"
fi

tmux switch-client -t $selected_name
