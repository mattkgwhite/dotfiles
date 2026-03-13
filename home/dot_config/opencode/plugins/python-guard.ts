import type { Plugin } from "@opencode-ai/plugin"
import { accessSync, constants, lstatSync } from "node:fs"
import { join } from "node:path"

const HOME = process.env.HOME ?? ""
const WOLF = join(HOME, ".local", "bin", "wolf")
const SHIM_DIR = join(HOME, ".local", "share", "opencode-shims")
const SHIMS = ["python", "python3", "pip", "pip3", "uv", "uvx"]

const checkIntegrity = (): string | null => {
  // Verify wolf exists and is executable
  try {
    accessSync(WOLF, constants.X_OK)
  } catch {
    return `wolf is missing or not executable at ${WOLF}. Run: chezmoi apply`
  }
  // Verify shim.sh exists and is executable
  const shimSh = join(SHIM_DIR, "shim.sh")
  try {
    accessSync(shimSh, constants.X_OK)
  } catch {
    return `shim.sh is missing or not executable at ${shimSh}. Run: chezmoi apply`
  }
  // Verify each shim symlink exists
  for (const name of SHIMS) {
    const p = join(SHIM_DIR, name)
    try {
      lstatSync(p) // lstat so we check the symlink itself, not its target
    } catch {
      return `shim symlink missing: ${p}. Run: chezmoi apply`
    }
  }
  return null
}

export const PythonGuard: Plugin = async () => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return
      const cmd = String(output.args.command || "").trim()
      if (!cmd) return

      // Integrity check: ensure wolf and shims have not been tampered with
      const integrity = checkIntegrity()
      if (integrity) {
        throw new Error(`python-guard integrity failure: ${integrity}`)
      }

      // Skip wrapping if already wrapped (idempotent)
      if (/^wolf\s/.test(cmd) || cmd === "wolf") return

      // Run via `wolf` which prepends the opencode-shims dir to PATH,
      // ensuring shims shadow any system python/pip/uv/uvx binaries
      // regardless of shell profile ordering.
      output.args.command = `wolf ${cmd}`
    }
  }
}
