---
name: memory
description: Persist rules, conventions, or lessons into AGENTS.md files so future sessions benefit. Load this skill before writing to global memory (~/.config/opencode/AGENTS.md) or any project AGENTS.md.
---

## The two memory targets

**Global memory** (`~/.config/opencode/AGENTS.md`) — rules that apply to every OpenCode session across every project.
Source: `~/.local/share/chezmoi/home/dot_config/opencode/AGENTS.md`

**Local memory** (`AGENTS.md` in the current project root or nearest ancestor) — rules specific to that codebase.
Source: edit that file directly; it is not managed by chezmoi.

For rules specific to the chezmoi dotfiles repo itself, use `~/.local/share/chezmoi/AGENTS.md`.

## Updating global memory

1. Read `~/.local/share/chezmoi/home/dot_config/opencode/AGENTS.md`.
2. Edit it with the Edit tool. Never write from scratch; always preserve existing content.
3. Run `chezmoi apply` to deploy.
4. Commit and push:

   ```sh
   git -C ~/.local/share/chezmoi add home/dot_config/opencode/AGENTS.md
   git -C ~/.local/share/chezmoi commit -m "chore(opencode): <description>"
   git -C ~/.local/share/chezmoi pull --rebase
   git -C ~/.local/share/chezmoi push
   ```

## Updating local memory

1. Read the project AGENTS.md.
2. Edit it in place with the Edit tool.
3. Commit and push using the project's git repo.

## Quality rules

- Never edit `~/.config/opencode/AGENTS.md` directly; it is managed by chezmoi.
- Never remove existing rules unless explicitly instructed.
- Review nearby rules for contradictions, duplication, and scope conflicts; reconcile in the same edit.
- Keep rules at the narrowest correct scope: cross-cutting rules in global memory, project-specific rules in local memory.
- No em dashes. Use commas, colons, or restructured sentences.
- After committing, always push. Work is not complete until pushed.
