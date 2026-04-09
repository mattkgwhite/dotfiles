# MCP Server Configuration

This repo defines MCP servers in one canonical file:

- `home/.chezmoidata/mcp-servers.yaml`

That data is rendered into:

- Cursor: `home/dot_cursor/mcp.json.tmpl`
- OpenCode: `home/dot_config/opencode/opencode.jsonc.tmpl`

## Design Rules

- Single transport config per server, use either `local` or `remote`.
- No per-target transport overrides under `targets`.
- `targets` only controls enablement per client (`cursor` and `opencode`).
- Template logic should trust schema-required fields.

## Server Shape

Each `mcpServers` entry has:

- `id` (server id)
- `enabled` (boolean)
- optional `conditions` (generic key/value matches against global chezmoi data)
- `targets.cursor.enabled`
- `targets.opencode.enabled`
- one of:
  - `local` with required `command` and `args`, optional `env`, optional `appendDataArgs`
  - `remote` with required `url`, optional `transport`, optional `headers`

## Conditions

`conditions` are evaluated against the root template data object. A server is included only when all condition key/value pairs match.

Example:

```yaml
conditions:
  private: false
```

This means the server only renders when `.private` is `false` in chezmoi data.

## appendDataArgs

For local servers, `appendDataArgs` appends values from global template data to the command args list.

Example:

```yaml
local:
  command: "mise"
  args: ["x", "node@22", "--", "npx", "-y", "@mauricio.wolff/mcp-obsidian@0.8.2"]
  appendDataArgs:
    - "obsidianVaultPath"
```

If `obsidianVaultPath` exists in template data, its value is appended to `args`.

## Validation

Schema:

- `schemas/mcp-servers.schema.json`

Recommended checks after changes:

1. Render both templates with `chezmoi execute-template`.
2. Validate rendered Cursor MCP JSON.
3. Run `pre-commit run --all-files` (on Windows, run via WSL in this repo).
