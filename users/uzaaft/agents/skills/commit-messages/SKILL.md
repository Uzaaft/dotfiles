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

### 3. Commit Message Format

**Title (first line):**
- Limit to 60 characters maximum
- Use lowercase except for symbols or acronyms
- Use imperative mood ("add feature" not "adds feature")
- Use a short prefix for readability in `git log --oneline` (avoid "fix:" or "feature:" prefixes)

**Body:**
- Explain what the change does and why
- Use proper grammar and punctuation
- Use imperative mood throughout

**Trailers:**
- If fixing a ticket, add appropriate trailers
- If fixing a regression, add a "Fixes:" trailer with the commit id and title
