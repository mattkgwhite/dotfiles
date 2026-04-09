---
name: homebrew-management
description: Maintain Homebrew configuration in this chezmoi repo, including Brewfile conventions, brew-review behavior, tap removal workflow, and Brewfile env var rules. Use when editing Brewfile, Brewfile.ignore, or brew-related chezmoiscripts.
---

# Homebrew Management

Use this skill before changing Homebrew-related files in this repo.

## Scope

- `home/Brewfile`
- `home/Brewfile.ignore`
- `home/.chezmoiscripts/run_onchange_after_bootstrap.sh.tmpl`
- `home/.chezmoiscripts/run_onchange_after_brew_review.sh.tmpl`
- `home/dot_scripts/executable_brew-review`
- Related Brewfile references in templates or scripts

## Key conventions

- `home/Brewfile` and `home/Brewfile.ignore` are source-dir only, they are listed in `home/.chezmoiignore` and are not applied to `~/`.
- `run_onchange_after_bootstrap.sh.tmpl` runs `brew bundle install` when Brewfile content changes using a hash trigger comment.
- `run_onchange_after_brew_review.sh.tmpl` runs `brew-review` from `dot_scripts/brew-review`.
- In chezmoiscripts context, `$CHEZMOI_SOURCE_DIR` points at `home/` (the chezmoiroot), so paths should use `dot_scripts/...`.

## Brewfile editing rules

- Keep entries alphabetized within each section (`brew`, `cask`, `mas`).
- Keep commented-out entries sorted inline with active entries by package name.
- Use `if OS.mac?` for macOS-only entries.
- Use `unless ENV["HOMEBREW_CODESPACES"]` for Codespaces-irrelevant entries.
- Do not regenerate the Brewfile wholesale.

## Brewfile env var rule

Homebrew adds a `HOMEBREW_` prefix to env vars in Brewfile Ruby evaluation:

- In scripts, set short env vars before `brew bundle`, for example `CODESPACES=1` or `PRIVATE=1`.
- In Brewfile, read prefixed vars, for example `ENV["HOMEBREW_CODESPACES"]` or `ENV["HOMEBREW_PRIVATE"]`.
- Do not set `HOMEBREW_FOO=1` before `brew bundle`, that becomes `ENV["HOMEBREW_HOMEBREW_FOO"]`.

## brew-review placement

- `brew-review` must stay in `dot_scripts/`, not `dot_zfunctions/`.
- `~/.scripts` is added to PATH via the `path` array in `home/dot_config/zsh/dot_zshenv`.

## Tap removal workflow

When removing a tap:

1. Identify installed formulae and casks from that tap.
2. Uninstall installed formulae and casks from that tap.
3. Untap after uninstalling.

Use tap metadata plus installed-package lists to avoid uninstalling packages that are not installed.

## Script safety

- Do not add `|| true` to `brew update` in scripts.
- Script failures during package management should be treated as real errors.
