Dotfiles
===

[![SLSA 3](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev)

<!-- start chipwolf/badgesort default -->
[![macOS](https://img.shields.io/badge/macOS-000000.svg?style=for-the-badge&logo=macos&logoColor=white)](#)
[![BadgeSort](https://img.shields.io/badge/BadgeSort-000000.svg?style=for-the-badge&logo=githubsponsors)](https://github.com/ChipWolf/BadgeSort)
[![tmux](https://img.shields.io/badge/tmux-1BB91F.svg?style=for-the-badge&logo=tmux&logoColor=white)](#)
[![Neovim](https://img.shields.io/badge/Neovim-57A143.svg?style=for-the-badge&logo=neovim&logoColor=white)](#)
[![Linux](https://img.shields.io/badge/Linux-FCC624.svg?style=for-the-badge&logo=linux&logoColor=black)](#)
[![Homebrew](https://img.shields.io/badge/Homebrew-FBB040.svg?style=for-the-badge&logo=homebrew&logoColor=black)](#)
[![Git](https://img.shields.io/badge/Git-F05032.svg?style=for-the-badge&logo=git&logoColor=white)](#)
[![Docker](https://img.shields.io/badge/Docker-2496ED.svg?style=for-the-badge&logo=docker&logoColor=white)](#)
[![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF.svg?style=for-the-badge&logo=githubactions&logoColor=white)](#)
[![Bitwarden](https://img.shields.io/badge/Bitwarden-175DDC.svg?style=for-the-badge&logo=bitwarden&logoColor=white)](#)
[![Python](https://img.shields.io/badge/Python-3776AB.svg?style=for-the-badge&logo=python&logoColor=white)](#)
<!-- end chipwolf/badgesort default -->

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

## Provenance

The [Codespaces overlay image](https://ghcr.io/chipwolf/dotfiles) is built with
[SLSA Build L3](https://slsa.dev/spec/v1.0/levels#build-l3) provenance via the
[SLSA GitHub Generator](https://github.com/slsa-framework/slsa-github-generator).
Signing runs in an isolated job that build steps cannot influence, preventing
tampering both during and after the build.

Verify with the [GitHub CLI](https://cli.github.com):

```sh
gh attestation verify oci://ghcr.io/chipwolf/dotfiles:latest --owner chipwolf
```
