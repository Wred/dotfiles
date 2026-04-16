#!/usr/bin/env zsh

# Set up a dev split: nvim (left) + claude (right, 40%).
# Picks up CODING_AGENT_ISSUE and CODING_AGENT_MODE from tmux session
# env vars to pass issue context to claude.
#
# Idempotent — does nothing if the window already has multiple panes.
# Called via send-keys from the picker after session creation.

# Must be in tmux
[[ -z $TMUX ]] && exit 0

# Idempotency: skip if window already has >1 pane
(( $(tmux list-panes 2>/dev/null | wc -l) > 1 )) && exit 0

# Read issue context from tmux session env
session=$(tmux display-message -p '#S')
issue=$(tmux show-environment -t "$session" CODING_AGENT_ISSUE 2>/dev/null | cut -d= -f2-)
mode=$(tmux show-environment -t "$session" CODING_AGENT_MODE 2>/dev/null | cut -d= -f2-)

# Build agent command — override with CODING_AGENT in .envrc (default: claude)
agent=${CODING_AGENT:-claude}
agent_cmd="$agent --continue || $agent"
if [[ -n $issue ]]; then
	if [[ $mode == "autonomous" ]]; then
		agent_cmd="$agent 'GitHub issue #${issue}. Read it with: gh issue view ${issue} --json title,body,labels,url. Assign the issue to yourself with gh issue edit ${issue} --add-assignee @me and comment that you have started working on it. Then work it end-to-end: implement, test, commit on the current branch, push, and open a draft PR with gh pr create --draft. If acceptance criteria are ambiguous or you hit a blocking decision, stop and ask rather than guessing.'"
	else
		agent_cmd="$agent 'GitHub issue #${issue}. Read it with: gh issue view ${issue} --json title,body,labels,url. Summarize it back to me, then ask if I want to assign the issue to myself and start working on it.'"
	fi
fi

# Split: claude on the right (50% width)
# Use direnv exec to inherit .envrc environment (e.g. KUBECONFIG)
tmux split-window -h -p 50 "direnv exec . zsh -ic '${agent_cmd}'"

# Start nvim in this pane (the left/original pane where the script is running)
nvim
