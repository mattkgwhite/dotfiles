import type { Plugin } from "@opencode-ai/plugin"

const MUTATING_TOOLS = new Set(["write", "edit", "move", "delete", "apply_patch"])
const HOME_CONFIG = process.env.HOME ? `${process.env.HOME}/.config` : ""

const BLOCK_MESSAGE =
  "Do not modify ~/.config directly. Follow the instructions: edit ~/.local/share/chezmoi/home/dot_config, then run chezmoi apply."

function collectStrings(value: unknown): string[] {
  if (typeof value === "string") return [value]
  if (Array.isArray(value)) return value.flatMap(collectStrings)
  if (value && typeof value === "object") {
    return Object.values(value as Record<string, unknown>).flatMap(collectStrings)
  }
  return []
}

function mentionsConfigPath(value: string): boolean {
  return (
    value.includes("~/.config") ||
    value.includes("$HOME/.config") ||
    (HOME_CONFIG.length > 0 && value.includes(HOME_CONFIG))
  )
}

export const ChezmoiConfigGuard: Plugin = async () => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool === "bash") {
        const command = String(output.args.command ?? "").trim()
        if (!mentionsConfigPath(command)) return
        throw new Error(BLOCK_MESSAGE)
        return
      }

      if (!MUTATING_TOOLS.has(input.tool)) return

      const argStrings = collectStrings(output.args)
      const touchesConfig = argStrings.some(mentionsConfigPath)
      if (!touchesConfig) return

      throw new Error(BLOCK_MESSAGE)
    }
  }
}
