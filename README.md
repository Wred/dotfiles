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