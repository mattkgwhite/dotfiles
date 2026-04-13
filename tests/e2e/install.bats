#!/usr/bin/env bats
# install.bats — E2E verification after chezmoi apply with Vaultwarden-backed secrets.
# Run by the e2e-install workflow after seeding Vaultwarden and running chezmoi apply.

@test "wakatime config was created" {
  [ -f "$HOME/.config/wakatime/.wakatime.cfg" ]
}

@test "wakatime config contains Bitwarden-resolved API key" {
  grep -q "test-wakatime-key-12345" "$HOME/.config/wakatime/.wakatime.cfg"
}

@test "gitconfig exists" {
  [ -f "$HOME/.gitconfig" ]
}

@test "nvim init.lua exists" {
  [ -f "$HOME/.config/nvim/init.lua" ]
}
