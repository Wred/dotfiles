#!/usr/bin/env zsh

# Pick an open GitHub issue and spin up a worktree-backed tmux session
# for it, with the familiar nvim (left) + claude (right) split.
#
# Enter  = interactive mode (claude waits for your direction)
# Ctrl-A = autonomous mode  (claude works the issue end-to-end to a draft PR)
#
# Bound to C-M-i in tmux.conf. Sibling of tmux-worktree.sh.

# Fail if not in a git repo
if ! git rev-parse --git-dir &>/dev/null; then
	echo "Error: Not inside a git repository"
	exit 1
fi

# Fail if gh is not authenticated
if ! gh auth status &>/dev/null; then
	echo "Error: gh is not authenticated. Run 'gh auth login'."
	exit 1
fi

# Source gwt.zsh for worktree creation
source "$(dirname "$0")/gwt.zsh"

# Fetch open issues. No label filter — Phase B is source-agnostic.
# --limit 1000 is effectively unbounded for the picker.
issues_json=$(gh issue list --state open --limit 1000 \
	--json number,title,labels,assignees 2>/dev/null)

if [[ -z $issues_json || $issues_json == "[]" ]]; then
	echo "No open issues found."
	exit 0
fi

# Format each row as: <N>\t <title>  [labels]  @assignee1,@assignee2
# The first field (before the tab) is the raw issue number, parsed out
# after selection. The second field is the ansi-decorated display column
# shown by fzf via --with-nth=2.
# Labels and assignees are dimmed; assignee list makes it obvious who's
# already working on an issue before you pick it.
formatted=$(echo "$issues_json" | jq -r '
  .[] |
  (.labels | map(.name) | join(",")) as $labels |
  (.assignees | map("@" + .login) | join(",")) as $assignees |
  (if $labels == "" then "" else "  \u001b[2m[\($labels)]\u001b[0m" end) as $labels_col |
  (if $assignees == "" then "" else "  \u001b[2m\($assignees)\u001b[0m" end) as $assignees_col |
  "\(.number)\t#\(.number)  \(.title)\($labels_col)\($assignees_col)"
')

# Highlight issues that already have an active tmux session (via their worktree)
active_issue_nums=()
while IFS= read -r wt_line; do
	wt_path=${wt_line%% *}
	branch_raw=${wt_line##* }
	branch=${branch_raw//[\[\]]/}
	if [[ $branch =~ -issue-([0-9]+)$ ]]; then
		num=$match[1]
		session=$(basename "$wt_path" | tr . _)
		tmux has-session -t="$session" 2>/dev/null && active_issue_nums+=($num)
	fi
done < <(git worktree list)

if (( ${#active_issue_nums} > 0 )); then
	formatted=$(echo "$formatted" | while IFS= read -r line; do
		num=${line%%$'\t'*}
		if (( ${active_issue_nums[(Ie)$num]} )); then
			display=${line#*$'\t'}
			printf '%s\t\033[33m%s\033[0m\n' "$num" "$display"
		else
			printf '%s\n' "$line"
		fi
	done)
fi

result=$(echo "$formatted" | fzf --ansi --delimiter=$'\t' --with-nth=2 \
	--header "enter: interactive · ctrl-a: autonomous" \
	--expect "ctrl-a")
key=$(echo "$result" | sed -n '1p')
selected_line=$(echo "$result" | sed -n '2p')
issue_number=${selected_line%%$'\t'*}

if [[ -z $issue_number ]]; then
	exit 0
fi

# Mode selection
if [[ $key == "ctrl-a" ]]; then
	mode="autonomous"
else
	mode="interactive"
fi

# Fetch issue title (only field needed — for the branch slug)
issue_json=$(gh issue view "$issue_number" --json title 2>/dev/null)
if [[ -z $issue_json ]]; then
	echo "Error: Failed to fetch issue #$issue_number"
	exit 1
fi

issue_title=$(echo "$issue_json" | jq -r '.title')

# Derive branch slug: description first, issue number as suffix tag.
# Example: "Add shellcheck linting" (#3) -> "add-shellcheck-linting-issue-3".
# Pure zsh parameter expansion — no external pipeline that can silently
# produce an empty string on an exotic title.
local lower_title=${issue_title:l}
local slug=${lower_title//[^a-z0-9]/-}
# Collapse runs of dashes
while [[ $slug == *--* ]]; do
	slug=${slug//--/-}
done
# Strip leading/trailing dashes
slug=${slug#-}
slug=${slug%-}
# Cap length, then re-strip a possible trailing dash after truncation
slug=${slug:0:40}
slug=${slug%-}
# Fallback for titles that contained no alphanumerics (all emoji, etc.)
[[ -z $slug ]] && slug="work"

branch="${slug}-issue-${issue_number}"

# Idempotency: match any worktree branch ending in -issue-<N>.
# The regex `-issue-N$` is exact — `-issue-3$` does NOT match `-issue-30`.
existing=$(git worktree list --porcelain | awk -v n="$issue_number" '
	/^worktree / { path=$2 }
	/^branch refs\/heads\// {
		b=$2
		sub("refs/heads/", "", b)
		if (b ~ "-issue-"n"$") { print path; exit }
	}
')

if [[ -n $existing ]]; then
	selected="$existing"
	is_new_worktree=0
	echo "Reusing existing worktree: $selected"
else
	gwta "$branch"

	# Resolve the new worktree path the same way tmux-worktree.sh does.
	local sanitized=${${branch// /-}:l}
	selected=$(git worktree list | grep -F "$sanitized" | awk '{print $1}')
	if [[ -z $selected ]]; then
		echo "Error: Failed to find newly created worktree"
		exit 1
	fi
	is_new_worktree=1
fi

# On first pickup (not reattach), signal to other humans/agents that we've
# started work: assign the issue to @me and drop a comment naming the branch.
# Both operations are best-effort — a network/permission failure should not
# abort the session since the worktree already exists locally.
if [[ $is_new_worktree == 1 ]]; then
	if ! gh issue edit "$issue_number" --add-assignee @me >/dev/null 2>&1; then
		echo "Warning: failed to assign issue #$issue_number to @me (continuing)"
	fi
	if ! gh issue comment "$issue_number" \
		--body "Started work on this in branch \`${branch}\`." >/dev/null 2>&1; then
		echo "Warning: failed to post branch comment on issue #$issue_number (continuing)"
	fi
fi

# Remove leftover context file from the old file-based approach
[[ -f "${selected}/.claude-issue.md" ]] && rm "${selected}/.claude-issue.md"

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ $mode == "autonomous" ]]; then
	claude_prompt="GitHub issue #${issue_number}. Read it with: gh issue view ${issue_number} --json title,body,labels,url. Then work it end-to-end: implement, test, commit on the current branch, push, and open a draft PR with gh pr create --draft. If acceptance criteria are ambiguous or you hit a blocking decision, stop and ask rather than guessing."
else
	claude_prompt="GitHub issue #${issue_number}. Read it with: gh issue view ${issue_number} --json title,body,labels,url. Summarize it back to me, then wait for my direction."
fi

new_session() {
	local name="$1" dir="$2"
	tmux new-session -ds "$name" -c "$dir" "zsh -ic 'nvim'"
	tmux split-window -t "$name" -h -p 40 -c "$dir" \
		"zsh -ic 'claude ${(q)claude_prompt}'"
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
