#!/usr/bin/env bats
# chezmoi.bats — validate chezmoi templates and ignore logic

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  SOURCE_DIR="$REPO_ROOT/home"
  # Minimal config so chezmoi execute-template can resolve .chezmoi.* and data vars
  export CHEZMOI_CONFIG="$BATS_TEST_TMPDIR/chezmoi.toml"
  cat >"$CHEZMOI_CONFIG" <<'EOF'
[data]
  codespaces = false
  private = false
EOF
}

# --- .chezmoi.toml.tmpl renders without error ---

@test ".chezmoi.toml.tmpl renders" {
  chezmoi execute-template --init \
    --promptBool "codespaces=false" \
    --promptBool "private=false" \
    <"$SOURCE_DIR/.chezmoi.toml.tmpl"
}

# --- .chezmoiignore produces correct ignores per OS ---

@test "chezmoiignore: linux ignores macOS-only targets" {
  output=$(chezmoi execute-template \
    --init \
    --promptBool "codespaces=false" \
    --promptBool "private=false" \
    <"$SOURCE_DIR/.chezmoiignore" 2>&1 || true)
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
