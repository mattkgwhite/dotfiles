---
name: python-toolchain
description: Rules for running Python, pip, uv, and mise correctly in this environment. Load this skill before any Python work or when unsure how to invoke a Python tool.
---

## Core rule

Never run `python`, `python3`, `pip`, `pip3`, `uv`, or `uvx` directly. All Python toolchain commands go through `mise`.

## Running commands

| Task                    | Command                                      |
|-------------------------|----------------------------------------------|
| Ad hoc Python command   | `mise x -- uv run --no-project python ...`   |
| Run a script            | `mise x -- uv run <script>`                  |
| Run with extra deps     | `mise x -- uv run --with <package> <script>` |
| Install project dep     | `mise x -- uv add <package>`                 |
| Install global CLI tool | `mise x -- uv tool install <package>`        |

- Prefer `mise x -- <command>` for ad hoc commands.
- Use `mise run <task>` for project tasks when available.

## Project bootstrap

Before project-scoped uv commands, ensure the directory has a `pyproject.toml` and `.python-version`. If missing, run `mise x -- uv init .` first.

For uv projects, the project `.venv` is auto-created or sourced via `python.uv_venv_auto = "create|source"` in the global mise config. Do not create or activate virtualenvs manually.

Never use `--break-system-packages`.

## Shims (why direct invocation is blocked)

When OpenCode spawns a shell, `OPENCODE=1` is set. The `.zshenv` PATH prepends `~/.local/share/opencode-shims`, which contains shims for `python`, `python3`, `pip`, `pip3`, `uv`, and `uvx`. Each shim checks whether it was invoked via `mise`; if not, it blocks with an error.

- Do not prefix commands with any wrapper. Shims are injected via PATH automatically.
- Do not modify files in `~/.local/share/opencode-shims/`.
