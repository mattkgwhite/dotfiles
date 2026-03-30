import type { Plugin } from '@opencode-ai/plugin'

const MUTATING_TOOLS = new Set(['write', 'edit', 'move', 'delete', 'apply_patch'])
const HOME_DIR = String(process.env.HOME ?? '')
const HOME_CONFIG = HOME_DIR.length > 0 ? `${HOME_DIR}/.config` : ''
const CHEZMOI_SOURCE_CONFIG =
  HOME_DIR.length > 0
    ? `${HOME_DIR}/.local/share/chezmoi/home/dot_config`
    : ''

const TILDE_CONFIG = '~/' + '.config'
const DOLLAR_HOME_CONFIG = '$HOME/' + '.config'
const BLOCK_MESSAGE =
  'Do not modify ~/' +
  '.config directly. Follow the instructions: edit ~/.local/share/chezmoi/home/dot_config, then run chezmoi apply.'

function normalizePathLike (value: string): string {
  if (value.length === 0) return value
  if (value.startsWith('~/') && HOME_DIR.length > 0) {
    return `${HOME_DIR}/${value.slice(2)}`
  }
  if (value.startsWith('$HOME/') && HOME_DIR.length > 0) {
    return `${HOME_DIR}/${value.slice(6)}`
  }
  return value
}

function mentionsConfigPath (value: string): boolean {
  return (
    value.includes(TILDE_CONFIG) ||
    value.includes(DOLLAR_HOME_CONFIG) ||
    (HOME_CONFIG.length > 0 && value.includes(HOME_CONFIG))
  )
}

function isDirectConfigPath (value: string): boolean {
  const normalized = normalizePathLike(value)
  if (normalized.length === 0) return false
  if (
    CHEZMOI_SOURCE_CONFIG.length > 0 &&
    normalized.startsWith(CHEZMOI_SOURCE_CONFIG)
  ) {
    return false
  }
  return mentionsConfigPath(normalized)
}

function extractPatchPaths (patchText: string): string[] {
  return patchText
    .split('\n')
    .flatMap((line) => {
      if (line.startsWith('*** Add File: ')) return [line.slice(14)]
      if (line.startsWith('*** Update File: ')) return [line.slice(17)]
      if (line.startsWith('*** Delete File: ')) return [line.slice(17)]
      if (line.startsWith('*** Move to: ')) return [line.slice(13)]
      return []
    })
    .filter(Boolean)
}

function collectMutatedPaths (tool: string, args: Record<string, unknown>): string[] {
  switch (tool) {
    case 'write':
    case 'edit':
      return typeof args.filePath === 'string' ? [args.filePath] : []
    case 'move': {
      const paths: string[] = []
      if (typeof args.oldPath === 'string') paths.push(args.oldPath)
      if (typeof args.newPath === 'string') paths.push(args.newPath)
      return paths
    }
    case 'delete':
      if (typeof args.filePath === 'string') return [args.filePath]
      if (typeof args.path === 'string') return [args.path]
      return []
    case 'apply_patch':
      return extractPatchPaths(typeof args.patchText === 'string' ? args.patchText : '')
    default:
      return []
  }
}

export const ChezmoiConfigGuard: Plugin = async () => {
  return {
    'tool.execute.before': async (input, output) => {
      if (input.tool === 'bash') {
        const command = String(output.args.command ?? '').trim()
        if (!mentionsConfigPath(command)) return
        throw new Error(BLOCK_MESSAGE)
      }

      if (!MUTATING_TOOLS.has(input.tool)) return

      const paths = collectMutatedPaths(input.tool, output.args as Record<string, unknown>)
      if (!paths.some(isDirectConfigPath)) return

      throw new Error(BLOCK_MESSAGE)
    }
  }
}
