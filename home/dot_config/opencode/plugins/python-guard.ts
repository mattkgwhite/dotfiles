import type { Plugin } from "@opencode-ai/plugin"
import { join } from "node:path"

const SHIM_DIR = join(process.env.HOME ?? "", ".local", "share", "opencode-shims")

export const PythonGuard: Plugin = async () => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return
      const cmd = String(output.args.command || "").trim()
      if (!cmd) return
      // Prepend shim dir to PATH so shims shadow any system python/pip/uv/uvx
      // binaries that the shell profile may have inserted earlier in PATH.
      output.args.command = `PATH="${SHIM_DIR}:$PATH" ${cmd}`
    }
  }
}
