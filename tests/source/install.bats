#!/usr/bin/env bats
# install.bats — structural tests for install script templates and CI workflows.
# Validates that regressions from the install script hardening are not reintroduced.

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  if command -v cygpath >/dev/null 2>&1; then
    REPO_ROOT="$(cygpath -m "$REPO_ROOT")"
  fi
}

# --- install.ps1.tmpl: prerequisite packages in elevated block ---

@test "install.ps1: elevated block installs chezmoi" {
  grep -q 'Get-Command chezmoi.*packages.*chezmoi' "$REPO_ROOT/install.ps1.tmpl"
}

@test "install.ps1: elevated block installs gnupg" {
  grep -q 'Get-Command gpg.*packages.*gnupg' "$REPO_ROOT/install.ps1.tmpl"
}

@test "install.ps1: elevated block installs mise" {
  grep -q 'Get-Command mise.*packages.*mise' "$REPO_ROOT/install.ps1.tmpl"
}

@test "install.ps1: elevated block installs powershell-core" {
  grep -q 'Get-Command pwsh.*packages.*powershell-core' "$REPO_ROOT/install.ps1.tmpl"
}

@test "install.ps1: elevated block installs bitwarden-cli" {
  grep -q 'Get-Command bw.*packages.*bitwarden-cli' "$REPO_ROOT/install.ps1.tmpl"
}

@test "install.ps1: elevated block installs git" {
  grep -q 'packages.*git' "$REPO_ROOT/install.ps1.tmpl"
}

# --- install.ps1.tmpl: elevation split ---

@test "install.ps1: uses scriptblock elevation pattern" {
  grep -q '\$elevatedScript\s*=' "$REPO_ROOT/install.ps1.tmpl"
}

@test "install.ps1: bw login is outside elevated block" {
  local non_elevated
  non_elevated=$(grep -n '# --- Non-elevated' "$REPO_ROOT/install.ps1.tmpl" | head -1 | cut -d: -f1)
  local bw_login
  bw_login=$(grep -vn '^\s*#' "$REPO_ROOT/install.ps1.tmpl" | grep 'bw login' | head -1 | cut -d: -f1)
  [ "$bw_login" -gt "$non_elevated" ]
}

@test "install.ps1: chezmoi init is outside elevated block" {
  local non_elevated
  non_elevated=$(grep -n '# --- Non-elevated' "$REPO_ROOT/install.ps1.tmpl" | head -1 | cut -d: -f1)
  local chezmoi_init
  chezmoi_init=$(grep -vn '^\s*#' "$REPO_ROOT/install.ps1.tmpl" | grep 'chezmoi init' | head -1 | cut -d: -f1)
  [ "$chezmoi_init" -gt "$non_elevated" ]
}

# --- install.ps1.tmpl: error handling ---

@test "install.ps1: elevated block has try-catch" {
  grep -q 'try {' "$REPO_ROOT/install.ps1.tmpl"
  grep -q 'catch {' "$REPO_ROOT/install.ps1.tmpl"
}

@test "install.ps1: elevated block pauses on failure" {
  grep -q 'ReadKey' "$REPO_ROOT/install.ps1.tmpl"
}

@test "install.ps1: checks LASTEXITCODE after chezmoi init" {
  # LASTEXITCODE check must appear after chezmoi init --apply
  local chezmoi_init
  chezmoi_init=$(grep -n 'chezmoi init --apply' "$REPO_ROOT/install.ps1.tmpl" | tail -1 | cut -d: -f1)
  local exit_check
  exit_check=$(grep -n 'LASTEXITCODE' "$REPO_ROOT/install.ps1.tmpl" | tail -1 | cut -d: -f1)
  [ "$exit_check" -gt "$chezmoi_init" ]
}

@test "install.ps1: does not print Done on chezmoi failure" {
  # "Done!" must be inside a success branch (after LASTEXITCODE check), not unconditional
  ! grep -P '^\s*Write-Host.*Done!.*Green' "$REPO_ROOT/install.ps1.tmpl" | head -1 | grep -v 'else'
  grep -B5 'Done!' "$REPO_ROOT/install.ps1.tmpl" | grep -q 'LASTEXITCODE'
}

# --- install.ps1.tmpl: bw login ---

@test "install.ps1: checks bw status before login" {
  grep -q 'bw status' "$REPO_ROOT/install.ps1.tmpl"
}

@test "install.ps1: prompts bw login when unauthenticated" {
  grep -q 'unauthenticated' "$REPO_ROOT/install.ps1.tmpl"
  grep -q 'bw login' "$REPO_ROOT/install.ps1.tmpl"
}

@test "install.ps1: syncs bw vault after login" {
  grep -q 'bw sync' "$REPO_ROOT/install.ps1.tmpl"
  local bw_login
  bw_login=$(grep -n 'bw login' "$REPO_ROOT/install.ps1.tmpl" | head -1 | cut -d: -f1)
  local bw_sync
  bw_sync=$(grep -n 'bw sync' "$REPO_ROOT/install.ps1.tmpl" | head -1 | cut -d: -f1)
  [ "$bw_sync" -gt "$bw_login" ]
}

# --- install.sh.tmpl: bitwarden prereqs ---

@test "install.sh: installs bitwarden-cli via brew (non-codespaces)" {
  grep -q 'brew install bitwarden-cli' "$REPO_ROOT/install.sh.tmpl"
}

@test "install.sh: bw install is gated on non-codespaces" {
  grep -q 'CODESPACES' "$REPO_ROOT/install.sh.tmpl"
}

@test "install.sh: checks bw status and prompts login" {
  grep -q 'bw status' "$REPO_ROOT/install.sh.tmpl"
  grep -q 'bw login' "$REPO_ROOT/install.sh.tmpl"
}

@test "install.sh: syncs bw vault after login" {
  grep -q 'bw sync' "$REPO_ROOT/install.sh.tmpl"
  local bw_login
  bw_login=$(grep -n 'bw login' "$REPO_ROOT/install.sh.tmpl" | head -1 | cut -d: -f1)
  local bw_sync
  bw_sync=$(grep -n 'bw sync' "$REPO_ROOT/install.sh.tmpl" | head -1 | cut -d: -f1)
  [ "$bw_sync" -gt "$bw_login" ]
}

# --- bootstrap_windows: mise error handling ---

@test "bootstrap_windows: checks LASTEXITCODE after mise install" {
  grep -A2 'mise install' "$REPO_ROOT/home/.chezmoiscripts/run_onchange_after_bootstrap_windows.ps1.tmpl" | grep -q 'LASTEXITCODE'
}

@test "bootstrap_windows: gnupg in choco package list" {
  grep -q '"gnupg"' "$REPO_ROOT/home/.chezmoiscripts/run_onchange_after_bootstrap_windows.ps1.tmpl"
}

# --- CI workflows: bot skip conditions ---

@test "test.yml: skips bot pushes to main" {
  grep -q "contains(github.actor.*bot" "$REPO_ROOT/.github/workflows/test.yml"
}

@test "megalinter.yml: skips bot pushes to main" {
  grep -q "contains(github.actor.*bot" "$REPO_ROOT/.github/workflows/megalinter.yml"
}

# --- chezmoi.bats: Windows compatibility guards ---

@test "chezmoi.bats: setup converts MSYS paths via cygpath" {
  grep -q 'cygpath' "$REPO_ROOT/tests/source/chezmoi.bats"
}

@test "chezmoi.bats: Ruby globs use File.join (no shell wildcard to native executables)" {
  # No *.yaml passed as an argument to ruby — globs must be constructed inside Ruby
  ! grep -P "ruby.*\*\.yaml" "$REPO_ROOT/tests/source/chezmoi.bats"
}
