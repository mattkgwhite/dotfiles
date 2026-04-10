# Homebrew

Homebrew state in this repo is managed as structured data, not hand-edited Ruby.

## Source of truth

The Homebrew package model lives in:

- `home/.chezmoidata/brew/`

Each file defines one or more overlays under `brew.overlays.<overlay-id>.packages`.

Package entries use structured fields:

- `type`: `tap`, `brew`, `cask`, or `mas`
- `name`: package token
- `masId`: required for `mas`
- `conditions`: optional condition objects (os/env/tty)

Condition objects are one-line maps, for example:

- `{ kind: os, op: is, value: mac }`
- `{ kind: env, name: CODESPACES, op: unset }`
- `{ kind: env, name: PRIVATE, op: set }`
- `{ kind: tty, op: is, value: true }`

## Generation

`home/Brewfile` is generated from:

- template: `home/Brewfile.tmpl`
- data: `home/.chezmoidata/brew/*.yaml`
- all overlays discovered in lexical filename order

Render manually:

```bash
chezmoi execute-template --file home/Brewfile.tmpl > home/Brewfile
```

The template prefixes env conditions with `HOMEBREW_` during render because Homebrew evaluates Brewfile entries in its own bundle context and exposes passed env vars with a `HOMEBREW_` prefix (for example, script `CODESPACES=1` becomes Brewfile `ENV["HOMEBREW_CODESPACES"]`).

## Runtime usage

Bootstrap script:

- `home/.chezmoiscripts/run_onchange_after_bootstrap.sh.tmpl`

It runs `brew bundle --file="$CHEZMOI_SOURCE_DIR/Brewfile"` with short env vars:

- `CODESPACES=1` for Codespaces
- `PRIVATE=1` for private machines

Homebrew itself evaluates these as `ENV["HOMEBREW_CODESPACES"]` and `ENV["HOMEBREW_PRIVATE"]` inside Brewfile Ruby.

## brew-review

`brew-review` is an interactive drift-review helper:

- script: `home/dot_scripts/executable_brew-review`
- deployed path: `~/.scripts/brew-review`
- orchestration script: `home/.chezmoiscripts/run_onchange_after_brew_review.sh.tmpl`

It compares:

- installed set (`brew bundle dump`)
- declared set (`home/Brewfile`)
- ignore set (`home/Brewfile.ignore`)

For installed-but-undeclared packages, prompts:

- **add**: choose an overlay file, append a structured package entry there, then regenerate `home/Brewfile`
- **remove**: uninstall package
- **ignore permanently**: append key to `home/Brewfile.ignore`
- **skip**: no action

Installed formulae/casks from taps are removed before untapping.

## Validation

Source tests include `tests/source/brewfile.bats` which verify:

- rendered Brewfile is valid Ruby
- rendered output matches the checked-in `home/Brewfile`
- expected env-prefix and condition formatting semantics
