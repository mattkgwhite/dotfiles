Dotfiles
===

Configuration files for backup/sync between systems.

## Install

**macOS / Linux**

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/chipwolf/dotfiles/main/install.sh)"
```

**Windows** (PowerShell)

```powershell
irm https://raw.githubusercontent.com/chipwolf/dotfiles/main/install.ps1 | iex
```

### Already have [chezmoi](https://chezmoi.io)?

```sh
chezmoi init --apply https://github.com/chipwolf/dotfiles
```

### Forking

Update the `$repoUrl` variable at the top of `install.ps1` and the `repo_url` variable at the top of `install.sh` to point at your fork.

## SSH key setup

```shell
# Disable YubiKey OTP
ykman config usb -d OTP
# Generate key
ssh-keygen -t ed25519-sk -C "user@domain.tld" -O resident -O verify-required
```
