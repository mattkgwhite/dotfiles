#!/usr/bin/env bats
# brewfile.bats — Brewfile structure and guard validation

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  BREWFILE="$REPO_ROOT/home/Brewfile"
  BREWFILE_TMPL="$REPO_ROOT/home/Brewfile.tmpl"
}

# --- Brewfile parses as valid Ruby ---

@test "Brewfile is valid Ruby syntax" {
  ruby -c "$BREWFILE"
}

# --- All active cask entries require OS.mac? ---

@test "all active cask entries have 'if OS.mac?' guard" {
  local failed=0
  while IFS= read -r line; do
    if ! echo "$line" | grep -q 'if OS\.mac?'; then
      echo "Missing OS.mac? guard: $line"
      failed=1
    fi
  done < <(grep -E '^cask ' "$BREWFILE")
  [[ $failed -eq 0 ]]
}

# --- tmux formula is gated to macOS ---

@test "tmux brew entry includes macOS guard" {
  line=$(grep -E '^brew "tmux"' "$BREWFILE")
  echo "$line" | grep -Fq 'OS.mac?'
}

# --- Brewfile template rendering ---

render_brewfile_template() {
  chezmoi execute-template <"$BREWFILE_TMPL"
}

@test "Brewfile template renders valid Ruby syntax" {
  run render_brewfile_template
  [ "$status" -eq 0 ]
  printf "%s\n" "$output" >"$BATS_TEST_TMPDIR/Brewfile.rendered"
  ruby -c "$BATS_TEST_TMPDIR/Brewfile.rendered"
}

@test "Brewfile template render matches checked-in Brewfile" {
  run render_brewfile_template
  [ "$status" -eq 0 ]
  printf "%s\n" "$output" >"$BATS_TEST_TMPDIR/Brewfile.rendered"
  diff -u "$BREWFILE" "$BATS_TEST_TMPDIR/Brewfile.rendered"
}

@test "Brewfile render uses HOMEBREW_ env prefix for data conditions" {
  run render_brewfile_template
  [ "$status" -eq 0 ]
  echo "$output" | grep -q 'ENV\["HOMEBREW_CODESPACES"\]'
  echo "$output" | grep -q 'ENV\["HOMEBREW_PRIVATE"\]'
  ! echo "$output" | grep -q 'ENV\["CODESPACES"\]'
  ! echo "$output" | grep -q 'ENV\["PRIVATE"\]'
}

@test "Brewfile render preserves mixed condition expression formatting" {
  run render_brewfile_template
  [ "$status" -eq 0 ]
  echo "$output" | grep -Fq 'brew "cbonsai" if (ENV["HOMEBREW_PRIVATE"]) && !(ENV["HOMEBREW_CODESPACES"])'
  echo "$output" | grep -Fq 'brew "tmux" if (OS.mac?) && !(ENV["HOMEBREW_CODESPACES"])'
}
