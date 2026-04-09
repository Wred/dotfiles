#!/usr/bin/env zsh

# Fail if not in a git repo
if ! git rev-parse --git-dir &>/dev/null; then
	echo "Error: Not inside a git repository"
	exit 1
fi

# Source gwt.zsh for worktree creation
source "$(dirname "$0")/gwt.zsh"

# Select a worktree via fzf (--print-query to capture typed input)
# ctrl-x: delete worktree, enter: select worktree
while true; do
	worktree_list=$(git worktree list | while read -r line; do
		path=${line%% *}
		folder=${path:t}
		session=${${folder}//./_}
		branch_field=${line##* }
		branch=${branch_field//[\[\]]/}
		if /opt/homebrew/bin/tmux has-session -t="$session" 2>/dev/null; then
			echo "${path}"$'\t'$'\033[33m'"${branch}"$'\033[0m'
		else
			echo "${path}"$'\t'"${branch}"
		fi
	done)

	result=$(echo "$worktree_list" | fzf --ansi --delimiter=$'\t' --with-nth=2 --print-query \
		--header "ctrl-x: delete worktree" \
		--expect "ctrl-x")
	query=$(echo "$result" | sed -n '1p')
	key=$(echo "$result" | sed -n '2p')
	selected_line=$(echo "$result" | sed -n '3p')
	match=${selected_line%%$'\t'*}

	if [[ $key == "ctrl-x" && -n $match ]]; then
		gwtrm "$match"
		continue
	fi
	break
done

if [[ -n $match ]]; then
	# User selected an existing worktree
	selected="$match"
elif [[ -n $query ]]; then
	# User typed something that didn't match — offer to create it
	while true; do
		read "reply?Branch '$query' not found. Create a new worktree? (Y/n) "
		[[ -z $reply || $reply == [yY] ]] && break
		[[ $reply == [nN] ]] && exit 0
		echo "Invalid input. Please enter y or n."
	done
	echo

	gwta "$query"

	# Resolve the new worktree path using the sanitized branch name
	local sanitized=${${query// /-}:l}
	selected=$(git worktree list | grep -F "$sanitized" | awk '{print $1}')
	if [[ -z $selected ]]; then
		echo "Error: Failed to find newly created worktree"
		exit 1
	fi
else
	exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
	tmux new-session -s "$selected_name" -c "$selected"
	exit 0
fi

if ! tmux has-session -t="$selected_name" 2>/dev/null; then
	tmux new-session -ds "$selected_name" -c "$selected"
fi

tmux switch-client -t "$selected_name"
