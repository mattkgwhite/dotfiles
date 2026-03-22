import type { Plugin } from "@opencode-ai/plugin"

type CachedRequest = {
  id: string
  sessionID: string
  permission: string
  patterns: string[]
  always: string[]
}

// requestID -> request details (populated on permission.asked)
const requestCache = new Map<string, CachedRequest>()

// sessionID -> approved requests awaiting pattern confirmation
const pendingApprovals = new Map<string, CachedRequest[]>()

export const PermissionPersist: Plugin = async ({ client }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "permission.asked") {
        const { id, sessionID, permission, patterns, always } = event.properties
        requestCache.set(id, { id, sessionID, permission, patterns, always })
      }

      if (event.type === "permission.replied") {
        const { sessionID, requestID, reply } = event.properties
        const req = requestCache.get(requestID)
        requestCache.delete(requestID)

        if (req && reply === "always") {
          const queue = pendingApprovals.get(sessionID) ?? []
          queue.push(req)
          pendingApprovals.set(sessionID, queue)
        }
      }

      if (event.type === "session.idle") {
        const { sessionID } = event.properties
        const pending = pendingApprovals.get(sessionID)
        if (!pending || pending.length === 0) return

        // Clear before the async call to prevent double-firing on rapid idle events
        pendingApprovals.delete(sessionID)

        const approvalLines = pending
          .map((req, i) => {
            const cmds = req.patterns.map((p) => `\`${p}\``).join(", ")
            const wildcards = req.always.map((p) => `\`${p}\``).join(", ")
            return [
              `${i + 1}. **Tool:** \`${req.permission}\``,
              `   **Exact command(s):** ${cmds}`,
              `   **Default wildcard(s):** ${wildcards}`,
            ].join("\n")
          })
          .join("\n\n")

        const text = [
          `During this session, you permanently approved the following command(s):`,
          ``,
          approvalLines,
          ``,
          `Please ask the user which pattern(s) they would like saved permanently to their OpenCode config.`,
          `Show them the exact command and the default wildcard as examples, and let them specify their own`,
          `pattern in natural language (or say "skip" to not save any). For each pattern to save, load the`,
          `\`dotfiles\` skill and add it to the \`permission\` section of`,
          `\`~/.local/share/chezmoi/home/dot_config/opencode/opencode.jsonc.tmpl\` with a value of`,
          `\`"allow"\`, under the relevant tool key (e.g., \`"bash"\`). Then run \`chezmoi apply\`.`,
        ].join("\n")

        void client.session.prompt({
          path: { id: sessionID },
          body: { parts: [{ type: "text", text }] },
        })
      }
    },
  }
}
