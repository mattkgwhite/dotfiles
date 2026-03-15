# Global agent rules

These rules apply to **all** OpenCode sessions, across every project.

---

## Two-level rule system

OpenCode loads rules from two locations:

| Level | File | Scope |
|-------|------|-------|
| **Global** | `~/.config/opencode/AGENTS.md` | Every session, every project |
| **Project** | `AGENTS.md` in the project root (or nearest ancestor) | That project only |

Use `~/.config/opencode/AGENTS.md` for rules that should apply universally — personal preferences, workflow conventions, and cross-cutting principles.

Use a project-level `AGENTS.md` for rules specific to that codebase: language conventions, repo layout, build commands, etc.

---

## Never guess schemas or APIs

When working with any configuration schema (Kubernetes, Talos, Helm values, etc.), always read the authoritative source before writing config. Acceptable sources, in order of preference:

1. The actual Go struct definitions or JSON schema from the project source (clone the repo if needed)
2. The official rendered documentation
3. The project's own example files in the same repo

Never trust: blog posts, AI-generated examples, or partial memory of a schema. A wrong key name wastes more time than the lookup takes. This applies even when you are fairly confident -- verify before writing.

If a documentation site does not render usefully via WebFetch, clone the source repo and read the struct tags directly.

---

## Continuous maintenance (meta-rule)

- After every substantive conversation, review whether `~/.config/opencode/AGENTS.md` or the relevant project `AGENTS.md` needs updating.
- Add a rule when a user corrects agent behavior or establishes a new pattern — write it down so the next session benefits.
- Never remove rules without explicit user confirmation.
- Never silently adopt a convention that isn't written down.
- Keep `~/.config/opencode/AGENTS.md` concise. If it grows unwieldy, propose splitting into topic files.

---

## Global memory and local memory

The user refers to `~/.config/opencode/AGENTS.md` as **global memory**. When asked to "commit something to global memory":

1. Edit the chezmoi source at `~/.local/share/chezmoi/home/dot_config/opencode/AGENTS.md`
2. Run `chezmoi apply`

Never edit `~/.config/opencode/AGENTS.md` directly — it is managed by chezmoi and will be overwritten.

The user refers to the `AGENTS.md` in the current project root (or nearest ancestor) as **local memory**. When asked to "commit something to local memory", edit that file directly.

The same chezmoi rule applies to all dotfiles under `~/.config/` — always edit the source in `~/.local/share/chezmoi/` and apply from there.

For rules specific to the chezmoi dotfiles repo itself, edit `~/.local/share/chezmoi/AGENTS.md` instead.

---

## Writing style

- Never use em dashes (---, &mdash;, or the Unicode character —). Use a comma, colon, or restructure the sentence instead. This applies at the point of writing — do not generate em dashes and fix them later. Treat this as a hard constraint during composition, not a post-hoc linting step.

---

## Daily note logging

When something is achieved during a session (a task completed, a ticket updated, a document published, etc.), check whether today's daily note exists in Obsidian before asking. Only ask if the note already exists. Use the `question` tool to ask — not plain text. Only add it if they confirm. Use the Obsidian Tasks format for action items and plain bullets for logged achievements, following vault conventions.

---

## Post-task retrospective and self-improvement

After completing any non-trivial task, perform a brief critical retrospective before closing out:

1. **What went right:** note any approaches or tools that worked well.
2. **What went wrong:** identify mistakes, incorrect assumptions, wasted steps, or anything that required correction.
3. **Actionable lessons:** for each thing that went wrong, determine whether a rule change would prevent it recurring. If yes, update global memory immediately (edit the chezmoi source and apply). Do not defer this.

The retrospective does not need to be verbose. A single sentence per point is enough. The goal is that each session leaves global memory slightly better than it found it. Silent self-improvement is acceptable; only surface the retrospective to the user if a rule was added or if the user would benefit from knowing.

This rule applies retroactively: if a session ends without a retrospective, perform one before the final response.

---

## Problem-solving attitude

Never suggest the user accept a limitation, take a shortcut, or move on when a proper solution may exist. Keep investigating until the problem is actually solved. Suggesting workarounds as a final answer is not acceptable.

---

## Atlassian Jira — writing ticket content

When writing content to Jira tickets via the Atlassian MCP (descriptions, comments, etc.):

- Reference other Jira tickets using the plain key format: `KEY-123` (e.g. `SEC-105`, `ONW-476`). Jira auto-resolves bare keys to smart links in the rendered UI.
- Do **not** use the `JIRA:KEY-123` prefix — that is an Obsidian-specific convention for the Jira plugin and will appear as literal text in Jira.
- Jira Cloud uses Atlassian Document Format (ADF) for rich text. When passing content via MCP tools, prefer plain text or ADF-structured input as required by the tool — do not use Confluence/Jira wiki markup (e.g. `h2.`, `||`, `{code}`) unless the tool explicitly expects it.
- In Obsidian notes, continue to use `JIRA:KEY-123` as per vault conventions.

---

## Browsing code in git repositories

When you need to read source code from a public or private git repository, clone it locally with `git clone` first. Do not curl GitHub API endpoints, fetch raw file URLs, or use the GitHub web UI to browse code. Cloning is faster, more reliable, and gives full access to the entire codebase. This applies even for a single file lookup.

---

## Toolchain execution policy (mise required)

When a runtime or CLI can be managed by `mise`, agents must run it through `mise`.

- Prefer `mise x -- <command>` (or `mise exec ... -- <command>`) for ad hoc commands.
- Use `mise run <task>` for project tasks when available.
- Do not call managed toolchains directly when a `mise` invocation is possible.

## Python package management (mise + uv required)

Python workflows must use `mise` and `uv` together.

- Never run `python`, `python3`, `pip`, `pip3`, or raw `uv` directly.
- Run Python commands as `mise x -- uv ...` (or `mise exec ... -- uv ...`).
- Install project dependencies with `mise x -- uv add <package>`.
- Install global Python CLI tools with `mise x -- uv tool install <package>`.
- Run scripts with dependencies using `mise x -- uv run --with <package> <script-or-command>`.
- For one-shot Python commands outside a uv project, use `mise x -- uv run --no-project python ...`.
- Before project-scoped uv commands, ensure the directory is bootstrapped by uv (`pyproject.toml` and `.python-version`). If missing, run `mise x -- uv init .` first.
- Never use `--break-system-packages`.

For uv projects, rely on global mise config to auto source or create the project `.venv` via `python.uv_venv_auto = "create|source"`.

---

## Python guard (shell.env shims)

When OpenCode spawns a shell, it sets `OPENCODE=1` natively. The `.zshenv` PATH array detects this and conditionally prepends `~/.local/share/opencode-shims`, which contains shims for `python`, `python3`, `pip`, `pip3`, `uv`, and `uvx`. Each shim checks `$_` to see if it was invoked via `mise`; if not, it blocks with an error.

- Do not prefix commands with `wolf` or any other wrapper. Shims are injected via PATH automatically.
- Do not modify files in `~/.local/share/opencode-shims/`.

---

## Commit discipline

Before committing, run `git diff --staged` and make an objective assessment of whether the change is both atomic and in-scope based on the context of the request. Do not commit unrelated changes that happened to be modified in the working tree.

Commit messages use semantic commit format: `type(scope): description`. Types: `feat`, `fix`, `chore`. Scope is optional but use it when relevant. Always check `git log --oneline` before committing to match the repo's existing style.

---

## Directory access behavior

- Do not run proactive directory existence checks before path operations (for example, `ls /tmp` before writing to `/tmp`).
- Attempt the intended operation first.
- If it fails because a directory is missing, create the directory and retry.
- Only do a pre-check when a tool explicitly requires it.
