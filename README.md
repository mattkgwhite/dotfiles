Dotfiles
===

<!-- start chipwolf/badgesort default -->
[![macOS](https://img.shields.io/badge/macOS-000000.svg?style=for-the-badge&logo=macos&logoColor=white)](#)
[![BadgeSort](https://img.shields.io/badge/BadgeSort-000000.svg?style=for-the-badge&logo=githubsponsors)](https://github.com/ChipWolf/BadgeSort)
[![Windows](https://img.shields.io/badge/Windows-0078D4.svg?style=for-the-badge&logo=windows&logoColor=white)](#)
[![tmux](https://img.shields.io/badge/tmux-1BB91F.svg?style=for-the-badge&logo=tmux&logoColor=white)](#)
[![Neovim](https://img.shields.io/badge/Neovim-57A143.svg?style=for-the-badge&logo=neovim&logoColor=white)](#)
[![Linux](https://img.shields.io/badge/Linux-FCC624.svg?style=for-the-badge&logo=linux&logoColor=black)](#)
[![Homebrew](https://img.shields.io/badge/Homebrew-FBB040.svg?style=for-the-badge&logo=homebrew&logoColor=black)](#)
[![Git](https://img.shields.io/badge/Git-F05032.svg?style=for-the-badge&logo=git&logoColor=white)](#)
<!-- end chipwolf/badgesort default -->

Cross-platform dotfiles managed with [chezmoi](https://chezmoi.io). Covers macOS (primary), Linux, Windows, and GitHub Codespaces. For Codespaces, GitHub can install this repo as your dotfiles repo on every new codespace, and this project also ships a pre-baked overlay image to make that path faster.

**Includes:** zsh + Powerlevel10k · Neovim (LazyVim) · tmux · Homebrew · mise · WezTerm · Kitty · Ghostty · OpenCode · k9s · Finicky · GnuPG · Git

---

## Install

**macOS / Linux**

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/chipwolf/dotfiles/main/install.sh)"
```

**Windows** (PowerShell)

```powershell
irm https://raw.githubusercontent.com/chipwolf/dotfiles/main/install.ps1 | iex
```

> [!NOTE]
> The install script bootstraps chezmoi, clones this repo, and applies the config. On macOS/Linux it also installs Homebrew and runs `brew bundle`.

### Already have [chezmoi](https://chezmoi.io)?

```sh
chezmoi init --apply https://github.com/chipwolf/dotfiles
```

> [!TIP]
> To inspect before applying: `chezmoi init https://github.com/chipwolf/dotfiles && chezmoi diff && chezmoi apply`

### Forking

Update `$repoUrl` in `install.ps1` and `repo_url` in `install.sh` to point at your fork.

> [!IMPORTANT]
> Most personalisation lives in the chezmoi templates. Review `.chezmoi.toml.tmpl` (machine-specific data), `home/Brewfile` (packages), and the `dot_config/` subtree. `private` is enabled on personal machines, including Windows, and `codespaces` is enabled automatically inside GitHub Codespaces.

## Codespaces

GitHub Codespaces supports a personal dotfiles repository. When enabled in your GitHub Codespaces settings, GitHub clones this repo into each new codespace and runs `install.sh` automatically.

> [!TIP]
> Enable it at `https://github.com/settings/codespaces`, turn on **Automatically install dotfiles**, then select this repository.

> [!NOTE]
> This repo detects `CODESPACES=1` and uses a pre-baked overlay image for faster provisioning. It applies the same dotfiles, but skips the slow path where a fresh codespace would otherwise run the full bootstrap from scratch.

> [!IMPORTANT]
> Dotfiles changes only apply to new codespaces. Existing codespaces keep their current state unless you rebuild or recreate them.

---

## SSH key setup (YubiKey-backed FIDO2 resident key)

```shell
# Disable YubiKey OTP to prevent accidental triggers
ykman config usb -d OTP
# Set a FIDO2 PIN before generating resident keys
ykman fido access change-pin
# Generate a FIDO2 resident key with PIN verification required at each use
ssh-keygen -t ed25519-sk -C "user@domain.tld" -O resident -O verify-required
```

> [!NOTE]
> Requires a YubiKey 5 series or later. `verify-required` means you'll be prompted for your FIDO2 PIN on each use, not just a touch.

---

## Provenance [![SLSA 3](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev)

The [Codespaces overlay image](https://ghcr.io/chipwolf/dotfiles) is built with
[SLSA Build L3](https://slsa.dev/spec/v1.0/levels#build-l3) provenance via the
[SLSA GitHub Generator](https://github.com/slsa-framework/slsa-github-generator).
Signing runs in an isolated job that build steps cannot influence, preventing
tampering both during and after the build.

> [!WARNING]
> SLSA provenance covers the container image only. The bootstrap scripts (`install.sh`, `install.ps1`) are fetched over HTTPS and are not individually signed, review them before running.

Verify the container image with the [GitHub CLI](https://cli.github.com):

```sh
gh attestation verify oci://ghcr.io/chipwolf/dotfiles:latest --owner chipwolf
```
