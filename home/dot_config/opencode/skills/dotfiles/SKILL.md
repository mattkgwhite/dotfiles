---
name: dotfiles
description: Make changes to chezmoi-managed dotfiles: adding, modifying, or removing config files, scripts, and templates in the source state. Load this skill before touching anything under ~/.local/share/chezmoi/.
---

## Key paths

- **Chezmoi repo:** `~/.local/share/chezmoi/` (git repo, branch `main`)
- **Source state root:** `~/.local/share/chezmoi/home/` (set by `.chezmoiroot`)
- **Target:** `~/`

Never edit files under `~/` directly when they are chezmoi-managed. Always edit the source under `~/.local/share/chezmoi/home/` then run `chezmoi apply`.

## Source state naming conventions

Files under `home/` use chezmoi source state attributes:

| Prefix | Effect |
|--------|--------|
| `dot_` | Adds a leading dot to the target name (`dot_gitconfig` -> `~/.gitconfig`) |
| `private_` | Target has no group/world permissions |
| `executable_` | Target is executable |
| `run_` | Script run on every apply |
| `run_once_` | Script run once per content hash |
| `run_onchange_` | Script run when content changes |
| `before_` / `after_` | With `run_*`: run before or after updating files |

| Suffix | Effect |
|--------|--------|
| `.tmpl` | Content is a Go text/template |

Directories follow the same attribute rules (`dot_config/` -> `~/.config/`). Scripts in `home/.chezmoiscripts/` do not create a target directory.

When unsure about an attribute, consult https://www.chezmoi.io/reference/source-state-attributes/ rather than guessing.

## Workflow: adding or modifying a managed file

1. Edit the source file in `~/.local/share/chezmoi/home/` using the Edit or Write tool.
2. Run `chezmoi diff` to verify the change looks correct.
3. Run `chezmoi apply` to deploy.
4. Commit and push:
   ```
   git -C ~/.local/share/chezmoi add <path>
   git -C ~/.local/share/chezmoi commit -m "<type>(<scope>): <description>"
   git -C ~/.local/share/chezmoi pull --rebase
   git -C ~/.local/share/chezmoi push
   ```

## Workflow: removing a managed file

Deleting a source file does NOT remove the deployed target automatically. To fully remove:

1. Add the target path to `home/.chezmoiremove` (or use another documented chezmoi removal mechanism).
2. Delete the source file from `home/`.
3. Run `chezmoi apply` — chezmoi removes the deployed target.

Do not manually delete files from `~/` before the chezmoi removal is recorded and applied.

## Templating

Templates use Go `text/template` plus sprig and chezmoi-specific functions. Common data:

- `.chezmoi.os` — OS name (`darwin`, `linux`, `windows`)
- `.chezmoi.hostname` — machine hostname
- `.chezmoi.homeDir` — home directory path
- `.codespaces` — bool, set from env in `home/.chezmoi.toml.tmpl`
- `.private` — bool, true when `~/.private` exists (personal machine; excludes work-only configs like Atlassian MCP)

Run `chezmoi data` to inspect all available template data on the current machine.

Shared template fragments go in `home/.chezmoitemplates/<name>.tmpl` and are invoked with `{{ template "<name>.tmpl" . }}`.

## OS-conditional ignores

`home/.chezmoiignore` uses template blocks to control which targets deploy per platform:

```
{{ if eq .chezmoi.os "windows" }}
# unix-only targets
{{ end }}
{{ if ne .chezmoi.os "windows" }}
# windows-only targets
{{ end }}
```

When adding a new config, decide if it is cross-platform, Unix-only, or Windows-only, and update `.chezmoiignore` accordingly.

## Bash chezmoiscripts: OS guards

- Bash scripts (`.sh.tmpl`) must be wrapped in `{{ if ne .chezmoi.os "windows" }}...{{ end }}`.
- PowerShell scripts (`.ps1.tmpl`) must be wrapped in `{{ if eq .chezmoi.os "windows" }}...{{ end }}`.
- Scripts that render to empty are skipped by chezmoi automatically.

## Homebrew / Brewfile conventions

- `home/Brewfile` and `home/Brewfile.ignore` are source-dir only (listed in `.chezmoiignore`).
- Entries are alphabetised within each section (`brew`, `cask`, `mas`).
- Commented-out entries are sorted inline with active lines by package name (case-insensitive).
- Darwin-only entries use `if OS.mac?` conditionals.
- Codespaces-irrelevant entries use `unless ENV["HOMEBREW_CODESPACES"]`.
- Homebrew renames env vars before `brew bundle` by adding the `HOMEBREW_` prefix. Set short names in scripts (`CODESPACES=1 brew bundle`); access prefixed names in Brewfile (`ENV["HOMEBREW_CODESPACES"]`). Never set `HOMEBREW_FOO=1` in scripts.
- When removing a tap, uninstall all installed formulae/casks from it first, then untap.
- `brew update` in scripts must NOT have `|| true`.
- The `brew-review` script lives in `dot_scripts/` (not `dot_zfunctions/`), deployed to `~/.scripts/`.
- `$CHEZMOI_SOURCE_DIR` in script context points to `home/` (the chezmoiroot).

## Repo-specific layout

- **Zsh:** `home/dot_config/zsh/` — `dot_zshrc`, `dot_zshenv`, `dot_zprofile`, `dot_zplugins`, `dot_zshrc.d/`, `dot_zfunctions/`, `dot_p10k.zsh`. Top-level `home/dot_zshenv` and `home/dot_profile` set `ZDOTDIR`/`XDG_CONFIG_HOME`.
- **Neovim:** `home/dot_config/nvim/` (LazyVim-style).
- **OpenCode config:** `home/dot_config/opencode/opencode.jsonc.tmpl`.
- **OpenCode global rules:** `home/dot_config/opencode/AGENTS.md` — edit here, not at `~/.config/opencode/AGENTS.md`.
- **WezTerm:** `home/dot_config/wezterm/wezterm.lua` — Windows only (ignored on non-Windows).
- **Scripts:** `home/dot_scripts/` — deployed to `~/.scripts/` which is on PATH.

## Commit conventions

- Semantic format: `type(scope): description`. Types: `feat`, `fix`, `chore`.
- Check `git -C ~/.local/share/chezmoi log --oneline -5` before committing to match existing style.
- After committing, always push. Work is not complete until pushed.
- Before committing, run `git diff --staged` and confirm the change is atomic and in-scope.

## Constraints

- Never edit files under `~/.config/` directly; always edit the chezmoi source and apply.
- Scripts should be idempotent.
- When `chezmoi apply` triggers a brew bundle run (via an onchange script), treat it as fire-and-forget. Do not wait on the background process.
- Never use em dashes. Use commas, colons, or restructured sentences instead.
- Do not update AGENTS.md files here. Load the `memory` skill for that.
