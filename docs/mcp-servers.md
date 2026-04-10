# MCP Servers (How To)

MCP server configuration follows the same layered-data pattern as Brew.

Source files:

- `home/.chezmoidata/mcps/*.yaml` (canonical overlays, merged lexically)
- schema: `schemas/mcp-servers.schema.json`

Rendered outputs:

- Cursor via `home/dot_cursor/mcp.json.tmpl`
- OpenCode via `home/dot_config/opencode/opencode.jsonc.tmpl`

## Data shape

Each overlay contributes to:

```yaml
mcp:
  serversById:
    <server-id>:
      enabled: true
      local: ... # or remote: ...
```

`serversById` is a map keyed by server id. This enables clean layered overrides across multiple YAML files.

## Quick start

### Add a remote server

```yaml
mcp:
  serversById:
    context7:
      enabled: true
      remote:
        url: "https://mcp.context7.com/mcp"
```

### Add a local server

```yaml
mcp:
  serversById:
    obsidian:
      enabled: true
      local:
        command: "mise"
        args:
          - "x"
          - "node@22"
          - "--"
          - "npx"
          - "-y"
          - "@mauricio.wolff/mcp-obsidian@0.8.2"
          - "$data.obsidianVaultPath"
        env: {}
```

## Common tasks

### Disable a server

```yaml
mcp:
  serversById:
    atlassian:
      enabled: false
```

### Disable a server for one client only

```yaml
mcp:
  serversById:
    mcp-atlassian:
      enabled: true
      targets:
        cursor:
          enabled: false
        opencode: {}
```

### Show a server only on certain machines

Use `conditions` against global chezmoi data (for example from `home/.chezmoi.toml.tmpl`):

```yaml
conditions:
  private: false
```

### Interpolate data values in args

Use `$data.<key>` in `local.args`; template rendering replaces tokens inline.

## Field reference

Per-server fields under `mcp.serversById.<id>`:

- `enabled` (required)
- `conditions` (optional)
- `targets` (optional). When omitted, server is enabled for both clients by default.
- `targets.cursor.enabled` / `targets.opencode.enabled` (optional, default `true`)
- exactly one of `local` or `remote`

`local` fields:

- `command` (required)
- `args` (required)
- `env` (optional)

`remote` fields:

- `url` (required)
- `transport` (optional)
- `headers` (optional)

## Validation

1. Render both templates with `chezmoi execute-template`.
2. Validate rendered Cursor MCP JSON.
3. Run `pre-commit run --all-files` (on Windows run via WSL in this repo).
