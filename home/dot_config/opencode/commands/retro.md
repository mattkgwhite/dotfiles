---
description: Run post-task retrospective and update memory with lessons learned
---

Perform a structured post-task retrospective covering the work just completed.

If additional context was provided via arguments: $ARGUMENTS, factor this in when identifying what went wrong and deciding which areas to scrutinise most closely. If no arguments were provided, base the retrospective on the current session.

Follow these steps in order:

## 1. What went right

Identify approaches, tools, or decisions that worked well. For each one, delegate to the `@memory` subagent to either confirm it is already covered by an existing rule or to strengthen/add a rule that encodes the good practice. Report back a 1-sentence summary per point.

## 2. What went wrong

Identify mistakes, incorrect assumptions, wasted steps, or anything that required correction. For each one, delegate to the `@memory` subagent to add a new rule or tighten an existing rule so the same mistake does not recur in future sessions. Report back a 1-sentence summary per point.

## 3. Output

After delegating all lessons to `@memory`, provide a compact summary:

- **Went right:** one sentence per point
- **Went wrong:** one sentence per point
- **Memory updated:** confirm which rules were added, strengthened, or confirmed as already covered

Keep the summary concise. The goal is a continuous improvement loop: every session leaves global memory slightly better than it found it.
