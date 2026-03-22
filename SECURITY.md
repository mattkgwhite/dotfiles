# Security

This document describes the trust model for this dotfiles repository.

## What is committed

This repo contains configuration files, shell scripts, and templates. **No secrets, private keys, passwords, or tokens are committed.** Secrets are introduced at runtime via Bitwarden CLI (`bw`), environment variables, or manual setup (see [docs/secrets.md](docs/secrets.md)).

GnuPG configuration (`private_dot_gnupg/`) contains only `gpg.conf` and `scdaemon.conf`, which set algorithm preferences and smartcard behavior. No keyrings or private key material are stored in the repo.

## Bootstrap trust model

The install scripts are designed to be fetched and executed in a single command:

```sh
# macOS / Linux
sh -c "$(curl -fsSL https://raw.githubusercontent.com/chipwolf/dotfiles/main/install.sh)"

# Windows (PowerShell)
irm https://raw.githubusercontent.com/chipwolf/dotfiles/main/install.ps1 | iex
```

### What this means for trust

- Both scripts are fetched over HTTPS from the `main` branch of this repository.
- They are **not pinned by hash or commit SHA**. Anyone with write access to `main` can change what gets executed.
- They are **not individually signed or attested**. There is no way to verify the script content came from a specific author or build pipeline.
- `curl | sh` and `irm | iex` execute arbitrary code from the network. This is standard practice for dotfiles repos but requires you to trust the repository owner and GitHub's transport security.

### Windows-specific considerations

`irm | iex` (Invoke-RestMethod piped to Invoke-Expression) has the same trust properties as `curl | sh`: it fetches and executes code in a single step. Additionally:

- The Windows bootstrap script installs Chocolatey, which itself uses `irm | iex` for its installer.
- The script runs `choco install` for each package, which downloads and installs binaries from the Chocolatey community repository.
- PowerShell's execution policy does not protect against `irm | iex` since the code is never written to disk as a `.ps1` file.

### Safer alternative

If you prefer to inspect before executing, use chezmoi directly:

```sh
chezmoi init https://github.com/chipwolf/dotfiles
chezmoi diff
chezmoi apply
```

This clones the repo, lets you review the diff, and only applies after your explicit confirmation. You still need to install chezmoi first, but this avoids running an unreviewed script.

## Container image provenance

The [Codespaces overlay image](https://ghcr.io/chipwolf/dotfiles) is the one artifact with formal provenance. It is built with [SLSA Build L3](https://slsa.dev/spec/v1.0/levels#build-l3) via the [SLSA GitHub Generator](https://github.com/slsa-framework/slsa-github-generator). The signing job runs in isolation from the build steps, preventing tampering during or after the build.

Verify the image:

```sh
gh attestation verify oci://ghcr.io/chipwolf/dotfiles:latest --owner chipwolf
```

### Trust asymmetry

The SLSA attestation covers **only the container image**. It does not cover:

- The bootstrap scripts (`install.sh`, `install.ps1`)
- The chezmoi source state (templates, configs, run scripts)
- Packages installed by Homebrew, Chocolatey, or mise

This means the Codespaces fast path (which uses the attested image) has a stronger trust guarantee than the standard bootstrap path (which fetches and runs scripts from `main`).

## Reporting vulnerabilities

If you find a security issue in this repository, open a GitHub issue or contact the repository owner directly. This is a personal dotfiles repo, not a production service, so there is no formal disclosure process.
