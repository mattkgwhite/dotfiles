#!/usr/bin/env bats
# overlay.bats — validate image layer structure for delta extraction
#
# Run from the CI runner (not inside the container), e.g.:
#   bats tests/container/overlay.bats
#
# Requires: docker, with dotfiles-full:local already built and the
# base image (FROM line) still in the local daemon cache.

setup() {
  BASE_IMAGE="mcr.microsoft.com/devcontainers/universal:latest"
  FULL_IMAGE="dotfiles-full:local"
  DIFF_COUNT=2
}

@test "built image has exactly ${DIFF_COUNT} layers over the base" {
  base_layers=$(docker inspect --format '{{json .RootFS.Layers}}' "$BASE_IMAGE" \
    | jq 'length')
  full_layers=$(docker inspect --format '{{json .RootFS.Layers}}' "$FULL_IMAGE" \
    | jq 'length')
  delta=$(( full_layers - base_layers ))
  echo "base=$base_layers full=$full_layers delta=$delta expected=$DIFF_COUNT"
  [[ $delta -eq $DIFF_COUNT ]]
}
