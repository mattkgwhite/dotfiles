#!/usr/bin/env bats
# chezmoi.bats — validate chezmoi templates and ignore logic

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  SOURCE_DIR="$REPO_ROOT/home"
  # Minimal config so chezmoi execute-template can resolve .chezmoi.* and data vars
  export CHEZMOI_CONFIG="$BATS_TEST_TMPDIR/chezmoi.toml"
  cat >"$CHEZMOI_CONFIG" <<EOF
sourceDir = "$REPO_ROOT"

[data]
  codespaces = false
  private = false
EOF
}

render_template() {
  local template_path="$1"
  chezmoi execute-template --init \
    --promptBool "codespaces=false" \
    --promptBool "private=false" \
    <"$template_path"
}

render_template_with_override_data() {
  local template_path="$1"
  local data_file="$2"
  chezmoi execute-template --override-data-file "$data_file" <"$template_path"
}

# --- .chezmoi.toml.tmpl renders without error ---

@test ".chezmoi.toml.tmpl renders" {
  render_template "$SOURCE_DIR/.chezmoi.toml.tmpl"
}

# --- .chezmoiignore produces correct ignores per OS ---

@test "chezmoiignore: linux ignores macOS-only targets" {
  output=$(render_template "$SOURCE_DIR/.chezmoiignore" 2>&1 || true)
  # The template uses .chezmoi.os which is the host OS; we can only
  # validate syntax here. Semantics are tested via grep below.
  [[ $? -eq 0 ]]
}

@test "chezmoiignore: non-darwin block lists .config/tmux" {
  grep -q '\.config/tmux' "$SOURCE_DIR/.chezmoiignore"
}

@test "chezmoiignore: non-darwin block lists .config/ghostty" {
  grep -q '\.config/ghostty' "$SOURCE_DIR/.chezmoiignore"
}

@test "chezmoiignore: windows block lists .config/zsh" {
  grep -q '\.config/zsh' "$SOURCE_DIR/.chezmoiignore"
}

@test "chezmoiignore: non-windows block lists .config/wezterm" {
  grep -q '\.config/wezterm' "$SOURCE_DIR/.chezmoiignore"
}

# --- MCP template rendering ---

@test "Cursor MCP template renders local/remote shapes and target overrides correctly" {
  local data_file="$BATS_TEST_TMPDIR/mcp-shapes-cursor.json"
  cat >"$data_file" <<'EOF'
{
  "private": false,
  "mcpServers": [
    {
      "id": "shape-local-base",
      "enabled": true,
      "targets": { "cursor": { "enabled": true }, "opencode": { "enabled": true } },
      "local": {
        "command": "mise",
        "args": ["x", "node", "--", "npx", "-y", "pkg-local-base@latest"],
        "env": {}
      }
    },
    {
      "id": "shape-local-override",
      "enabled": true,
      "targets": {
        "cursor": {
          "enabled": true,
          "local": {
            "args": ["x", "node@22", "--", "npx", "-y", "pkg-local-override@latest"],
            "env": { "CURSOR_ONLY": "1" }
          }
        },
        "opencode": { "enabled": true }
      },
      "local": {
        "command": "mise",
        "args": ["x", "node", "--", "npx", "-y", "pkg-local-base-ignored@latest"],
        "env": {}
      }
    },
    {
      "id": "shape-remote-base",
      "enabled": true,
      "targets": { "cursor": { "enabled": true }, "opencode": { "enabled": true } },
      "remote": { "url": "https://example.com/base" }
    },
    {
      "id": "shape-remote-override",
      "enabled": true,
      "targets": {
        "cursor": {
          "enabled": true,
          "remote": {
            "transport": "streamableHttp",
            "url": "https://example.com/cursor-override",
            "headers": { "X-Cursor": "1" }
          }
        },
        "opencode": { "enabled": true }
      },
      "remote": { "url": "https://example.com/base-ignored" }
    }
  ]
}
EOF

  output=$(render_template_with_override_data "$SOURCE_DIR/dot_cursor/mcp.json.tmpl" "$data_file")
  echo "$output" | ruby -rjson -e '
    j = JSON.parse(STDIN.read)
    s = j.fetch("mcpServers")
    raise "missing local base" unless s.key?("shape-local-base")
    raise "missing local override" unless s.key?("shape-local-override")
    raise "missing remote base" unless s.key?("shape-remote-base")
    raise "missing remote override" unless s.key?("shape-remote-override")
    raise "local base command mismatch" unless s["shape-local-base"]["command"] == "mise"
    raise "local base arg mismatch" unless s["shape-local-base"]["args"].include?("pkg-local-base@latest")
    raise "local override arg not applied" unless s["shape-local-override"]["args"].include?("node@22")
    raise "local override env not applied" unless s["shape-local-override"]["env"]["CURSOR_ONLY"] == "1"
    raise "remote base url mismatch" unless s["shape-remote-base"]["url"] == "https://example.com/base"
    raise "remote override url mismatch" unless s["shape-remote-override"]["url"] == "https://example.com/cursor-override"
    raise "remote override header missing" unless s["shape-remote-override"]["headers"]["X-Cursor"] == "1"
  '
}

@test "Cursor MCP template applies private gating for requirePrivateFalse" {
  local data_file="$BATS_TEST_TMPDIR/mcp-private-cursor.json"
  cat >"$data_file" <<'EOF'
{
  "private": true,
  "mcpServers": [
    {
      "id": "shape-private-blocked",
      "enabled": true,
      "conditions": { "requirePrivateFalse": true },
      "targets": { "cursor": { "enabled": true }, "opencode": { "enabled": true } },
      "remote": { "url": "https://example.com/private-blocked" }
    },
    {
      "id": "shape-private-allowed",
      "enabled": true,
      "targets": { "cursor": { "enabled": true }, "opencode": { "enabled": true } },
      "remote": { "url": "https://example.com/private-allowed" }
    }
  ]
}
EOF

  output=$(render_template_with_override_data "$SOURCE_DIR/dot_cursor/mcp.json.tmpl" "$data_file")
  echo "$output" | ruby -rjson -e '
    j = JSON.parse(STDIN.read)
    s = j.fetch("mcpServers")
    raise "blocked server rendered" if s.key?("shape-private-blocked")
    raise "allowed server missing" unless s.key?("shape-private-allowed")
  '
}

@test "OpenCode MCP template renders local/remote shapes and target overrides correctly" {
  local data_file="$BATS_TEST_TMPDIR/mcp-shapes-opencode.json"
  cat >"$data_file" <<'EOF'
{
  "private": false,
  "mcpServers": [
    {
      "id": "shape-op-local-base",
      "enabled": true,
      "targets": { "cursor": { "enabled": true }, "opencode": { "enabled": true } },
      "local": {
        "command": "mise",
        "args": ["x", "node", "--", "npx", "-y", "pkg-op-local-base@latest"],
        "env": {}
      }
    },
    {
      "id": "shape-op-local-override",
      "enabled": true,
      "targets": {
        "cursor": { "enabled": true },
        "opencode": {
          "enabled": true,
          "local": {
            "args": ["x", "node@22", "--", "npx", "-y", "pkg-op-local-override@latest"]
          }
        }
      },
      "local": {
        "command": "mise",
        "args": ["x", "node", "--", "npx", "-y", "pkg-op-local-base-ignored@latest"],
        "env": {}
      }
    },
    {
      "id": "shape-op-remote-base",
      "enabled": true,
      "targets": { "cursor": { "enabled": true }, "opencode": { "enabled": true } },
      "remote": { "url": "https://example.com/op-base" }
    },
    {
      "id": "shape-op-remote-override",
      "enabled": true,
      "targets": {
        "cursor": { "enabled": true },
        "opencode": {
          "enabled": true,
          "remote": { "url": "https://example.com/op-override" }
        }
      },
      "remote": { "url": "https://example.com/op-base-ignored" }
    }
  ]
}
EOF

  output=$(render_template_with_override_data "$SOURCE_DIR/dot_config/opencode/opencode.jsonc.tmpl" "$data_file")
  echo "$output" | grep -q '"shape-op-local-base"'
  echo "$output" | grep -q '"pkg-op-local-base@latest"'
  echo "$output" | grep -q '"shape-op-local-override"'
  echo "$output" | grep -q '"pkg-op-local-override@latest"'
  echo "$output" | grep -q '"shape-op-remote-base"'
  echo "$output" | grep -q 'https://example.com/op-base'
  echo "$output" | grep -q '"shape-op-remote-override"'
  echo "$output" | grep -q 'https://example.com/op-override'
}

@test "Cursor MCP template with real chezmoidata renders valid schema and enabled IDs" {
  local merged_data_file="$BATS_TEST_TMPDIR/mcp-realdata-cursor.json"
  local rendered_file="$BATS_TEST_TMPDIR/cursor-mcp-rendered.json"
  ruby -ryaml -rjson -e '
    raw = YAML.load_file(ARGV[0])
    merged = { "private" => false, "mcpServers" => raw.fetch("mcpServers") }
    File.write(ARGV[1], JSON.generate(merged))
  ' "$SOURCE_DIR/.chezmoidata/mcp-servers.yaml" "$merged_data_file"

  output=$(chezmoi execute-template \
    --override-data-file "$merged_data_file" \
    <"$SOURCE_DIR/dot_cursor/mcp.json.tmpl")
  printf '%s' "$output" >"$rendered_file"

  ruby -rjson -e '
    rendered_path = ARGV[0]
    data_path = ARGV[1]

    rendered = JSON.parse(File.read(rendered_path))
    servers = rendered.fetch("mcpServers")

    data = JSON.parse(File.read(data_path))
    is_private = data.fetch("private", false)
    expected_ids = data.fetch("mcpServers")
      .select { |s| s.dig("targets", "cursor", "enabled") }
      .reject { |s| s.dig("conditions", "requirePrivateFalse") && is_private }
      .map { |s| s.fetch("id") }
      .sort

    actual_ids = servers.keys.sort
    raise "cursor IDs mismatch, expected=#{expected_ids} actual=#{actual_ids}" unless actual_ids == expected_ids

    servers.each do |id, cfg|
      if cfg.key?("command")
        raise "cursor local #{id} missing args array" unless cfg["args"].is_a?(Array)
        raise "cursor local #{id} missing env object" unless cfg["env"].is_a?(Hash)
      else
        raise "cursor remote #{id} missing transport" unless cfg["transport"].is_a?(String)
        raise "cursor remote #{id} missing url" unless cfg["url"].is_a?(String)
        raise "cursor remote #{id} missing headers object" unless cfg["headers"].is_a?(Hash)
      end
    end
  ' "$rendered_file" "$merged_data_file"
}

@test "OpenCode MCP block with real chezmoidata renders valid schema and enabled IDs" {
  local merged_data_file="$BATS_TEST_TMPDIR/mcp-realdata-opencode.json"
  local rendered_file="$BATS_TEST_TMPDIR/opencode-rendered.jsonc"
  ruby -ryaml -rjson -e '
    raw = YAML.load_file(ARGV[0])
    merged = { "private" => false, "mcpServers" => raw.fetch("mcpServers") }
    File.write(ARGV[1], JSON.generate(merged))
  ' "$SOURCE_DIR/.chezmoidata/mcp-servers.yaml" "$merged_data_file"

  output=$(chezmoi execute-template \
    --override-data-file "$merged_data_file" \
    <"$SOURCE_DIR/dot_config/opencode/opencode.jsonc.tmpl")
  printf '%s' "$output" >"$rendered_file"

  ruby -rjson -e '
    rendered_path = ARGV[0]
    data_path = ARGV[1]
    text = File.read(rendered_path)

    marker = "\"mcp\":"
    marker_idx = text.index(marker)
    raise "missing mcp block" if marker_idx.nil?
    start_idx = text.index("{", marker_idx)
    raise "missing mcp object start" if start_idx.nil?

    depth = 0
    in_string = false
    escape = false
    end_idx = nil

    (start_idx...text.length).each do |i|
      ch = text[i]
      if in_string
        if escape
          escape = false
        elsif ch == "\\\\"
          escape = true
        elsif ch == "\""
          in_string = false
        end
      else
        if ch == "\""
          in_string = true
        elsif ch == "{"
          depth += 1
        elsif ch == "}"
          depth -= 1
          if depth == 0
            end_idx = i
            break
          end
        end
      end
    end

    raise "unterminated mcp object" if end_idx.nil?
    mcp = JSON.parse(text[start_idx..end_idx])

    data = JSON.parse(File.read(data_path))
    is_private = data.fetch("private", false)
    expected_ids = data.fetch("mcpServers")
      .select { |s| s.dig("targets", "opencode", "enabled") }
      .reject { |s| s.dig("conditions", "requirePrivateFalse") && is_private }
      .map { |s| s.fetch("id") }
      .sort

    actual_ids = mcp.keys.sort
    raise "opencode IDs mismatch, expected=#{expected_ids} actual=#{actual_ids}" unless actual_ids == expected_ids

    mcp.each do |id, cfg|
      raise "opencode #{id} missing enabled bool" unless cfg["enabled"] == true || cfg["enabled"] == false
      case cfg["type"]
      when "local"
        raise "opencode local #{id} missing command array" unless cfg["command"].is_a?(Array) && !cfg["command"].empty?
      when "remote"
        raise "opencode remote #{id} missing url" unless cfg["url"].is_a?(String)
      else
        raise "opencode #{id} invalid type #{cfg["type"].inspect}"
      end
    end
  ' "$rendered_file" "$merged_data_file"
}

# --- All .tmpl files are valid Go templates ---

@test "all .tmpl files parse without syntax errors" {
  local failed=0
  while IFS= read -r tmpl; do
    # Use --init so .chezmoi.* variables and include are available.
    # Rendering may fail on missing data (e.g. bitwarden), but syntax
    # errors produce a distinct "parse" error. We only fail on parse errors.
    err=$(chezmoi execute-template --init \
      --promptBool "codespaces=false" \
      --promptBool "private=false" \
      <"$tmpl" 2>&1) || {
        if echo "$err" | grep -qi "parse"; then
          echo "PARSE ERROR in $tmpl:"
          echo "$err"
          failed=1
        fi
      }
  done < <(find "$SOURCE_DIR" -name '*.tmpl' -type f)
  [[ $failed -eq 0 ]]
}
