---
name: choosing-merge-strategies
description: "Chooses between merge commits, squash merges, and rebases for pull requests. Use when deciding a Git merge strategy, explaining commit hygiene, preparing PRs for merge, or advising on bisect-friendly history."
---

# Choosing Merge Strategies

Use merge commits, squash merges, and rebases situationally. Optimize for truthful history, buildable commits, useful bisects, and easy reverts.

## Default Preference

Prefer a normal merge commit when the branch has meaningful, buildable commits.

Why:
- It represents true history: the branch happened, then it merged.
- It preserves the merge point and the developer's sequence of work.
- It makes the whole change easy to revert with `git revert -m <parent-number> <merge-commit-sha>`.
- It keeps information useful for `git bisect`, as long as each commit builds.

The key assumption is commit hygiene: every commit should build and should make sense as an atomic piece of work. A history of many small, coherent commits is better than one large squashed commit.

## Decision Rules

### Use a merge commit when

Choose merge when:
- The branch contains multiple meaningful commits.
- Each commit is expected to build and pass relevant checks.
- The commits tell a useful development story.
- Preserving the exact branch history helps future debugging, auditing, or revert work.
- The diff is large enough that preserving intermediate steps will make `git bisect` substantially more useful.

This is the preferred strategy for well-maintained branches.

### Use squash merge when

Choose squash when:
- The PR is conceptually one small change.
- The branch has many low-value commits such as `WIP`, `fix`, `fix tests`, or repeated checkpoint commits.
- The final diff is small enough that one commit remains reviewable and bisectable.
- The intermediate history does not convey useful information.

Squashing is a cleanup tool for noisy history, not the default way to merge all PRs.

### Use interactive rebase when

Choose interactive rebase when:
- The diff is large and the branch history is noisy.
- There are many `WIP` commits, but a single squash would produce an unhelpfully huge commit.
- Commits need to be reordered, split, edited, or selectively squashed into coherent atomic changes.
- The final history should preserve useful bisect points while removing noise.

For large changes, prefer a cleaned-up sequence of meaningful commits over either raw noisy history or one massive squash commit.

## Bisect Standard

Protect `git bisect` usefulness.

Avoid landing one huge squashed commit when the underlying change contains many separable decisions. Landing on a single `+2000/-500` commit during a bisect is not useful. Prefer commits small enough that a future debugger can identify the bug quickly.

Target sizes are guidance, not hard rules:
- Ideal bisect landing point: roughly `+50/-50` or another small atomic change.
- Acceptable worst case: roughly `+500/-500` if the change is still conceptually coherent.
- Avoid: one massive squashed PR commit containing many unrelated or separable changes.

A merge with many small, buildable, meaningful commits is better than one large squashed commit.

## Commit Hygiene Expectations

When preserving commits, ensure each commit:
- Builds.
- Passes relevant focused checks when practical.
- Represents one atomic piece of work.
- Has a meaningful message.
- Does not depend on later commits to fix obvious breakage.
- Does not include temporary debug code, secrets, generated junk, or unrelated churn.

If these expectations are not met, clean the branch with an interactive rebase before merging.

## Practical Workflow

1. Inspect the PR size and commit history.
2. Ask whether the existing commits are meaningful and buildable.
3. If yes, prefer a merge commit.
4. If the PR is small and history is mostly low-value WIP noise, squash.
5. If the PR is large and history is noisy, interactive rebase into coherent commits, then merge.
6. After cleanup, preserve as much useful history as possible.

## Communication Guidance

When advising others, frame the choice as situational, not dogmatic:

- Merge commits preserve true history and support better bisects when commits are clean.
- Squash merges are appropriate for small changes with noisy WIP history.
- Interactive rebase is the right cleanup tool for large noisy branches.

Do not recommend squash as a blanket policy. Do not preserve broken or meaningless commits just for the sake of preserving history.
