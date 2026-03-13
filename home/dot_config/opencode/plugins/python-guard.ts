import type { Plugin } from "@opencode-ai/plugin"

export const PythonGuard: Plugin = async () => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return
      const cmd = String(output.args.command || "").trim()
      if (!cmd) return
      // Guard against double-wrapping: if the command already starts with
      // `wolf`, the plugin has already been applied (e.g. manual mistake).
      if (/^wolf\s/.test(cmd) || cmd === "wolf") {
        throw new Error(
          "Do not add `wolf` to commands manually. The python-guard plugin wraps every bash command with wolf automatically."
        )
      }
      // Run via `wolf` which prepends the opencode-shims dir to PATH,
      // ensuring shims shadow any system python/pip/uv/uvx binaries
      // regardless of shell profile ordering.
      output.args.command = `wolf ${cmd}`
    }
  }
}
