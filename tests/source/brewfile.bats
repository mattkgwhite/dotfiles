#!/usr/bin/env bats
# brewfile.bats — Brewfile structure and guard validation

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  BREWFILE_TMPL="$REPO_ROOT/home/Brewfile.tmpl"
  BREWFILE_RENDERED="$BATS_TEST_TMPDIR/Brewfile.rendered"
}

render_brewfile_template() {
  chezmoi execute-template --file "$BREWFILE_TMPL"
}

render_brewfile_to_tmp() {
  run render_brewfile_template
  [ "$status" -eq 0 ]
  printf "%s\n" "$output" >"$BREWFILE_RENDERED"
}

@test "Brewfile template renders valid Ruby syntax" {
  render_brewfile_to_tmp
  ruby -c "$BREWFILE_RENDERED"
}

@test "Brewfile render uses HOMEBREW_ env prefix for data conditions" {
  render_brewfile_to_tmp
  echo "$output" | grep -q 'ENV\["HOMEBREW_CODESPACES"\]'
  echo "$output" | grep -q 'ENV\["HOMEBREW_PRIVATE"\]'
  ! echo "$output" | grep -q 'ENV\["CODESPACES"\]'
  ! echo "$output" | grep -q 'ENV\["PRIVATE"\]'
}

@test "all active cask entries have 'if OS.mac?' guard" {
  render_brewfile_to_tmp
  local failed=0
  while IFS= read -r line; do
    if ! echo "$line" | grep -q 'if OS\.mac?'; then
      echo "Missing OS.mac? guard: $line"
      failed=1
    fi
  done < <(grep -E '^cask ' "$BREWFILE_RENDERED")
  [[ $failed -eq 0 ]]
}

@test "tmux brew entry includes macOS guard" {
  render_brewfile_to_tmp
  line=$(grep -E '^brew "tmux"' "$BREWFILE_RENDERED")
  echo "$line" | grep -Fq 'OS.mac?'
}

@test "Brewfile render preserves mixed condition expression formatting" {
  render_brewfile_to_tmp
  echo "$output" | grep -Fq 'brew "cbonsai" if (ENV["HOMEBREW_PRIVATE"]) && !(ENV["HOMEBREW_CODESPACES"])'
  echo "$output" | grep -Fq 'brew "tmux" if (OS.mac?) && !(ENV["HOMEBREW_CODESPACES"])'
}
