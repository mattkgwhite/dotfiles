import type { Plugin } from '@opencode-ai/plugin'
import { accessSync, constants, lstatSync } from 'node:fs'
import { join } from 'node:path'

const HOME = process.env.HOME ?? ''
const SHIM_DIR = join(HOME, '.local', 'share', 'opencode-shims')
const SHIMS = ['python', 'python3', 'pip', 'pip3', 'uv', 'uvx']

const checkIntegrity = (): string | null => {
  // Verify shim.sh exists and is executable
  const shimSh = join(SHIM_DIR, 'shim.sh')
  try {
    accessSync(shimSh, constants.X_OK)
  } catch {
    return `shim.sh is missing or not executable at ${String(shimSh)}. Run: chezmoi apply`
  }
  // Verify each shim symlink exists
  for (const name of SHIMS) {
    const p = join(SHIM_DIR, name)
    try {
      lstatSync(p) // lstat so we check the symlink itself, not its target
    } catch {
      return `shim symlink missing: ${String(p)}. Run: chezmoi apply`
    }
  }
  return null
}

export const PythonGuard: Plugin = async () => {
  // Integrity check at plugin load: ensure shims are in place
  const integrity = checkIntegrity()
  if (integrity !== null && integrity.length > 0) {
    console.warn(`python-guard: ${integrity}`)
  }
  return {}
}
