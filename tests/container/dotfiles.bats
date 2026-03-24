#!/usr/bin/env bats
# dotfiles.bats — validate the built container image has expected tools and configs
#
# Run from the CI runner (not inside the container), e.g.:
#   bats tests/container/dotfiles.bats
#
# Requires: docker, with dotfiles-full:local already built.

setup() {
  # Run a command inside the container as the codespace user
  docker_exec() {
    docker run --rm dotfiles-full:local bash -lc "$1"
  }
  export -f docker_exec
}

# --- Core tools on PATH ---

@test "zsh is on PATH" {
  docker run --rm dotfiles-full:local bash -lc 'command -v zsh'
}

@test "nvim is on PATH" {
  docker run --rm dotfiles-full:local bash -lc 'command -v nvim'
}

@test "mise is on PATH" {
  docker run --rm dotfiles-full:local bash -lc 'command -v mise'
}

@test "chezmoi is on PATH" {
  docker run --rm dotfiles-full:local bash -lc 'command -v chezmoi'
}

# --- Key config files exist ---

@test "~/.zshrc exists" {
  docker run --rm dotfiles-full:local test -f /home/codespace/.zshrc
}

@test "~/.gitconfig exists" {
  docker run --rm dotfiles-full:local test -f /home/codespace/.gitconfig
}

@test "~/.config/nvim/init.lua exists" {
  docker run --rm dotfiles-full:local test -f /home/codespace/.config/nvim/init.lua
}

# --- Antidote plugin cache is populated ---

@test "antidote cache directory is non-empty" {
  docker run --rm dotfiles-full:local bash -lc \
    'test -d /home/codespace/.cache/antidote && [ "$(ls -A /home/codespace/.cache/antidote)" ]'
}
