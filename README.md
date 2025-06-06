# dotfiles
André Milton's dotfiles, managed with [`chezmoi.io`](https://chezmoi.io/).

# Preflight

You'll need to have an ssh key and gpg keys set up in Github.  The initialization will ask for the gpg key ID (see List Keys below).

# Install

## Ubuntu
To install on Ubuntu 20.04:

```sh
snap install chezmoi --classic
systemctl stop apt-daily.timer
sudo apt-get install git
chezmoi init --apply --verbose git@github.com:Wred/dotfiles.git
```

*Note*: the stop for the apt service seems necessary to remove the lock likely taken by auto-update before installing git

## Arch
To install on Manjaro-i3 (https://manjaro.org/downloads/community/i3/):

```sh
pacman -S --noconfirm chezmoi
chezmoi init --apply --verbose https://github.com/Wred/dotfiles.git
```

## Mac
To install on MacOS, install Homebrew:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the instructions to add `brew` to the path etc.

Install `gpupg` with brew to generate a key (see below) and don't forget to generate an ssh key and add to Github.  You'll also need to fix the gpg config to point to gpg-agent to the correct pinentry (see https://stackoverflow.com/questions/39494631/gpg-failed-to-sign-the-data-fatal-failed-to-write-commit-object-git-2-10-0):

```sh
echo "pinentry-program $(brew --prefix)/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
killall gpg-agent
```

Install `chezmoi`:

```sh
brew install chezmoi
chezmoi init --apply --verbose git@github.com:Wred/dotfiles.git
```

# Postflight

Install the tmux packages using `prefix-I` to start the tpm install.
Set the Neovim theme with `<leader> th`.

# GPG

Using GPG for signing commits in git.

## Create keys

You can do this on a new machine:

```sh
gpg --full-generate-key
```


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

## Add keys to Github account

To output the ASCII armor format to copy/paste into Github:

```sh
gpg --armor --export KEYID
```

## Renewing keys

GPG keys expire (set when you create them).  To renew, find the key and edit:

```sh
$ gpg --list-keys
$ gpg --edit-key KEYID
```

Use the expire command to set a new expire date:

```sh
gpg> expire
```    

When prompted type `1y` or however long you want the key to last for.

Select all the subkeys (the primary key, which we just set the expires date for, is key 0):

```sh
gpg> key 1
gpg> key 2
gpg> expire
```

A star will sppear before all selected keys.

Since the key has changed we now need to trust it, otherwise we get the error "There is no assurance this key belongs to the named user" when using they key:

```sh
gpg> trust
```

When done, save:

```sh
gpg> save
```


## Test key

Test it out, do a round trip:

```sh
gpg -ea > secret.out
gpg -d secret.out
```

## Key mapping

### Ubuntu

Had a hell of a time finding a way to map escape and control to capslock *on linux* and
include it in this dotfiles repo.  So for now just do it manually from here:

https://github.com/rvaiya/keyd

Add a file `/etc/keyd/default.conf`:

```
[ids]

*

[main]

capslock = overload(control, esc)
```

### Windows

Use: https://github.com/ililim/dual-key-remap
