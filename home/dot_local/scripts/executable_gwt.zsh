# Git worktree helper functions

# Create a worktree for a branch
gwta() {
  if ! git rev-parse --git-dir &>/dev/null; then
    echo "Error: Not inside a git repository"
    return 1
  fi

  local branch=${${1// /-}:l}
  if [[ -z $branch ]]; then
    echo "Usage: gwta <branch-name>"
    return 1
  fi

  # Use the main worktree path so this works from any worktree
  local main_tree=$(git worktree list | head -1 | awk '{print $1}')
  local dir="$(dirname $main_tree)/$(basename $main_tree)-$branch"

  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git worktree add "$dir" "$branch"
  else
    git worktree add "$dir" -b "$branch"
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

  local branch=${${1// /-}:l}
  if [[ -z $branch ]]; then
    echo "Usage: gwtrm [-f] <branch-name>"
    return 1
  fi

  local main_tree=$(git worktree list | head -1 | awk '{print $1}')
  local dir="$(dirname $main_tree)/$(basename $main_tree)-$branch"

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
  else
    echo "Error: Worktree not found at $dir"
    return 1
  fi

  git worktree prune

  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git branch -D "$branch"
    echo "Branch deleted: $branch"
  fi
}

# Prune stale worktree references
gwtp() {
  git worktree prune -v
}
