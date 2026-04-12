#!/usr/bin/env bash
# tmux-kube-status-refresh
#
# Updates @kube_context_cache and @kube_namespace_cache on the tmux server
# based on the active pane's current directory, respecting direnv. Triggered
# both by tmux hooks (on pane/window/session switch) and by a hidden #() in
# status-right that runs on every status-interval tick.
#
# Idempotent and safe to invoke repeatedly.

set -u

pane_path=$(tmux display-message -p -F '#{pane_current_path}' 2>/dev/null || true)
[[ -n "${pane_path:-}" && -d "$pane_path" ]] || pane_path="$HOME"

# Run the given command inside the pane's directory. If direnv is available we
# use `direnv exec`, which loads any .envrc under $pane_path before executing
# the command — that's how per-directory KUBECONFIG overrides reach kubectl.
if command -v direnv >/dev/null 2>&1; then
  run_in_dir() { direnv exec "$pane_path" "$@" 2>/dev/null; }
else
  run_in_dir() { (cd "$pane_path" && "$@") 2>/dev/null; }
fi

context=$(run_in_dir kubectl config current-context || true)
if [[ -n "$context" ]]; then
  namespace=$(run_in_dir kubectl config view --minify \
    -o jsonpath='{.contexts[0].context.namespace}' || true)
  [[ -z "$namespace" ]] && namespace="default"
else
  namespace=""
fi

# Only update the cache (and trigger a redraw) when something actually changed.
prev_context=$(tmux show-option -gqv @kube_context_cache)
prev_namespace=$(tmux show-option -gqv @kube_namespace_cache)

if [[ "$context" != "$prev_context" || "$namespace" != "$prev_namespace" ]]; then
  tmux set-option -g @kube_context_cache   "$context"
  tmux set-option -g @kube_namespace_cache "$namespace"
  tmux refresh-client -S 2>/dev/null || true
fi
