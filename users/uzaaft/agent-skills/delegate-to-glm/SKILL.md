---
name: delegating-to-glm
description: "Delegates bounded research, review, planning, or implementation tasks to GLM-5.2 through the OpenCode CLI. Use when asked to send, hand off, or dispatch work to GLM-5.2 in OpenCode."
compatibility: "Requires Git, the opencode CLI, and configured Fireworks AI access to accounts/fireworks/models/glm-5p2."
---

# Delegating to GLM-5.2

Send a well-bounded task to GLM-5.2 with OpenCode, wait for it to finish, and verify its work before reporting it as complete.

## Before dispatch

1. Confirm the CLI and model are available:

   ```sh
   command -v opencode
   opencode models fireworks-ai | grep -Fx \
     'fireworks-ai/accounts/fireworks/models/glm-5p2'
   ```

2. Read enough of the repository to define the task precisely. Do not delegate the responsibility of discovering what the user meant.
3. Record `git status --short` before an implementation task. Pre-existing changes belong to the user or another agent and must not be reverted or overwritten.
4. Choose one bounded outcome. Split independent or unrelated work into separate dispatches.

## Create an isolated worktree

Every delegation, including read-only research and review, must run in a new Git worktree. Never point OpenCode at the caller's checkout.

Create a detached worktree from the commit the task should use:

```sh
repository_root="$(git rev-parse --show-toplevel)"
delegation_root="$(mktemp -d "${TMPDIR:-/tmp}/glm-5p2.XXXXXXXX")"
worktree_path="$delegation_root/worktree"
git -C "$repository_root" worktree add --detach "$worktree_path" HEAD
```

The isolated worktree contains committed state only. It does not contain staged, unstaged, or untracked files from the caller's checkout. If the task depends on those files, stop and prepare a safe isolated baseline rather than silently delegating against stale code. Never copy secrets, ignored files, or the entire caller checkout into the worktree.

## Write the handoff

Treat GLM as a capable agent with no conversation context. The prompt must include:

- the required outcome and why it matters;
- the workspace path and the files or directories to inspect first;
- relevant repository constraints and existing patterns;
- whether the task is research, review, planning, implementation, or verification;
- explicit in-scope and out-of-scope boundaries;
- exact validation commands when code may change;
- the expected final response: outcome, evidence, files changed, validation, and blockers.

Tell GLM to read every applicable `AGENTS.md` before editing. Do not paste secrets, credentials, customer content, or large source files into the prompt. Give file paths and let GLM inspect them locally.

For implementation work, include this constraint:

> Make the smallest correct change inside this isolated worktree. Do not push. Run the specified validation and report every changed file. Leave the changes uncommitted for review.

## Dispatch

Run OpenCode against the isolated worktree. Pass `--auto` to auto-approve permissions that are not explicitly denied. Use a quoted heredoc so shell expansion cannot alter the prompt:

```sh
opencode run \
  --model fireworks-ai/accounts/fireworks/models/glm-5p2 \
  --auto \
  --dir "$worktree_path" \
  --title "GLM-5.2: <short task name>" \
  "$(
    cat <<'GLM_TASK'
You are working in the isolated Git worktree at <absolute worktree path>.

Outcome:
<one concrete outcome>

Context and starting points:
- <relevant files, symbols, and facts>

Constraints:
- Read applicable AGENTS.md files before editing.
- <scope and repository-specific constraints>
- Work only inside this worktree. Do not commit or push.

Validation:
- <exact commands, or state that this is read-only>

Return:
- Outcome
- Evidence or files changed
- Validation results
- Blockers or remaining uncertainty
GLM_TASK
  )"
```

`--auto` is intentionally required for these isolated delegations. It auto-approves permissions that are not explicitly denied, which is why the worktree boundary is mandatory. It does not override an explicit OpenCode permission denial.

Wait for the existing process when the shell runner reports that it is still running. Do not launch the same task again. A long task can legitimately exceed the shell tool's initial timeout.

## Follow up in the same session

Prefer one self-contained dispatch. If GLM's result needs a focused correction, identify the session with `opencode session list`, then continue it:

```sh
opencode run \
  --session \
  fireworks-ai/accounts/fireworks/models/glm-5p2 \
  --auto \
  --dir "$worktree_path" \
  "<specific correction backed by observed evidence>" <session-id >--model
```

Do not retry an unchanged prompt. Explain the failure or missing requirement in the follow-up.

## Review the result

GLM's final message is a report, not proof.

For code-changing tasks:

1. Inspect `git -C "$worktree_path" status --short` and `git -C "$worktree_path" diff` yourself.
2. Confirm every changed hunk is in scope and preserves pre-existing work.
3. Run the narrowest meaningful validation yourself inside the worktree. Broaden it when shared contracts changed.
4. Correct defects directly or send one evidence-backed follow-up.
5. Port only reviewed changes into the caller's checkout. Do not overwrite unrelated local changes; apply the changes manually when a patch would conflict.
6. Re-run relevant validation in the caller's checkout after integration.
7. Report GLM's work only after independent review. State any validation you could not run.

For read-only tasks, verify decisive claims against the cited files, command output, or primary sources before relying on them.

## Remove the worktree

For a clean read-only worktree, remove it after review:

```sh
git -C "$repository_root" worktree remove "$worktree_path"
rmdir "$delegation_root"
```

For implementation work, first port and verify every wanted change. A normal `git worktree remove` refuses to remove a dirty worktree. Never use `--force` or delete the directory while it contains the only copy of delegated changes. Preserve the diff or obtain approval before discarding it.

## When not to delegate

Do not dispatch when the task is a trivial local edit, requires secrets that cannot be exposed to the provider, would create unsafe concurrent edits, or is too ambiguous to describe with a concrete done condition.
