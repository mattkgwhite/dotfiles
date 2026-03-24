#!/usr/bin/env bats
# brewfile.bats — Brewfile structure and guard validation

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  BREWFILE="$REPO_ROOT/home/Brewfile"
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

@test "tmux brew entry has 'if OS.mac?' guard" {
  line=$(grep -E '^brew "tmux"' "$BREWFILE")
  echo "$line" | grep -q 'if OS\.mac?'
}
