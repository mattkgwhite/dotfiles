# Secrets and sensitive data

This documents how secrets are introduced into the environment and what sensitive material lives where.

## Principle: no secrets in the repo

This repository contains **zero secrets**. No passwords, tokens, API keys, or private key material are committed. Everything in the source state is safe to be public.

Secrets are introduced at runtime through one of three mechanisms:

1. **Bitwarden CLI** (`bw`): for passwords, API keys, and other credentials
2. **Environment variables**: for tokens that vary per machine or session
3. **Manual setup**: for one-time operations like SSH key generation or GPG key import

## Bitwarden integration

chezmoi is configured to use Bitwarden CLI as its secret manager. The config in `.chezmoi.toml.tmpl`:

```toml
[bitwarden]
    command = "bw"
```

This tells chezmoi templates to resolve secrets via `bw get` at apply time. The workflow:

1. Install the Bitwarden CLI: `brew install bitwarden-cli` (included in the Brewfile)
2. Log in: `bw login`
3. Unlock the vault: `export BW_SESSION=$(bw unlock --raw)`
4. Run `chezmoi apply`: templates that reference `bitwarden` will pull secrets from your vault

### Secret introduction order

On a fresh machine, the bootstrap runs in this order:

1. `install.sh` / `install.ps1` installs chezmoi and dependencies
2. `chezmoi init --apply` applies configs
3. Templates that need Bitwarden secrets will fail silently or produce placeholder values if the vault is not unlocked
4. After unlocking Bitwarden, re-run `chezmoi apply` to populate secrets

This means the first apply on a new machine produces a functional but incomplete setup. A second apply after `bw unlock` fills in the secrets.

## GnuPG configuration

The repo manages GnuPG config files under `home/private_dot_gnupg/`:

| Source file | Target | Contents |
|------------|--------|----------|
| `private_gpg.conf` | `~/.gnupg/gpg.conf` | Algorithm preferences, key display settings, smartcard options |
| `private_scdaemon.conf` | `~/.gnupg/scdaemon.conf` | `disable-ccid` (uses the system CCID driver instead of GnuPG's built-in one) |

The `private_` prefix ensures these files are deployed with `0600` permissions (owner read/write only).

### What is NOT in the repo

- No keyrings (`pubring.kbx`, `trustdb.gpg`)
- No private keys
- No revocation certificates
- No `gpg-agent.conf` (uses system defaults)

### GnuPG hardening choices

The `gpg.conf` enforces several security-relevant preferences:

- **SHA-512 as default digest**: `personal-digest-preferences SHA512 SHA384 SHA256`
- **AES-256 as default cipher**: `personal-cipher-preferences AES256 AES192 AES`
- **High s2k iteration count**: `s2k-count 65011712` (strengthens passphrase-derived key stretching)
- **No auto key retrieval**: `auto-key-locate local` and `keyserver-options no-auto-key-retrieve` prevent unintended keyserver traffic
- **Recipient anonymity**: `throw-keyids` omits recipient key IDs from encrypted messages
- **No passphrase caching**: `no-symkey-cache` prevents gpg-agent from caching symmetric passphrases

## Environment variable secrets

Some tools expect secrets as environment variables. These are typically set in shell-local files that are not committed:

- `~/.config/opencode/mcp-atlassian.env`: Atlassian API credentials for the MCP server (only on non-private machines)
- Session-scoped variables like `BW_SESSION` (Bitwarden unlock token)

## Ongoing hygiene

After the initial setup, use `chezmoi verify` to check that managed files match the source state:

```sh
chezmoi verify
```

If files have drifted (edited directly in `~/` instead of through chezmoi), `chezmoi diff` will show what changed and `chezmoi apply` will restore the source state.
