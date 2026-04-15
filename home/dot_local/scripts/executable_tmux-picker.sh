#!/usr/bin/env zsh

# Unified tmux session picker with tabbed fzf interface.
# Tabs: Directories | Worktrees | Issues | PRs
# Non-git directories show only the Directories tab.
#
# Bound to C-g in tmux.conf.

SELF="${0:A}"
export TMUX_PICKER="$SELF"

source "$(dirname "$SELF")/gwt.zsh"

# ─── List generators (called by fzf reload) ─────────────────────────

_list_dirs() {
	local directories=${TMUX_SESSIONIZER_SEARCH_DIRS:-"$HOME/work"}
	local extra_dirs=${TMUX_SESSIONIZER_EXTRA_DIRS:-"$HOME/.local/share/chezmoi"}
	local active_sessions=$(tmux list-sessions -F '#S' 2>/dev/null || true)
	{ find $directories -mindepth 2 -maxdepth 2 -type d; echo $extra_dirs; } \
		| while IFS= read -r dir; do
			local name=$(basename "$dir" | tr . _)
			local label="${dir:h:t}/${dir:t}"
			if echo "$active_sessions" | grep -qx "$name" 2>/dev/null; then
				printf 'dir:%s\t\033[33m%s\033[0m\n' "$dir" "$label"
			else
				printf 'dir:%s\t%s\n' "$dir" "$label"
			fi
		done
}

_list_worktrees() {
	git worktree list | while read -r line; do
		local wt_path=${line%% *}
		local folder=${wt_path:t}
		local session=${${folder}//./_}
		local branch_field=${line##* }
		local branch=${branch_field//[\[\]]/}
		if tmux has-session -t="$session" 2>/dev/null; then
			printf 'wt:%s\t\033[33m%s\033[0m\n' "$wt_path" "$branch"
		else
			printf 'wt:%s\t%s\n' "$wt_path" "$branch"
		fi
	done

	local checked_out=$(git worktree list --porcelain \
		| awk '/^branch refs\/heads\// { sub("^branch refs/heads/", ""); print }')
	git branch -r --no-color 2>/dev/null | sed 's/^[* ]*//' | grep -v 'HEAD' \
		| while read -r ref; do
			local local_name=${ref#origin/}
			echo "$checked_out" | grep -qxF "$local_name" && continue
			printf 'remote:%s\t\033[36m%s\033[0m\n' "$local_name" "$ref"
		done
}

_list_issues() {
	if ! gh auth status >/dev/null 2>&1; then
		printf '\t\033[31mgh not authenticated — run gh auth login\033[0m\n'
		return
	fi
	local issues_json
	issues_json=$(gh issue list --state open --limit 1000 \
		--json number,title,labels,assignees 2>/dev/null)
	if [[ -z $issues_json || $issues_json == "[]" ]]; then
		printf '\t\033[2mNo open issues\033[0m\n'
		return
	fi

	local -a active_issue_nums=()
	while IFS= read -r wt_line; do
		local wt_path=${wt_line%% *}
		local branch_raw=${wt_line##* }
		local branch=${branch_raw//[\[\]]/}
		if [[ $branch =~ -issue-([0-9]+)$ ]]; then
			local num=$match[1]
			local session=$(basename "$wt_path" | tr . _)
			tmux has-session -t="$session" 2>/dev/null && active_issue_nums+=($num)
		fi
	done < <(git worktree list)

	echo "$issues_json" | jq -r '
		.[] |
		(.labels | map(.name) | join(",")) as $labels |
		(.assignees | map("@" + .login) | join(",")) as $assignees |
		(if $labels == "" then "" else "  \u001b[2m[\($labels)]\u001b[0m" end) as $labels_col |
		(if $assignees == "" then "" else "  \u001b[2m\($assignees)\u001b[0m" end) as $assignees_col |
		"issue:\(.number)\t#\(.number)  \(.title)\($labels_col)\($assignees_col)"
	' | while IFS= read -r line; do
		local num=${line#issue:}
		num=${num%%$'\t'*}
		if (( ${active_issue_nums[(Ie)$num]} )); then
			local key=${line%%$'\t'*}
			local display=${line#*$'\t'}
			printf '%s\t\033[33m%s\033[0m\n' "$key" "$display"
		else
			printf '%s\n' "$line"
		fi
	done
}

_list_prs() {
	if ! gh auth status >/dev/null 2>&1; then
		printf '\t\033[31mgh not authenticated — run gh auth login\033[0m\n'
		return
	fi
	local prs_json
	prs_json=$(gh pr list --state open --limit 1000 \
		--json number,title,headRefName,author,isDraft,reviewDecision 2>/dev/null)
	if [[ -z $prs_json || $prs_json == "[]" ]]; then
		printf '\t\033[2mNo open PRs\033[0m\n'
		return
	fi

	# Build set of branches with active tmux sessions (via worktrees)
	local -A active_branches=()
	while IFS= read -r wt_line; do
		local wt_path=${wt_line%% *}
		local branch_raw=${wt_line##* }
		local branch=${branch_raw//[\[\]]/}
		local session=$(basename "$wt_path" | tr . _)
		tmux has-session -t="$session" 2>/dev/null && active_branches[$branch]=1
	done < <(git worktree list)

	echo "$prs_json" | jq -r '
		.[] |
		(.author.login) as $author |
		(if .isDraft then "\u001b[2m[draft]\u001b[0m " else "" end) as $draft |
		(if .reviewDecision == "APPROVED" then "  \u001b[32m✓\u001b[0m"
		 elif .reviewDecision == "CHANGES_REQUESTED" then "  \u001b[31m✗\u001b[0m"
		 else "" end) as $review |
		"pr:\(.headRefName)\t#\(.number)  \($draft)\(.title)  \u001b[2m@\($author)\u001b[0m\($review)"
	' | while IFS= read -r line; do
		local branch=${line#pr:}
		branch=${branch%%$'\t'*}
		if (( ${+active_branches[$branch]} )); then
			local key=${line%%$'\t'*}
			local display=${line#*$'\t'}
			printf '%s\t\033[33m%s\033[0m\n' "$key" "$display"
		else
			printf '%s\n' "$line"
		fi
	done
}

# ─── Tab header ──────────────────────────────────────────────────────

_tab_header() {
	local active=$1
	local reset=$'\033[0m'
	local on=$'\033[1;7m'
	local off=$'\033[2m'
	local d w i p
	[[ $active == dirs ]]      && d=$on || d=$off
	[[ $active == worktrees ]] && w=$on || w=$off
	[[ $active == issues ]]    && i=$on || i=$off
	[[ $active == prs ]]       && p=$on || p=$off
	local tabs="${d} f:Dirs ${reset}  ${w} w:Worktrees ${reset}  ${i} i:Issues ${reset}  ${p} p:PRs ${reset}"
	local hints
	case $active in
		worktrees) hints="ctrl-x: delete · ctrl-h/l: switch" ;;
		issues)    hints="ctrl-a: autonomous · ctrl-h/l: switch" ;;
		prs)       hints="ctrl-h/l: switch" ;;
		*)         hints="ctrl-h/l: switch" ;;
	esac
	printf '%s\n%s' "$tabs" "$hints"
}

# ─── fzf transform subcommands ──────────────────────────────────────

_switch_tab() {
	local tab=$1
	case $tab in
		dirs)      echo "change-prompt(Directories> )+reload($TMUX_PICKER --list-dirs)+transform-header($TMUX_PICKER --tab-header dirs)+clear-query" ;;
		worktrees) echo "change-prompt(Worktrees> )+reload($TMUX_PICKER --list-worktrees)+transform-header($TMUX_PICKER --tab-header worktrees)+clear-query" ;;
		issues)    echo "change-prompt(Issues> )+reload-sync($TMUX_PICKER --list-issues)+transform-header($TMUX_PICKER --tab-header issues)+clear-query" ;;
		prs)       echo "change-prompt(PRs> )+reload-sync($TMUX_PICKER --list-prs)+transform-header($TMUX_PICKER --tab-header prs)+clear-query" ;;
	esac
}

_cycle_left() {
	case "$1" in
		"Directories> ") _switch_tab prs ;;
		"Worktrees> ")   _switch_tab dirs ;;
		"Issues> ")      _switch_tab worktrees ;;
		"PRs> ")         _switch_tab issues ;;
	esac
}

_cycle_right() {
	case "$1" in
		"Directories> ") _switch_tab worktrees ;;
		"Worktrees> ")   _switch_tab issues ;;
		"Issues> ")      _switch_tab prs ;;
		"PRs> ")         _switch_tab dirs ;;
	esac
}

_on_enter() {
	case "$1" in
		"Directories> ") echo "become(printf '%s\n%s' select {1})" ;;
		"Worktrees> ")   echo "become(printf '%s\n%s\n%s' select {1} {q})" ;;
		"Issues> ")      echo "become(printf '%s\n%s' interactive {1})" ;;
		"PRs> ")         echo "become(printf '%s\n%s' select {1})" ;;
	esac
}

_on_ctrl_a() {
	[[ "$1" == "Issues> " ]] && echo "become(printf '%s\n%s' autonomous {1})"
}

_on_ctrl_x() {
	[[ "$1" == "Worktrees> " ]] && \
		echo "execute($TMUX_PICKER --delete-wt {1})+reload($TMUX_PICKER --list-worktrees)"
}

# ─── Worktree delete (runs inside fzf execute) ──────────────────────

_delete_wt() {
	local raw="$1"
	if [[ $raw == remote:* ]]; then
		echo "Cannot delete a remote branch reference."
		sleep 1
		return
	fi
	gwtrm "${raw#wt:}"
}

# ─── Session handlers ───────────────────────────────────────────────

_open_session() {
	local selected="$1"
	[[ -z $selected ]] && exit 0
	local selected_name=$(basename "$selected" | tr . _)
	local tmux_running=$(pgrep tmux)
	if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
		tmux new-session -ds "$selected_name" -c "$selected"
		tmux attach-session -t "$selected_name"
		exit 0
	fi
	if ! tmux has-session -t="$selected_name" 2>/dev/null; then
		tmux new-session -ds "$selected_name" -c "$selected"
	fi
	tmux switch-client -t "$selected_name"
}

_open_remote() {
	local remote_branch="$1"
	gwta "$remote_branch"
	local sanitized=${${remote_branch// /-}:l}
	local selected=$(git worktree list | grep -F "$sanitized" | awk '{print $1}')
	if [[ -z $selected ]]; then
		echo "Error: Failed to find newly created worktree"
		exit 1
	fi
	_open_session "$selected"
}

_create_branch() {
	local query="$1"
	while true; do
		read "reply?Branch '$query' not found. Create a new worktree? (Y/n) "
		[[ -z $reply || $reply == [yY] ]] && break
		[[ $reply == [nN] ]] && exit 0
		echo "Invalid input. Please enter y or n."
	done
	echo
	gwta "$query"
	local sanitized=${${query// /-}:l}
	local selected=$(git worktree list | grep -F "$sanitized" | awk '{print $1}')
	if [[ -z $selected ]]; then
		echo "Error: Failed to find newly created worktree"
		exit 1
	fi
	_open_session "$selected"
}

_open_pr() {
	local branch="$1"
	[[ -z $branch ]] && exit 0

	# Check if a worktree already exists for this branch
	local existing=$(git worktree list | while read -r line; do
		local wt_path=${line%% *}
		local branch_field=${line##* }
		local b=${branch_field//[\[\]]/}
		[[ $b == "$branch" ]] && echo "$wt_path" && break
	done)

	if [[ -n $existing ]]; then
		_open_session "$existing"
	else
		gwta "$branch"
		local sanitized=${${branch// /-}:l}
		local selected=$(git worktree list | grep -F "$sanitized" | awk '{print $1}')
		if [[ -z $selected ]]; then
			echo "Error: Failed to find newly created worktree"
			exit 1
		fi
		_open_session "$selected"
	fi
}

_open_issue() {
	local issue_number="$1" mode="$2"
	[[ ! $issue_number =~ ^[0-9]+$ ]] && exit 0

	local issue_json=$(gh issue view "$issue_number" --json title 2>/dev/null)
	if [[ -z $issue_json ]]; then
		echo "Error: Failed to fetch issue #$issue_number"
		exit 1
	fi
	local issue_title=$(echo "$issue_json" | jq -r '.title')

	# Derive branch slug
	local lower_title=${issue_title:l}
	local slug=${lower_title//[^a-z0-9]/-}
	while [[ $slug == *--* ]]; do slug=${slug//--/-}; done
	slug=${slug#-}; slug=${slug%-}
	slug=${slug:0:40}; slug=${slug%-}
	[[ -z $slug ]] && slug="work"
	local branch="${slug}-issue-${issue_number}"

	# Idempotency: find existing worktree for this issue
	local existing=$(git worktree list --porcelain | awk -v n="$issue_number" '
		/^worktree / { p=$2 }
		/^branch refs\/heads\// {
			b=$2; sub("refs/heads/", "", b)
			if (b ~ "-issue-"n"$") { print p; exit }
		}
	')

	local selected is_new_worktree
	if [[ -n $existing ]]; then
		selected="$existing"
		is_new_worktree=0
		echo "Reusing existing worktree: $selected"
	else
		gwta "$branch"
		local sanitized=${${branch// /-}:l}
		selected=$(git worktree list | grep -F "$sanitized" | awk '{print $1}')
		if [[ -z $selected ]]; then
			echo "Error: Failed to find newly created worktree"
			exit 1
		fi
		is_new_worktree=1
	fi

	# Assign and comment on first pickup
	if [[ $is_new_worktree == 1 ]]; then
		gh issue edit "$issue_number" --add-assignee @me >/dev/null 2>&1 || \
			echo "Warning: failed to assign issue #$issue_number to @me (continuing)"
		gh issue comment "$issue_number" \
			--body "Started work on this in branch \`${branch}\`." >/dev/null 2>&1 || \
			echo "Warning: failed to post branch comment on issue #$issue_number (continuing)"
	fi

	local selected_name=$(basename "$selected" | tr . _)
	local tmux_running=$(pgrep tmux)

	_set_issue_env() {
		tmux set-environment -t "$selected_name" CODING_AGENT_ISSUE "$issue_number"
		tmux set-environment -t "$selected_name" CODING_AGENT_MODE "$mode"
	}

	if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
		tmux new-session -ds "$selected_name" -c "$selected"
		_set_issue_env
		tmux attach-session -t "$selected_name"
		exit 0
	fi

	local newly_created=false
	if ! tmux has-session -t="$selected_name" 2>/dev/null; then
		tmux new-session -ds "$selected_name" -c "$selected"
		newly_created=true
	fi
	tmux switch-client -t "$selected_name"
	if $newly_created; then
		_set_issue_env
	fi
}

# ─── Subcommand dispatch ────────────────────────────────────────────

case "${1:-}" in
	--list-dirs)      _list_dirs;                  exit ;;
	--list-worktrees) _list_worktrees;             exit ;;
	--list-issues)    _list_issues;                exit ;;
	--list-prs)       _list_prs;                  exit ;;
	--tab-header)     _tab_header "$2";            exit ;;
	--delete-wt)      _delete_wt "$2";             exit ;;
	--switch-tab)     _switch_tab "$2";            exit ;;
	--cycle-left)     _cycle_left "$2";            exit ;;
	--cycle-right)    _cycle_right "$2";           exit ;;
	--on-enter)       _on_enter "$2";              exit ;;
	--on-ctrl-a)      _on_ctrl_a "$2";             exit ;;
	--on-ctrl-x)      _on_ctrl_x "$2";             exit ;;
esac

# ─── Main ───────────────────────────────────────────────────────────

if git rev-parse --git-dir &>/dev/null; then
	# Tabbed mode: dirs + worktrees + issues
	output=$("$SELF" --list-dirs | fzf --ansi \
		--delimiter=$'\t' --with-nth=2 \
		--prompt 'Directories> ' \
		--header "$("$SELF" --tab-header dirs)" \
		--bind 'ctrl-f:transform:$TMUX_PICKER --switch-tab dirs' \
		--bind 'ctrl-w:transform:$TMUX_PICKER --switch-tab worktrees' \
		--bind 'ctrl-i:transform:$TMUX_PICKER --switch-tab issues' \
		--bind 'ctrl-p:transform:$TMUX_PICKER --switch-tab prs' \
		--bind 'ctrl-h:transform:$TMUX_PICKER --cycle-left "$FZF_PROMPT"' \
		--bind 'ctrl-l:transform:$TMUX_PICKER --cycle-right "$FZF_PROMPT"' \
		--bind 'ctrl-x:transform:$TMUX_PICKER --on-ctrl-x "$FZF_PROMPT"' \
		--bind 'ctrl-a:transform:$TMUX_PICKER --on-ctrl-a "$FZF_PROMPT"' \
		--bind 'enter:transform:$TMUX_PICKER --on-enter "$FZF_PROMPT"' \
	)
else
	# Non-git: directories only, no tabs
	output=$("$SELF" --list-dirs | fzf --ansi \
		--delimiter=$'\t' --with-nth=2 \
		--prompt '> ' \
		--bind 'enter:become(printf select\\n{1})' \
	)
fi

[[ -z $output ]] && exit 0

# Parse structured output from become()
# Line 1: mode (select | interactive | autonomous)
# Line 2: prefixed item (dir:… | wt:… | remote:… | issue:…)
# Line 3: fzf query (worktrees tab only)
mode=$(echo "$output" | sed -n '1p')
selected=$(echo "$output" | sed -n '2p')
query=$(echo "$output" | sed -n '3p')

case "$selected" in
	dir:*)    _open_session "${selected#dir:}" ;;
	wt:*)     _open_session "${selected#wt:}" ;;
	remote:*) _open_remote "${selected#remote:}" ;;
	issue:*)  _open_issue "${selected#issue:}" "$mode" ;;
	pr:*)     _open_pr "${selected#pr:}" ;;
	"")       [[ -n $query ]] && _create_branch "$query" ;;
esac
