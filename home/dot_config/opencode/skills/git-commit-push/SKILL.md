---
name: git-commit-push
description: Execute a safe commit-and-push workflow with parallel git context checks, GitHub CLI credential diagnostics, and non-fast-forward rebase remediation. Use when the user asks to commit and push changes.
---

## Goal

Capture the exact workflow for commit and push requests:

1. Run three repo-inspection commands in parallel.
2. Commit with a message that matches repo style.
3. Push.
4. If auth fails, run two diagnostics in parallel and retry push with `gh` credential helper.
5. If non-fast-forward, rebase onto `origin/main` and push again.

## Step 1, run three parallel checks

Run these in parallel:

- `git status --short --branch`
- `git diff --stat && git diff --staged --stat`
- `git log --oneline -n 10`

Use the outputs to:

- Confirm branch and changed files.
- Size and classify the change.
- Match commit message style.

## Step 2, stage and commit

Stage intended files and commit using a heredoc message.

Template:

```sh
git add -A && git commit -m "$(cat <<'EOF'
<type>(<scope>): <short why-focused subject>

<1-2 sentence rationale>
EOF
)"
```

After commit, verify:

- `git status --short --branch`

## Step 3, attempt push

Try normal push first:

- `git push origin <branch>`

## Step 4, auth remediation with two parallel checks

If push fails with credential/auth errors, run these in parallel:

- `gh auth status`
- `git remote -v`

Then retry push with one-off helper (do not change global git config):

- `git -c credential.helper='!gh auth git-credential' push origin <branch>`

## Step 5, non-fast-forward remediation

If push is rejected with `fetch first` or non-fast-forward:

1. Fetch using `gh` helper:
   - `git -c credential.helper='!gh auth git-credential' fetch origin <branch>`
2. Inspect divergence:
   - `git status --short --branch`
   - `git log --oneline --decorate --graph --left-right --boundary origin/<branch>...<branch> -n 20`
3. Rebase local branch onto remote:
   - `git rebase origin/<branch>`
4. Push again with helper:
   - `git -c credential.helper='!gh auth git-credential' push origin <branch>`
5. Verify clean sync:
   - `git status --short --branch`

## Guardrails

- Do not force-push unless explicitly requested.
- Do not modify global git config during remediation.
- Keep commit scope atomic, do not stage unrelated files.

## Self-improvement loop

After each use, if any command order, diagnostics, or remediation step can be improved, update this skill in chezmoi source (`home/dot_config/opencode/skills/git-commit-push/SKILL.md`) and keep the workflow current.
