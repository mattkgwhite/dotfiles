# brew-review

`brew-review` is an interactive Homebrew drift review helper used by this dotfiles repo.

It compares:

- what is currently installed (`brew bundle dump`)
- what is declared in `home/Brewfile`
- what is explicitly ignored in `home/Brewfile.ignore`

## Why it exists

Over time, ad-hoc `brew install` usage can create drift between your machine and the repo's declared package set. `brew-review` helps reconcile that drift so `Brewfile` stays intentional.

## When it runs

The script is wired into chezmoi as an `after` `run_onchange` script:

- `home/.chezmoiscripts/run_onchange_after_brew_review.sh.tmpl`

It runs after apply when the tracked `Brewfile` content changes, and only in interactive sessions (TTY). In non-interactive contexts, it exits silently.

## What it does

For each package installed locally but missing from `Brewfile` (and not ignored), it prompts:

- **add**: append to `Brewfile` and re-sort sections
- **remove**: uninstall the package
- **ignore permanently**: append to `Brewfile.ignore`
- **skip**: do nothing

It also reports packages declared in `Brewfile` but currently missing locally (informational only).

## Manual usage

The executable is managed at:

- `home/dot_scripts/executable_brew-review` (deploys to `~/.scripts/brew-review`)

Basic usage:

```bash
brew-review
```

Optional positional arguments:

```bash
brew-review /path/to/Brewfile /path/to/Brewfile.ignore
```

## Notes

- Sections are sorted by package name while preserving section order.
- Tap removal is handled safely by uninstalling installed tap packages before untapping.
- `Brewfile` and `Brewfile.ignore` in this repo are source-state files (they are not directly deployed into `~/`).
