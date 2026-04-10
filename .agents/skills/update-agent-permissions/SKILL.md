---
name: update-agent-permissions
description: Update shared agent permission overlays and rendering for this chezmoi repo. Use when editing home/.chezmoidata/agent-permissions/*.yaml, schemas/agent-permissions.schema.json, or OpenCode permission template rendering.
---

# Update Agent Permissions

Use this skill when changing agent permission rules in this repo.

## Source of truth

- Canonical layered data: `home/.chezmoidata/agent-permissions/*.yaml`
- Schema: `schemas/agent-permissions.schema.json`
- Render partial: `home/.chezmoitemplates/opencode-permission.tmpl`
- OpenCode config template: `home/dot_config/opencode/opencode.jsonc.tmpl`

Treat `home/.chezmoidata/agent-permissions/*.yaml` as the single source of truth.

## Canonical schema

Rules live under:

- `agentPermissions.kinds` (map, routing and behavior per kind)
- `agentPermissions.rules` (array)

Each rule should follow this shape:

- `kind`: key from `agentPermissions.kinds`
- `pattern`: match pattern string
- `op`: `allow`, `ask`, or `deny`
- optional `conditions` object, matched against global chezmoi data
- optional `bashMatchMode` for kinds with `supportsMatchMode: true`: `exact`, `withArgs`, `exactAndWithArgs`

## Editing rules

1. Keep all permission behavior in `agentPermissions.rules` instead of introducing parallel structures.
2. Keep `agentPermissions.kinds` as the source of truth for destination routing and wildcard behavior, do not hardcode kind-specific destinations in templates.
3. Prefer profile-specific overlays (for example `10-<name>.yaml`) for personal/work-only rules.
4. Keep shared defaults in `00-base.yaml`.
5. Use `conditions` for environment/profile gating, not template-side hardcoded special cases.
6. Do not hand-edit generated OpenCode permission JSON, always edit data + template.

## Bash wildcard rule

OpenCode pattern matching treats bare commands and wildcard command forms distinctly in practice.

- `bashMatchMode: exact` -> emit only `"pattern"`
- `bashMatchMode: withArgs` -> emit only `"pattern *"`
- `bashMatchMode: exactAndWithArgs` -> emit both

Use `exactAndWithArgs` when both should be allowed explicitly.

## Validation workflow

After permission changes:

1. Render `home/dot_config/opencode/opencode.jsonc.tmpl` with current chezmoi data.
2. Confirm expected permission keys are present/absent.
3. Run `tests/source/chezmoi.bats`.
