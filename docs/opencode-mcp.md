# OpenCode MCP servers

This documents the MCP (Model Context Protocol) servers configured in OpenCode and what each one can access.

## What is MCP?

MCP servers give the AI coding agent (OpenCode) access to external tools and data sources. Each server exposes a set of tools that the agent can call during a session. The configuration lives in `home/dot_config/opencode/opencode.jsonc.tmpl`.

## Trust surface

Every MCP server is a trust boundary. When enabled, the server's tools can be invoked by the AI agent during your session. The permission system in `opencode.jsonc.tmpl` controls which tools require approval and which run automatically.

### Permission model

The config uses a layered permission system:

| Pattern | Policy | Meaning |
|---------|--------|---------|
| `bash: "*"` | `ask` | All shell commands require approval by default |
| `bash: "git status"` | `allow` | Specific read-only commands are pre-approved |
| `atlassian_*` | `ask` | All Atlassian tools require approval by default |
| `atlassian_get*` | `allow` | Read-only Atlassian tools are pre-approved |

The most specific matching pattern wins. This means read-only operations generally run without prompting, while write operations always ask.

## Configured servers

### Always enabled (all machines)

#### Obsidian (`obsidian`)

- **Type**: local process
- **Runtime**: Node.js via mise
- **Package**: `@mauricio.wolff/mcp-obsidian`
- **Access**: read/write to the Obsidian vault at `~/Documents/Obsidian/Vault`
- **Trust**: runs locally, accesses only the vault directory

#### Chrome DevTools (`chrome-devtools`)

- **Type**: local process
- **Runtime**: Node.js via mise
- **Package**: `chrome-devtools-mcp`
- **Access**: browser automation and debugging of open Chrome tabs
- **Trust**: runs locally, can interact with any page open in Chrome

#### Context7 (`context7`)

- **Type**: remote
- **URL**: `https://mcp.context7.com/mcp`
- **Access**: retrieves up-to-date library documentation for use in prompts
- **Trust**: read-only external service. Queries are sent to Context7's API. No local data is shared beyond the query itself.

#### grep.app (`grep`)

- **Type**: remote
- **URL**: `https://mcp.grep.app`
- **Access**: searches public GitHub repositories by code pattern
- **Trust**: read-only external service. Searches public code only. No local data is shared beyond the search query.

### Work machines only (`private = false`)

These servers are excluded on personal machines (Windows, or any machine with `~/.private`).

#### Atlassian Rovo (`atlassian`)

- **Type**: remote
- **URL**: `https://mcp.atlassian.com/v1/mcp`
- **Auth**: OAuth 2.1 via `opencode mcp auth atlassian`
- **Access**: Jira issues, Confluence pages, Compass services
- **Trust**: authenticated access to your Atlassian workspace. Read-only tools are pre-approved; write tools require approval per invocation.

#### mcp-atlassian / sooperset (`mcp-atlassian`)

- **Type**: local process
- **Runtime**: Python via mise + uvx
- **Package**: `mcp-atlassian` (sooperset)
- **Auth**: credentials from `~/.config/opencode/mcp-atlassian.env`
- **Access**: full Jira tool suite including issue creation, linking, and updates
- **Trust**: runs locally but authenticates to Atlassian APIs. Credentials are stored in a local env file (not committed). Read-only tools are pre-approved; write tools require approval.

## What the `private` flag controls

| `private` | Atlassian Rovo | mcp-atlassian | Atlassian permissions |
|-----------|:--------------:|:-------------:|:---------------------:|
| `false` (work) | enabled | enabled | configured |
| `true` (personal) | excluded | excluded | excluded |

On personal machines, the Atlassian servers and their permission entries are completely removed from the generated config. They are not just disabled: the template conditionally omits them entirely.

## Adding a new MCP server

1. Edit `home/dot_config/opencode/opencode.jsonc.tmpl` in the chezmoi source.
2. Add the server config in the `"mcp"` object.
3. If it should only run on certain machines, wrap it in `{{- if ... }}` / `{{- end }}` template guards.
4. Add permission entries in the `"permission"` object. Default to `"ask"` for write operations.
5. Run `chezmoi apply` to deploy the updated config.

## Reviewing active servers

To see what MCP servers are currently configured in your deployed config:

```sh
cat ~/.config/opencode/opencode.jsonc
```

The deployed file has all template conditionals resolved, so it shows exactly what is active on your machine.
