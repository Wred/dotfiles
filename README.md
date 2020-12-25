# dotfiles
André Milton's dotfiles, managed with [`chezmoi.io`](https://chezmoi.io/).

# Install

## Ubuntu
To install on Ubuntu 20.04:

```
snap install chezmoi --classic
systemctl stop apt-daily.timer
sudo apt-get install git
chezmoi init --apply --verbose https://github.com/Wred/dotfiles.git
```

*Note*: the stop for the apt service seems necessary to remove the lock likely taken by auto-update before installing git

## Arch
To install on Manjaro-i3 (https://manjaro.org/downloads/community/i3/):

```
pacman -S --noconfirm chezmoi
chezmoi init --apply --verbose https://github.com/Wred/dotfiles.git
```

## Mac
To install on MacOS 10.15 (Catalina)

```
brew install chezmoi
chezmoi init --apply --verbose git@github.com:Wred/dotfiles.git
```

- Set iTerm2 as the default terminal (under the iTerm2 menu -> "Make iTerm2 Default Term").
- "Note for iTerm2 users - Please enable the Nerd Font at iTerm2 > Preferences > Profiles > Text > Non-ASCII font > Hack Regular Nerd Font Complete."

# GPG

Using GPG for signing commits in git.

## Backup keys

```sh
gpg --armor --export > pgp-public-keys.asc
gpg --armor --export-secret-keys > pgp-private-keys.asc
gpg --export-ownertrust > pgp-ownertrust.asc
```

## Restore keys

```sh
gpg --import pgp-public-keys.asc
gpg --import pgp-private-keys.asc
gpg --import-ownertrust pgp-ownertrust.asc
```

## List keys

Public keys:
```sh
gpg -k --keyid-format LONG
```

Private keys:
```sh
gpg -K --keyid-format LONG
```

*Note*: the ID is only listed in `LONG` format (after the slash)

