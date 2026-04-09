---
name: update-mcp-servers
description: Update canonical MCP server definitions for this chezmoi repo, including target overrides and template rendering checks. Use when editing mcp-servers.yaml, Cursor MCP template output, or OpenCode MCP config generation.
---

# Update MCP Servers

Use this skill when changing MCP server configuration in this repo.

## Source of truth

- Canonical server data: `home/.chezmoidata/mcp-servers.yaml`
- Cursor render template: `home/dot_cursor/mcp.json.tmpl`
- OpenCode render template: `home/dot_config/opencode/opencode.jsonc.tmpl`

Treat `mcp-servers.yaml` as the single source of truth. Keep target-specific config only as explicit overrides.

## Canonical schema

Each entry in `mcpServers` should follow this shape:

- `id`, `enabled`
- optional `conditions.requirePrivateFalse`
- `targets.opencode.enabled`
- `targets.cursor.enabled`
- either `local` or `remote`

Local shape:

- `local.command` string
- `local.args` array
- optional `local.env`
- optional `local.appendVaultPath`

Remote shape:

- `remote.url`
- optional `remote.transport`
- optional `remote.headers`

Optional target override shape:

- `targets.opencode.local` or `targets.opencode.remote`
- `targets.cursor.local` or `targets.cursor.remote`

Only include override keys that actually differ from canonical values.

## Editing rules

1. Prefer canonical values over per-target overrides.
2. Keep overrides minimal, only for true target differences.
3. Do not re-introduce duplicate fields like parallel `cursorLocal` and `local`.
4. Keep command execution via `mise` where applicable.

## Validation workflow

After MCP changes:

1. Render `home/dot_cursor/mcp.json.tmpl` with current chezmoi data.
2. Render `home/dot_config/opencode/opencode.jsonc.tmpl` with current chezmoi data.
3. Validate the rendered Cursor MCP output is valid JSON.
4. Confirm expected server entries and args in rendered output.

If templates fail due to missing keys, use `hasKey` checks and safe defaults in templates, do not force duplication in YAML.
