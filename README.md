# dotfiles
André Milton's dotfiles, managed with [`chezmoi.io`](https://chezmoi.io/).

## Install

# Ubuntu
To install on Ubuntu 20.04:

Install chezmoi
```
snap install chezmoi --classic
```

Stop auto-update if it's running and has a lock
```
systemctl stop apt-daily.timer
```

Install git
```
sudo apt-get install git
```

Initialize chezmoi and apply
```
chezmoi init --apply --verbose git@github.com:Wred/dotfiles.git
```


## GPG

Using GPG for signing commits in git.

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

### Backup keys

```sh
gpg --armor --export > pgp-public-keys.asc
gpg --armor --export-secret-keys > pgp-private-keys.asc
gpg --export-ownertrust > pgp-ownertrust.asc
```

### Restore keys

```sh
gpg --import pgp-public-keys.asc
gpg --import pgp-private-keys.asc
gpg --import-ownertrust pgp-ownertrust.asc
```