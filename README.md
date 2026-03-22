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

Personal, opinionated dotfiles managed with [chezmoi](https://chezmoi.io). One repo configures macOS (primary), Linux, Windows, and GitHub Codespaces. The bootstrap scripts install dependencies, apply configs, and get a new machine to a working state in a single command.

This is not a framework or a starter kit. It is one person's daily-driver setup, shared publicly. If you fork it, expect to replace most of the personal choices before using it.

## What you get

| Tool | What it does |
|------|-------------|
| **zsh + Powerlevel10k** | Shell and prompt |
| **Neovim (LazyVim)** | Editor |
| **tmux** | Terminal multiplexer |
| **Homebrew** | Package manager (macOS/Linux) |
| **mise** | Polyglot runtime manager (node, python, go, etc.) |
| **WezTerm** | Terminal emulator (Windows) |
| **Kitty** | Terminal emulator (macOS/Linux) |
| **Ghostty** | Terminal emulator (macOS/Linux) |
| **OpenCode** | AI coding agent |
| **k9s** | Kubernetes TUI |
| **Finicky** | macOS default browser router |
| **GnuPG** | Encryption and signing |
| **Git** | Version control config |
| **Oh My Posh** | Prompt engine (Windows) |

### Platform matrix

Not everything deploys everywhere. chezmoi's ignore rules control what lands on each OS.

| | macOS | Linux | Windows | Codespaces |
|---|:---:|:---:|:---:|:---:|
| zsh + Powerlevel10k | x | x | | x |
| Neovim (LazyVim) | x | x | x | x |
| tmux | x | x | | x |
| Homebrew | x | x | | x |
| mise | x | x | x | x |
| WezTerm | | | x | |
| Oh My Posh | | | x | |
| Kitty | x | x | | |
| Ghostty | x | x | | |
| Finicky | x | | | |
| GnuPG | x | x | | |
| Git | x | x | x | x |
| OpenCode | x | x | x | x |
| k9s | x | x | x | x |

---

## Install

**macOS / Linux**

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/chipwolf/dotfiles/main/install.sh)"
```

**Windows** (PowerShell, elevated)

```powershell
irm https://raw.githubusercontent.com/chipwolf/dotfiles/main/install.ps1 | iex
```

### What happens

1. The script installs chezmoi (and Homebrew on macOS/Linux, Chocolatey on Windows, if missing).
2. chezmoi clones this repo and applies the config to your home directory.
3. On macOS/Linux, `brew bundle` installs packages from the Brewfile. On Windows, `choco install` handles packages.
4. mise installs managed runtimes. Neovim syncs plugins.

> [!IMPORTANT]
> chezmoi does not delete your existing files. It writes managed targets alongside whatever is already there. If a managed file conflicts with an existing one, chezmoi will overwrite it. Run `chezmoi diff` before `chezmoi apply` to see exactly what would change.

### Preview before applying

If you want to inspect everything first:

```sh
chezmoi init https://github.com/chipwolf/dotfiles
chezmoi diff
chezmoi apply
```

### Prerequisites

The bootstrap scripts install most dependencies automatically. You need:

- **macOS/Linux:** `curl` or `wget`, and a POSIX shell. Everything else (Homebrew, chezmoi, packages) is installed for you.
- **Windows:** PowerShell 5+. The script installs Chocolatey, chezmoi, and git.

---

## Template flags

chezmoi templates use two boolean flags to adapt behavior per machine. These are set automatically in `.chezmoi.toml.tmpl`:

| Flag | When it is true | What it gates |
|------|----------------|---------------|
| `codespaces` | `CODESPACES` env var is set | Skips GUI apps and redundant packages in the Brewfile. Uses the overlay fast path in `install.sh`. |
| `private` | Windows, or `~/.private` exists | Enables personal-machine config: excludes work-specific MCP servers and Atlassian integrations from OpenCode. |

To mark a macOS or Linux machine as private, `touch ~/.private` before running `chezmoi apply`.

---

## Codespaces

When you enable a personal dotfiles repo in your [GitHub Codespaces settings](https://github.com/settings/codespaces), GitHub clones this repo into each new codespace and runs `install.sh`.

This repo ships a pre-baked [overlay container image](https://ghcr.io/chipwolf/dotfiles) on GHCR. When `install.sh` detects `CODESPACES=1`, it pulls only the overlay layers that differ from the base devcontainer image and extracts them directly, skipping the full bootstrap. The result is the same setup, provisioned faster.

> [!IMPORTANT]
> Dotfiles changes only apply to new codespaces. Existing codespaces keep their current state unless you rebuild them.

---

## Forking and customization

This is a personal setup. If you fork it, here is what to change first:

1. **`install.sh` and `install.ps1`**: update `repo_url` / `$repoUrl` to your fork.
2. **`home/.chezmoi.toml.tmpl`**: review the `private` and `codespaces` logic. You may want different conditions.
3. **`home/Brewfile`**: replace the package list with your own.
4. **`home/dot_config/`**: this is where most tool configs live. Replace or remove what you do not use.
5. **`.macos`**: macOS system defaults (verbose boot, Safari auditing). Review and edit or delete.
6. **Git identity**: update `home/dot_config/git/` with your name, email, and signing key.

> [!TIP]
> The chezmoi source state lives under `home/` (set by `.chezmoiroot`). Filenames use chezmoi's attribute prefixes: `dot_` becomes a leading `.`, `private_` restricts permissions, `executable_` adds the execute bit. For example, `home/dot_config/nvim/` deploys to `~/.config/nvim/`.

### Updating after install

To pull the latest changes from the repo and re-apply:

```sh
chezmoi update
```

---

## SSH key setup (optional)

If you use a YubiKey for SSH authentication, the quick version:

```shell
ykman config usb -d OTP
ykman fido access change-pin
ssh-keygen -t ed25519-sk -C "user@domain.tld" -O resident -O verify-required
```

For the full workflow (backup keys, credential hygiene, recovery on new machines), see [docs/yubikey.md](docs/yubikey.md).

---

## Provenance [![SLSA 3](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev)

The [Codespaces overlay image](https://ghcr.io/chipwolf/dotfiles) is built with [SLSA Build L3](https://slsa.dev/spec/v1.0/levels#build-l3) provenance via the [SLSA GitHub Generator](https://github.com/slsa-framework/slsa-github-generator). Signing runs in an isolated job that build steps cannot influence, preventing tampering both during and after the build.

> [!WARNING]
> SLSA provenance covers the container image only. The bootstrap scripts (`install.sh`, `install.ps1`) are fetched over HTTPS from the `main` branch and are not individually signed or pinned by hash. Review them before running. No secrets or private key material are committed to this repository.

Verify the container image:

```sh
gh attestation verify oci://ghcr.io/chipwolf/dotfiles:latest --owner chipwolf
```

For the full trust model (bootstrap scripts, `irm | iex`, what is and is not attested), see [SECURITY.md](SECURITY.md).

---

## Further reading

| Document | Contents |
|----------|----------|
| [SECURITY.md](SECURITY.md) | Trust model, bootstrap script trust, container image provenance |
| [docs/yubikey.md](docs/yubikey.md) | Full YubiKey SSH workflow, backup strategy, credential hygiene |
| [docs/secrets.md](docs/secrets.md) | Bitwarden integration, GnuPG config, secret introduction order |
| [docs/opencode-mcp.md](docs/opencode-mcp.md) | MCP server inventory, trust surface, permission model |
