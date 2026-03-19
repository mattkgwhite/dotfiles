#!/usr/bin/env bash
# Shim: enforce mise wrapper for python/pip/uv toolchain binaries.
# When invoked via `mise x -- <cmd>`, the $_ env var points to the mise
# binary. Use that as a lightweight signal to allow through; otherwise block.

# Capture $_ immediately; subsequent commands overwrite it.
INVOKER="$_"

BINARY="$(basename "$0")"
REAL="$(PATH="${PATH#*opencode-shims:}" command -v "$BINARY" 2>/dev/null)"

# Under `mise x --`, $_ points to the mise binary
case "$INVOKER" in
  */mise) exec "$REAL" "$@" ;;
esac

cat >&2 <<EOF
Do not use $BINARY directly.
Python workflows must use mise and uv together.
Use these patterns:
  mise x -- uv run main.py
  mise x -- uv run --with <package> main.py
  mise x -- uv add <package>
  mise x -- uv tool install <package>
  mise x -- uv run --no-project python ...
EOF
exit 1
