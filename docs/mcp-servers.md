# MCP Servers (How To)

Use this file to manage MCP servers:

- [`home/.chezmoidata/mcp-servers.yaml`](../home/.chezmoidata/mcp-servers.yaml)

Chezmoi renders that into:

- Cursor config via [`home/dot_cursor/mcp.json.tmpl`](../home/dot_cursor/mcp.json.tmpl)
- OpenCode config via [`home/dot_config/opencode/opencode.jsonc.tmpl`](../home/dot_config/opencode/opencode.jsonc.tmpl)

## Quick Start

### Add a remote server

```yaml
- id: context7
  enabled: true
  targets:
    cursor: {}
    opencode: {}
  remote:
    url: "https://mcp.context7.com/mcp"
```

### Add a local server

```yaml
- id: obsidian
  enabled: true
  targets:
    cursor: {}
    opencode: {}
  local:
    command: "mise"
    args:
      - "x"
      - "node@22"
      - "--"
      - "npx"
      - "-y"
      - "@mauricio.wolff/mcp-obsidian@0.8.2"
    env: {}
```

## Common Tasks

### Disable a server for one client

`targets.*.enabled` defaults to `true`. Only set `false` when needed.

```yaml
targets:
  cursor:
    enabled: false
  opencode: {}
```

### Show a server only on certain machines

Use `conditions` to match global chezmoi data keys from [`home/.chezmoi.toml.tmpl`](../home/.chezmoi.toml.tmpl).

```yaml
conditions:
  private: false
```

This means the server is rendered only when `.private == false`.

### Interpolate data values in args

Use `$data.<key>` tokens in `args` when a local command needs values from global data in [`home/.chezmoi.toml.tmpl`](../home/.chezmoi.toml.tmpl).

In this repo:

- Key source: [`home/.chezmoi.toml.tmpl`](../home/.chezmoi.toml.tmpl) defines `obsidianVaultPath` in `[data]`
- Server usage: [`home/.chezmoidata/mcp-servers.yaml`](../home/.chezmoidata/mcp-servers.yaml) uses `$data.obsidianVaultPath` for the `obsidian` server

```yaml
local:
  command: "mise"
  args: ["x", "node@22", "--", "npx", "-y", "@mauricio.wolff/mcp-obsidian@0.8.2", "$data.obsidianVaultPath"]
```

If `obsidianVaultPath` exists in template data, `$data.obsidianVaultPath` resolves to that value.

Rendered result (example):

```json
{
  "command": "mise",
  "args": [
    "x",
    "node@22",
    "--",
    "npx",
    "-y",
    "@mauricio.wolff/mcp-obsidian@0.8.2",
    "/home/wolf/Documents/Obsidian/Vault"
  ]
}
```

In other words, each `$data.<key>` token is replaced inline in the final argument list.

## Fields

### Top-level server fields

- `id`: unique server id, used as the rendered key in Cursor/OpenCode MCP config.
- `enabled`: whether this server is rendered at all.
- `conditions` (optional): key/value filters matched against global chezmoi data from [`home/.chezmoi.toml.tmpl`](../home/.chezmoi.toml.tmpl) (for example `private: false`).
- `targets`: where this server should appear.
  - `targets.cursor.enabled` (optional): default `true`, set `false` to hide from Cursor.
  - `targets.opencode.enabled` (optional): default `true`, set `false` to hide from OpenCode.
- `local` or `remote`: exactly one transport block per server.

### `local` transport fields

- `command` (required): command to run the MCP process.
- `args` (required): command arguments.
- `env` (optional): environment variables for the process.
- `args` supports inline `$data.<key>` tokens, replaced from [`home/.chezmoi.toml.tmpl`](../home/.chezmoi.toml.tmpl) at render time.

### `remote` transport fields

- `url` (required): remote MCP URL.
- `transport` (optional): transport mode; defaults to `streamableHttp` in Cursor template rendering.
- `headers` (optional): HTTP headers map for remote calls.

Field requirements are validated by [`schemas/mcp-servers.schema.json`](../schemas/mcp-servers.schema.json).

## Validate Changes

1. Render both templates with `chezmoi execute-template`.
2. Validate rendered Cursor MCP JSON.
3. Run `pre-commit run --all-files` (on Windows, run via WSL in this repo).
