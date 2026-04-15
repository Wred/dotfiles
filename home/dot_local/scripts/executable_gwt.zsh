# Git worktree helper functions

# Create a worktree for a branch
gwta() {
  if ! git rev-parse --git-dir &>/dev/null; then
    echo "Error: Not inside a git repository"
    return 1
  fi

  local branch=${${1// /-}:l}
  branch=${branch#origin/}
  if [[ -z $branch ]]; then
    echo "Usage: gwta <branch-name>"
    return 1
  fi

  # Use the main worktree path so this works from any worktree
  local main_tree=$(git worktree list | head -1 | awk '{print $1}')
  local dir="$(dirname $main_tree)/$(basename $main_tree)-$branch"

  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git worktree add "$dir" "$branch"
  elif git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    git worktree add "$dir" -b "$branch" "origin/$branch"
  else
    git worktree add "$dir" -b "$branch"
  fi

  # Seed .envrc with dev layout and allow it
  if [[ ! -f "$dir/.envrc" ]]; then
    echo 'source tmux-dev-layout.sh' > "$dir/.envrc"
    direnv allow "$dir"
  fi

  echo "Worktree created at: $dir"
}

# List all worktrees
gwtl() {
  git worktree list
}

# Remove a worktree by branch name
gwtrm() {
  if ! git rev-parse --git-dir &>/dev/null; then
    echo "Error: Not inside a git repository"
    return 1
  fi

  local force=false
  if [[ $1 == "-f" ]]; then
    force=true
    shift
  fi

  local arg=$1
  if [[ -z $arg ]]; then
    echo "Usage: gwtrm [-f] <path-or-branch>"
    return 1
  fi

  local dir branch
  if [[ -d $arg ]]; then
    # Argument is a worktree path — use it directly and look up the branch
    dir=$arg
    branch=$(git worktree list | awk -v d="$dir" '$1 == d { gsub(/[\[\]]/, "", $3); print $3 }')
  else
    # Argument is a branch name — reconstruct the path
    branch=${${arg// /-}:l}
    local main_tree=$(git worktree list | head -1 | awk '{print $1}')
    dir="$(dirname $main_tree)/$(basename $main_tree)-$branch"
  fi

  if [[ -d $dir ]]; then
    if [[ $force != true ]]; then
      echo "This will remove worktree '$dir:t' and delete branch '$branch'."
      read -q "reply?Are you sure? [y/N] "
      echo
      if [[ $reply != "y" ]]; then
        echo "Aborted."
        return 0
      fi
    fi
    if [[ -n $(git -C "$dir" status --porcelain 2>/dev/null) ]]; then
      echo "Warning: worktree has uncommitted changes:"
      git -C "$dir" status --short
      echo
      read -q "force_reply?Remove anyway? [y/N] "
      echo
      if [[ $force_reply != "y" ]]; then
        echo "Aborted."
        return 0
      fi
      git worktree remove --force "$dir"
    else
      git worktree remove "$dir"
    fi
    echo "Worktree removed: $dir:t"
  fi

  git worktree prune

  if [[ -n $branch ]] && git show-ref --verify --quiet "refs/heads/$branch"; then
    git branch -D "$branch"
    echo "Branch deleted: $branch"
  fi
}

# Prune stale worktree references
gwtp() {
  git worktree prune -v
}
