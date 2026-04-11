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
		# NB: do NOT use the variable name `path` here — in zsh it is a
		# special array tied to $PATH, so `path=...` silently wipes $PATH
		# and every subsequent command in the loop (tmux, etc.) vanishes.
		wt_path=${line%% *}
		folder=${wt_path:t}
		session=${${folder}//./_}
		branch_field=${line##* }
		branch=${branch_field//[\[\]]/}
		if tmux has-session -t="$session" 2>/dev/null; then
			echo "${wt_path}"$'\t'$'\033[33m'"${branch}"$'\033[0m'
		else
			echo "${wt_path}"$'\t'"${branch}"
		fi
	done)

	# Build list of branches already checked out in worktrees (for dedup).
	# Porcelain lines look like `branch refs/heads/<name>`; we need just <name>
	# so the later `grep -qxF` whole-line match actually hits.
	checked_out_branches=$(git worktree list --porcelain | awk '/^branch refs\/heads\// { sub("^branch refs/heads/", ""); print }')

	# Build remote branch list (cyan), excluding branches that already have a worktree
	remote_list=$(git branch -r --no-color 2>/dev/null | sed 's/^[* ]*//' | grep -v 'HEAD' | while read -r ref; do
		local_name=${ref#origin/}
		if echo "$checked_out_branches" | grep -qxF "$local_name"; then
			continue
		fi
		echo "remote:${local_name}"$'\t'$'\033[36m'"${ref}"$'\033[0m'
	done)

	combined=$(printf '%s\n%s' "$worktree_list" "$remote_list" | sed '/^$/d')

	result=$(echo "$combined" | fzf --ansi --delimiter=$'\t' --with-nth=2 --print-query \
		--header "ctrl-x: delete worktree" \
		--expect "ctrl-x")
	query=$(echo "$result" | sed -n '1p')
	key=$(echo "$result" | sed -n '2p')
	selected_line=$(echo "$result" | sed -n '3p')
	match=${selected_line%%$'\t'*}

	if [[ $key == "ctrl-x" && -n $match ]]; then
		if [[ $match == remote:* ]]; then
			echo "Cannot delete a remote branch reference."
			continue
		fi
		gwtrm "$match"
		continue
	fi
	break
done

if [[ $match == remote:* ]]; then
	# User selected a remote branch — create a worktree from it
	local remote_branch=${match#remote:}
	gwta "$remote_branch"

	local sanitized=${${remote_branch// /-}:l}
	selected=$(git worktree list | grep -F "$sanitized" | awk '{print $1}')
	if [[ -z $selected ]]; then
		echo "Error: Failed to find newly created worktree"
		exit 1
	fi
elif [[ -n $match ]]; then
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

new_session() {
	local name="$1" dir="$2"
	tmux new-session -ds "$name" -c "$dir" "zsh -ic 'nvim'"
	tmux split-window -t "$name" -h -c "$dir" "zsh -ic 'claude --continue || claude'"
}

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
	new_session "$selected_name" "$selected"
	tmux attach-session -t "$selected_name"
	exit 0
fi

if ! tmux has-session -t="$selected_name" 2>/dev/null; then
	new_session "$selected_name" "$selected"
fi

tmux switch-client -t "$selected_name"
