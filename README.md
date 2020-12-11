# dotfiles
André Milton's dotfiles, managed with [`chezmoi.io`](https://chezmoi.io/).

## Install

Install chezmoi

```
curl -sfL https://git.io/chezmoi | sh
```

Stop auto-update if it's running and has a lock

```
systemctl stop apt-daily.timer
```

Generate an ssh key for this env.

```
ssh-keygen
```

Add key to github account.

Initialize chezmoi and apply

```
chezmoi init https://github.com/Wred/dotfiles.git
chezmoi apply
```


## GPG keys

### Backup

```
gpg --armor --export > pgp-public-keys.asc
gpg --armor --export-secret-keys > pgp-private-keys.asc
gpg --export-ownertrust > pgp-ownertrust.asc
```

### Restore

```
gpg --import pgp-public-keys.asc
gpg --import pgp-private-keys.asc
gpg --import-ownertrust pgp-ownertrust.asc
```