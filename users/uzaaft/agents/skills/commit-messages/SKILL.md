---
name: commit-messages
description: Write clear commit messages. Use when asked to commit changes, write a commit message, prepare a commit, or describe changes for version control.
---

# Committing Changes

Make small, atomic commits with clear messages.

## Workflow

### 1. Understand the Changes

If you don't already understand the changes, review them first:

```bash
git diff HEAD
git status --short
```

### 2. Stage and Commit

Make small, atomic commits—each commit should address one logical change. If your work spans multiple concerns (e.g., a refactor and a bug fix), break it into separate commits.

```bash
# Stage entire files
git add <files>

# Or stage specific hunks for finer control
git hunks list                            # List all hunks with IDs
git hunks add 'file:@-old,len+new,len'    # Stage specific hunks by ID

git commit -m "title" -m "body paragraph"
```

## Rules
### Subject line

- **Conventional cmmits**:
  - Use a short lowercase identifier for the type of change. 
  - Use a short, lowercase identifier for the
  area of code changed (e.g., `terminal`, `api`, `lib`, `config`). Determine this from the file paths in the diff.
- **Summary**: Lowercase start (not capitalized), imperative mood,
  no trailing period. Keep it concise—ideally under 60 characters
  total for the whole subject line.

### References

- If the change relates to a GitHub issue, PR, or discussion, list
  the relevant numbers on their own lines after the subject, separated
  by a blank line. E.g. `#1234`
- If there are no references, omit this section entirely (no blank
  line).

### Long form description

- Describe **what changed**, **what the previous behavior was**,
  and **how the new behavior works** at a high level.
- Use plain prose, not bullet points. Wrap lines at ~72 characters.
- Focus on the _why_ and _how_ rather than restating the diff.
- Keep the tone direct and technical without no filler phrases.
- Don't exceed a handful of paragraphs; less is more.

## Workflow

- If `.jj` is present, use `jj` instead of `git` for all commands.
- Run a diff to see what changes are present since the last commit.
- Identify the subsystem from the changed file paths.
- Identify any referenced issues/PRs from the diff context or
  branch name.
- Draft the commit message following the format above.
- Apply the commit
- Don't push the commit; leave that to the user.
