# YubiKey SSH setup

This documents the full workflow for setting up SSH authentication with a YubiKey FIDO2 resident key. This is optional: it only applies if you use a YubiKey for SSH.

## Requirements

- YubiKey 5 series or later (must support FIDO2 resident keys)
- OpenSSH 8.2+ (for `ed25519-sk` key type)
- `ykman` (YubiKey Manager CLI), installed via Homebrew: `brew install ykman`

## Initial YubiKey configuration

### Disable OTP

The OTP slot on YubiKeys triggers when you accidentally touch the key, pasting a one-time password into whatever has focus. Disable it if you do not use OTP:

```shell
ykman config usb -d OTP
```

### Set a FIDO2 PIN

A FIDO2 PIN is required before you can create resident keys. If you have not set one yet:

```shell
ykman fido access change-pin
```

You will be prompted to enter and confirm a new PIN. This PIN is used for `verify-required` operations (see below).

## Generate a resident key

```shell
ssh-keygen -t ed25519-sk -C "user@domain.tld" -O resident -O verify-required
```

What the flags do:

| Flag                   | Purpose                                                                         |
| ---------------------- | ------------------------------------------------------------------------------- |
| `-t ed25519-sk`        | Use the Ed25519 algorithm with a FIDO2 security key                             |
| `-C "user@domain.tld"` | Comment to identify the key (use your email)                                    |
| `-O resident`          | Store the key handle on the YubiKey itself, making it portable between machines |
| `-O verify-required`   | Require PIN entry on each use, not just a physical touch                        |

This creates two files:

- `~/.ssh/id_ed25519_sk`: the private key stub (a reference to the key on the YubiKey, not the actual private key)
- `~/.ssh/id_ed25519_sk.pub`: the public key (add this to GitHub, servers, etc.)

## Recovering keys on a new machine

Because the key is resident (stored on the YubiKey), you can regenerate the key stub on any machine:

```shell
ssh-keygen -K
```

This downloads all resident credentials from the YubiKey into the current directory as `id_ed25519_sk_rk*` files. Move them to `~/.ssh/` and set permissions:

```shell
mv id_ed25519_sk_rk* ~/.ssh/
chmod 600 ~/.ssh/id_ed25519_sk_rk
chmod 644 ~/.ssh/id_ed25519_sk_rk.pub
```

## Backup key strategy

A single YubiKey is a single point of failure. If you lose it, you lose SSH access to every service that only has that key registered.

Options:

1. **Two YubiKeys**: generate a resident key on each, register both public keys everywhere. Keep the backup in a safe location.
2. **Fallback key type**: keep a traditional `ed25519` key (encrypted, stored securely) as a break-glass credential registered on critical services.
3. **GitHub recovery codes**: always save your GitHub account recovery codes separately from your YubiKey.

## Credential hygiene

- Rotate your FIDO2 PIN periodically. Use `ykman fido access change-pin` to change it.
- List registered credentials with `ykman fido credentials list` to audit what is stored on the key.
- Delete credentials you no longer use: `ykman fido credentials delete <credential>`.
- If a YubiKey is lost or compromised, remove its public key from all services and revoke it from your GitHub account immediately.

## `verify-required` vs touch-only

| Mode                 | What happens on use                                               |
| -------------------- | ----------------------------------------------------------------- |
| Touch-only (default) | YubiKey blinks, you touch it, authentication proceeds             |
| `verify-required`    | YubiKey blinks, you enter your FIDO2 PIN, authentication proceeds |

`verify-required` is stronger: a stolen YubiKey cannot be used without the PIN. The tradeoff is that you type the PIN on every SSH operation (git push, scp, ssh, etc.).
