# Git worktree helper functions

# Create a worktree for a branch
gwta() {
  if ! git rev-parse --git-dir &>/dev/null; then
    echo "Error: Not inside a git repository"
    return 1
  fi

  local repo_root=$(git rev-parse --show-toplevel)
  if [[ $PWD != $repo_root ]]; then
    echo "Error: Must be at repository root ($repo_root)"
    return 1
  fi

  local branch=$1
  if [[ -z $branch ]]; then
    echo "Usage: gwta <branch-name>"
    return 1
  fi

  local dir="../$(basename $PWD)-$branch"

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

  local branch=$1
  if [[ -z $branch ]]; then
    echo "Usage: gwtrm <branch-name>"
    return 1
  fi

  local repo_root=$(git rev-parse --show-toplevel)
  local dir="$(dirname $repo_root)/$(basename $repo_root)-$branch"

  if [[ -d $dir ]]; then
    git worktree remove "$dir"
    echo "Worktree removed: $dir"
  else
    echo "Error: Worktree not found at $dir"
    return 1
  fi
}

# Prune stale worktree references
gwtp() {
  git worktree prune -v
}
