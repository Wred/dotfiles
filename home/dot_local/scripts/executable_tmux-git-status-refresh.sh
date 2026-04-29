#!/usr/bin/env bash
# Updates @git_branch_cache and @git_icon_cache on the tmux server based on
# the active pane's current directory and its git remote.
#
# Service detection (fast path, by hostname pattern):
#   github.com                        → GitHub public
#   *gitlab* / *bitbucket* / *gitea*  → respective service
#
# For any hostname not caught by the fast path, probes the service API and
# caches the result in ~/.cache/tmux-git-service/<hostname> so the network
# is only hit once per host. This covers enterprise GitHub/GitLab/Gitea
# instances with non-obvious hostnames.

set -u

ICON_GITHUB=$'\xef\x82\x9b'   # U+F09B  nf-fa-github
ICON_GITLAB=$'\xef\x8a\x96'   # U+F296  nf-fa-gitlab
ICON_BITBUCKET=$'\xef\x85\xb1' # U+F171  nf-fa-bitbucket
ICON_GITEA=$'\xef\x8c\xb9'    # U+F339  nf-md-tea
ICON_GENERIC=$'\xee\x82\xa0'  # U+E0A0  nf-pl-branch

pane_path=$(tmux display-message -p -F '#{pane_current_path}' 2>/dev/null || true)
[[ -n "${pane_path:-}" && -d "$pane_path" ]] || pane_path="$HOME"

branch=$(cd "$pane_path" && git rev-parse --abbrev-ref HEAD 2>/dev/null || true)

if [[ -n "$branch" ]]; then
  remote_url=$(cd "$pane_path" && git remote get-url origin 2>/dev/null || true)
  # Extract scheme and hostname (preserving port) from SSH or HTTP(S) remote URLs.
  # SSH:   git@host:path  → scheme=https, host=host  (port unknown, assume standard)
  # HTTP:  http://host:port/path → scheme=http, host=host:port
  # HTTPS: https://host/path    → scheme=https, host=host
  if [[ "$remote_url" == git@* ]]; then
    scheme="https"
    hostname="${remote_url#git@}"; hostname="${hostname%%:*}"
  elif [[ "$remote_url" == http://* ]]; then
    scheme="http"
    hostname="${remote_url#http://}"; hostname="${hostname%%/*}"
  elif [[ "$remote_url" == https://* ]]; then
    scheme="https"
    hostname="${remote_url#https://}"; hostname="${hostname%%/*}"
  else
    scheme="https"; hostname=""
  fi

  # Fast path: well-known hostnames and explicit env var lists
  icon=""
  if [[ "$hostname" == "github.com" ]]; then
    icon="$ICON_GITHUB"
  fi

  if [[ -z "$icon" ]]; then
    case "$hostname" in
      *gitlab*)    icon="$ICON_GITLAB" ;;
      *bitbucket*) icon="$ICON_BITBUCKET" ;;
      *gitea*)     icon="$ICON_GITEA" ;;
    esac
  fi

  # Slow path: probe service API for unknown hostnames, cache result per host
  if [[ -z "$icon" && -n "$hostname" ]]; then
    cache_dir="${HOME}/.cache/tmux-git-service"
    cache_file="${cache_dir}/${hostname//:/_}"
    mkdir -p "$cache_dir"

    if [[ -f "$cache_file" ]]; then
      cached_service=$(cat "$cache_file")
    else
      cached_service="generic"
      base="${scheme}://${hostname}"
      if curl -sf --max-time 3 "${base}/api/v3/meta" 2>/dev/null \
          | grep -qE '"github_services_sha"|"installed_version"'; then
        cached_service="github"
      elif curl -sf --max-time 3 "${base}/api/v4/version" 2>/dev/null \
          | grep -q '"version"'; then
        cached_service="gitlab"
      elif curl -sf --max-time 3 "${base}/api/v1/version" 2>/dev/null \
          | grep -q '"version"'; then
        cached_service="gitea"
      fi
      printf '%s' "$cached_service" > "$cache_file"
    fi

    case "$cached_service" in
      github)    icon="$ICON_GITHUB" ;;
      gitlab)    icon="$ICON_GITLAB" ;;
      gitea)     icon="$ICON_GITEA" ;;
      *)         icon="$ICON_GENERIC" ;;
    esac
  fi

  [[ -z "$icon" ]] && icon="$ICON_GENERIC"
else
  icon=""
fi

prev_branch=$(tmux show-option -gqv @git_branch_cache)
prev_icon=$(tmux show-option -gqv @git_icon_cache)

if [[ "$branch" != "$prev_branch" || "$icon" != "$prev_icon" ]]; then
  tmux set-option -g @git_branch_cache "$branch"
  tmux set-option -g @git_icon_cache   "$icon"
  tmux refresh-client -S 2>/dev/null || true
fi
