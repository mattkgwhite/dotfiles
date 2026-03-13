#!/usr/bin/env bash
# Shim: enforce mise wrapper for python/pip/uv toolchain binaries.
# Walk the process tree upward; if mise appears before the shell session
# boundary (bash/zsh/sh with pid=1 parent), allow through.
# Otherwise block with a clear error.

BINARY="$(basename "$0")"
REAL="$(PATH="${PATH#*opencode-shims:}" command -v "$BINARY" 2>/dev/null)"

# Walk up the process tree looking for mise
pid=$$
while true; do
  ppid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
  [[ -z "$ppid" || "$ppid" == "0" || "$ppid" == "$pid" ]] && break
  comm=$(ps -o comm= -p "$ppid" 2>/dev/null)
  case "$comm" in
    mise)
      # Invoked under mise — allow through
      exec "$REAL" "$@"
      ;;
    bash|zsh|sh|fish|opencode|node)
      # Hit the shell/session boundary without finding mise — block
      break
      ;;
  esac
  pid="$ppid"
done

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
