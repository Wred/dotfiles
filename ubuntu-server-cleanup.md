# Ubuntu Server Cleanup

The following packages, snaps, and applications are desktop-only in this dotfiles setup.
If you previously ran chezmoi on a machine before the desktop/server split, you may have
these installed on your server. Run `ubuntu-server-cleanup.sh` to remove them.

## Packages

- `krita`
- `skanlite`
- `xclip`
- `xcape`
- `wl-clipboard`
- `keyd`
- `peek`
- `hyprland`
- `wofi`

## Snaps

- `spotify`
- `signal-desktop`
- `standard-notes`
- `code` (VS Code)

## Applications installed outside apt/snap

- `zed` — installed via `curl -f https://zed.dev/install.sh | sh`. The exact paths depend
  on zed's installer; verify with `which zed` and `ls ~/.local/share/zed` before removing.

## PPAs

- `ppa:keyd-team/ppa`
