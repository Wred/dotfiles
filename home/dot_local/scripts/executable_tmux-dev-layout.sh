#!/usr/bin/env zsh

# Set up a dev split: nvim (left) + claude (right, 40%).
# Picks up CODING_AGENT_ISSUE and CODING_AGENT_MODE from tmux session
# env vars to pass issue context to claude.
#
# Idempotent — does nothing if the window already has multiple panes.
# Intended to be called from .envrc files.

# Must be in tmux
if [[ -z $TMUX ]]; then return 0 2>/dev/null; exit 0; fi

# Idempotency: skip if window already has >1 pane
if (( $(tmux list-panes 2>/dev/null | wc -l) > 1 )); then return 0 2>/dev/null; exit 0; fi

# Read issue context from tmux session env
session=$(tmux display-message -p '#S')
issue=$(tmux show-environment -t "$session" CODING_AGENT_ISSUE 2>/dev/null | cut -d= -f2-)
mode=$(tmux show-environment -t "$session" CODING_AGENT_MODE 2>/dev/null | cut -d= -f2-)

# Build claude command
claude_cmd="claude --continue || claude"
if [[ -n $issue ]]; then
	if [[ $mode == "autonomous" ]]; then
		claude_cmd="claude 'GitHub issue #${issue}. Read it with: gh issue view ${issue} --json title,body,labels,url. Assign the issue to yourself with gh issue edit ${issue} --add-assignee @me and comment that you have started working on it. Then work it end-to-end: implement, test, commit on the current branch, push, and open a draft PR with gh pr create --draft. If acceptance criteria are ambiguous or you hit a blocking decision, stop and ask rather than guessing.'"
	else
		claude_cmd="claude 'GitHub issue #${issue}. Read it with: gh issue view ${issue} --json title,body,labels,url. Summarize it back to me, then ask if I want to assign the issue to myself and start working on it.'"
	fi
fi

# Split: claude on the right (40% width)
tmux split-window -h -p 40 "zsh -ic '${claude_cmd}'"

# Focus back to the left pane and start nvim
tmux select-pane -L
tmux send-keys 'nvim' Enter
