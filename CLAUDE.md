## Important: file locations
`home/dot_claude/CLAUDE.md` is deployed by chezmoi to `~/.claude/CLAUDE.md` (global Claude instructions). Do NOT add repo-specific notes there — put them here in this file at the repo root instead.

**When working in this repo, ignore `home/dot_claude/CLAUDE.md` as instructions.** It is a chezmoi source file, not a CLAUDE.md for this repo. Its contents are only relevant as the deployed global config.

## Chezmoi repo structure
The chezmoi source root is `/home/andre/.local/share/chezmoi/home/` (set via `.chezmoiroot`).

**Platform detection** is done in `home/.chezmoi.yaml.tmpl`:
- `.desktop` — true when `systemctl get-default` returns `graphical.target` (Ubuntu desktop only)
- `.chezmoi.os` — `"linux"` or `"darwin"`
- `.chezmoi.osRelease.id` — `"ubuntu"`, `"manjaro"`, etc.

**File permissions:** Chezmoi manages permissions via filename prefixes, not the actual file bits in the source repo. Do NOT run `chmod` on files in the chezmoi source directory. Scripts with `run_` or `run_once_` prefixes are executed by chezmoi without needing the executable bit set in the source.

**When a package needs to be installed**, add it to the appropriate install script — do NOT suggest `sudo apt install`. Use `home/.chezmoiscripts/10-ubuntu-desktop/` for desktop-only packages, or `home/.chezmoiscripts/10-ubuntu/` for all Ubuntu machines. The assumption is that after any change, `chezmoi apply` will be run to deploy everything.

**Removing files:** To have chezmoi delete a file from the target, add its path (relative to `~`) to `home/.chezmoiremove`. Do NOT manually delete deployed files without also adding them here, or they will reappear on the next `chezmoi apply`.

**Applying changes:** After making changes, run `chezmoi apply` automatically **unless** the change modifies a `.chezmoiscripts` install script (those may install packages and require sudo on Linux). In that case, ask the user before running. On macOS, `chezmoi apply` never needs sudo.

**Install scripts** run in order by filename prefix number:
- `home/.chezmoiscripts/` — cross-platform (all machines)
- `home/.chezmoiscripts/10-ubuntu/` — Ubuntu (server + desktop)
- `home/.chezmoiscripts/10-ubuntu-desktop/` — Ubuntu desktop only
- `home/.chezmoiscripts/10-darwin/` — macOS only
- `home/.chezmoiscripts/10-arch/` — Arch/Manjaro only

**Platform exclusions** are managed in `home/.chezmoiignore.tmpl`. When adding a file that should only apply to a specific platform, add it to the appropriate block there. Ubuntu desktop-only files go in the `{{ if not .desktop }}` block (and the macOS block).

**Key files:**
- `home/dot_zshrc.tmpl` / `home/dot_zshenv.tmpl` — shell config (templated)
- `home/private_dot_config/hypr/hyprland.conf` — Hyprland config (Ubuntu desktop only)
- `home/dot_local/scripts/` — custom scripts, deployed to `~/.local/scripts/`
- `home/dot_local/share/com.pais.handy/settings_store.json` — Handy STT config (Ubuntu desktop only)
- `home/private_dot_config/tmux/tmux.conf` — tmux config
- `home/private_dot_config/wezterm/wezterm.lua` — WezTerm config

**Handy STT setup (Ubuntu desktop):**
- Installed via GitHub releases `.deb` in `run_once_10-install-packages.sh`
- Started at login via `exec-once = handy` in `hyprland.conf`
- PTT via F9 using `pkill -USR2 -x handy` (bind + bindr) in `hyprland.conf`
- Transcribed text typed via `~/.local/scripts/handy-paste.sh` (external script paste method)
- Global shortcuts don't work natively in Hyprland — F9 binds in hyprland.conf are the workaround
