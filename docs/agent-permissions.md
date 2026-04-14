# Agent Permissions (How To)

Agent permission rules are managed as layered chezmoi data, then rendered into OpenCode config.

Source files:

- `home/.chezmoidata/agent-permissions/*.yaml` (overlays merged lexically)
- schema: `schemas/agent-permissions.schema.json`

Rendered output:

- OpenCode config via `home/dot_config/opencode/opencode.jsonc.tmpl`

## Data shape

Each overlay contributes to:

```yaml
agentPermissions:
  kinds:
    bash:
      destinationType: namespaced
      destinationKey: bash
      supportsMatchMode: true
      defaultMatchMode: exact
      wildcardSuffix: " *"
    external_directory:
      destinationType: namespaced
      destinationKey: external_directory
    permission_key:
      destinationType: top_level
  rules:
    - kind: bash
      pattern: "git status"
      op: allow
      bashMatchMode: exactAndWithArgs
```

All rule types share the same schema. Kind routing is data-driven via `agentPermissions.kinds`.

## Kind configuration

`agentPermissions.kinds` controls where each rule kind is rendered:

- `destinationType: namespaced` -> rule emits into `permission.<destinationKey>`
- `destinationType: top_level` -> rule emits at top level of `permission`
- `supportsMatchMode` + `defaultMatchMode` + `wildcardSuffix` control wildcard expansion behavior for that kind

Rules then reference a configured kind by `kind`.

## Rule fields

Supported rule fields:

- `kind` (required): key from `agentPermissions.kinds`
- `pattern` (required): match string
- `op` (required): `allow`, `ask`, or `deny`
- `conditions` (optional): key/value match against template data (for example `private: false`)
- `bashMatchMode` (optional, `kind: bash` only): `exact`, `withArgs`, or `exactAndWithArgs`

## Rule kinds

### `bash`

Generates entries inside `"permission"."bash"`.

`bashMatchMode` controls exact and wildcard emission:

- `exact` -> `"pattern"`
- `withArgs` -> `"pattern *"`
- `exactAndWithArgs` -> both keys

This exists because OpenCode glob matching does not treat `"cmd *"` as equivalent to bare `"cmd"` for all cases.

### `external_directory`

Generates entries inside `"permission"."external_directory"`:

```yaml
- kind: external_directory
  pattern: "~/.local/share/chezmoi/**"
  op: allow
```

### `permission_key`

Generates top-level permission keys (same level as `bash`/`external_directory`), useful for MCP tool patterns:

```yaml
- kind: permission_key
  pattern: "atlassian_*"
  op: ask
  conditions:
    private: false
```

## Overlay strategy

Use the same split pattern as Brew and MCP:

- `00-base.yaml`: shared defaults
- `10-<profile>.yaml`: personal/work/fork-specific rules

In this repo, Atlassian-specific permission keys live in `home/.chezmoidata/agent-permissions/10-chipwolf.yaml`.

## Validation

1. Render OpenCode config with `chezmoi execute-template`.
2. Run test suite (`tests/source/chezmoi.bats`).
3. Run `pre-commit run --all-files` before commit.

