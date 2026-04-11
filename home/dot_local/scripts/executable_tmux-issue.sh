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

# Fetch full issue details
issue_json=$(gh issue view "$issue_number" \
	--json number,title,body,labels,url 2>/dev/null)
if [[ -z $issue_json ]]; then
	echo "Error: Failed to fetch issue #$issue_number"
	exit 1
fi

issue_title=$(echo "$issue_json" | jq -r '.title')
issue_body=$(echo "$issue_json" | jq -r '.body')
issue_url=$(echo "$issue_json" | jq -r '.url')
issue_labels=$(echo "$issue_json" | jq -r '.labels | map(.name) | join(", ")')

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

# Write the issue context file into the worktree. Overwrite on every run so
# an edited issue body gets picked up the next time you invoke the script.
# Use printf '%s\n' rather than a heredoc — an unquoted heredoc (<<EOF)
# expands backticks in $issue_body as command substitution, which causes
# the shell to escape them as \` before writing, leaving literal backslashes
# in the file.
context_file="${selected}/.claude-issue.md"
{
	printf '# Issue #%s: %s\n\n' "$issue_number" "$issue_title"
	printf '<!-- autogenerated by tmux-issue.sh — edit freely; will be overwritten on next run -->\n\n'
	printf 'Source: %s\n' "$issue_url"
	printf 'Labels: %s\n\n' "$issue_labels"
	printf '## Body\n\n'
	printf '%s\n' "$issue_body"
} >"$context_file"

# Exclude the context file locally so it never gets committed. The exclude
# file lives in the per-worktree .git dir (which for worktrees is a file
# pointing at .git/worktrees/<name>/), so resolve it via git rev-parse.
git_dir=$(git -C "$selected" rev-parse --git-path info/exclude 2>/dev/null)
if [[ -n $git_dir && -f $git_dir ]]; then
	if ! grep -qxF '.claude-issue.md' "$git_dir"; then
		echo '.claude-issue.md' >>"$git_dir"
	fi
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# Build the mode-specific first message for claude. These are short literal
# strings — safe to pass as argv. The issue body itself stays in the file
# to avoid quoting hell with backticks, dollar signs, and code blocks.
if [[ $mode == "autonomous" ]]; then
	claude_prompt='Read .claude-issue.md. Work the issue end-to-end: implement, test, commit on the current branch, push, then open a draft PR with gh pr create --draft. If acceptance criteria are ambiguous or you hit a blocking decision, stop and ask rather than guessing.'
else
	claude_prompt='Read .claude-issue.md and summarize the issue back to me. Then wait for my direction.'
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
