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

## SSH key setup

```shell
# Disable YubiKey OTP
ykman config usb -d OTP
# Generate key
ssh-keygen -t ed25519-sk -C "user@domain.tld" -O resident -O verify-required
```
