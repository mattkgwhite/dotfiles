// .opencode/plugins/python-guard.ts
import type { Plugin } from "@opencode-ai/plugin"
import { existsSync } from "node:fs"
import path from "node:path"

export const PythonGuard: Plugin = async (ctx = {}) => {
  const directory = (ctx as { directory?: string }).directory
  const stripLeadingEnvAssignments = (segment: string): string =>
    segment.replace(/^(?:[A-Za-z_][A-Za-z0-9_]*=(?:"[^"]*"|'[^']*'|\S+)\s+)*/, "")

  const resolveCommandDirectory = (workdir: unknown): string => {
    const candidate =
      typeof workdir === "string" && workdir.trim().length > 0 ? workdir.trim() : directory ?? process.cwd()

    const home = process.env.HOME ?? ""
    const expanded = candidate.startsWith("~/") ? path.join(home, candidate.slice(2)) : candidate
    return path.isAbsolute(expanded) ? expanded : path.resolve(directory ?? process.cwd(), expanded)
  }

  const findUvBootstrapRoot = (startDir: string): string | null => {
    let current = path.resolve(startDir)
    while (true) {
      const hasPyproject = existsSync(path.join(current, "pyproject.toml"))
      const hasPythonVersion = existsSync(path.join(current, ".python-version"))
      if (hasPyproject && hasPythonVersion) return current

      const parent = path.dirname(current)
      if (parent === current) return null
      current = parent
    }
  }

  const isMiseWrappedUvSegment = (segment: string): boolean => {
    const normalized = stripLeadingEnvAssignments(segment.trim())
    return /\bmise\s+(?:x|exec)\b[\s\S]*\s--\s*(?:[A-Za-z_][A-Za-z0-9_]*=(?:"[^"]*"|'[^']*'|\S+)\s+)*uv\b/.test(
      normalized
    )
  }

  const isProjectIndependentUvSegment = (segment: string): boolean => {
    const normalized = stripLeadingEnvAssignments(segment.trim())
    return (
      /\buv\s+init\b/.test(normalized) ||
      /\buv\s+(?:tool|python)\b/.test(normalized) ||
      /\buv\s+(?:-V|--version|help)(?:\s|$)/.test(normalized) ||
      /\buv\s*$/.test(normalized)
    )
  }

  const blockedCommandInSegment = (segment: string): string | null => {
    if (isMiseWrappedUvSegment(segment)) return null
    const match = segment.match(
      /(^|[\s;&|()"'])(?:[\w./-]*\/)?(python3?|pip3?|uvx?)(?=$|[\s;&|()"'])/
    )
    return match ? match[2] : null
  }

  const buildErrorMessage = (blocked: string): string =>
    [
      `Do not use ${blocked} directly, including inside chained commands.`,
      "Python workflows must use mise and uv together.",
      "Use these patterns:",
      "- mise x -- uv run main.py",
      "- mise x -- uv run --with <package> main.py",
      "- mise x -- uv add <package>",
      "- mise x -- uv tool install <package>",
      "In uv projects, mise should auto source or create .venv via python.uv_venv_auto = \"create|source\"."
    ].join("\n")

  const buildInitMessage = (): string =>
    [
      "This directory is not bootstrapped as a uv project.",
      "Required project files are missing: pyproject.toml and .python-version.",
      "Initialize first with: mise x -- uv init .",
      "Then run your command again through mise + uv."
    ].join("\n")

  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return

      const cmd = String(output.args.command || "").trim()
      const commandDir = resolveCommandDirectory(output.args.workdir)
      let hasUvBootstrap = findUvBootstrapRoot(commandDir) !== null

      const segments = cmd.split(/&&|\|\||;|\|/)
      for (const segment of segments) {
        if (!segment.trim()) continue

        const blocked = blockedCommandInSegment(segment)
        if (blocked) throw new Error(buildErrorMessage(blocked))

        if (!isMiseWrappedUvSegment(segment)) continue

        const normalized = stripLeadingEnvAssignments(segment.trim())
        if (/\buv\s+init\b/.test(normalized)) {
          hasUvBootstrap = true
          continue
        }

        if (isProjectIndependentUvSegment(segment)) continue
        if (hasUvBootstrap) continue
        throw new Error(buildInitMessage())
      }
    }
  }
}
