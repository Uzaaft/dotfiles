---
name: managing-linear
description: "Manages Linear issues, projects, teams, cycles, documents, and comments via the official Linear MCP server. Use when asked to create/update/list/search Linear issues, manage projects, query teams, or interact with Linear in any way."
---

# Linear

Interact with Linear's project management system through the official remote MCP server.

## Authentication

First use triggers an OAuth flow in the browser. Credentials are cached in `~/.mcp-auth`.
If auth fails, run `rm -rf ~/.mcp-auth` and retry.

## Tools

### Querying

| Tool | Purpose | Key Params |
|------|---------|------------|
| `list_issues` | List/filter issues | `teamId`, `stateId`, `assigneeId` (`"me"` supported), `labelId`, `projectId`, `cycleId`, `limit`, `orderBy` |
| `list_projects` | List projects | `teamId`, `limit` |
| `list_teams` | All teams | — |
| `list_users` | All users | `limit` |
| `list_documents` | List documents | `projectId`, `limit` |
| `list_cycles` | List cycles | `teamId`, `limit` |
| `list_comments` | Comments on issue | `issueId` |
| `list_issue_labels` | Issue labels | `teamId` |
| `list_issue_statuses` | Workflow states | `teamId` |
| `list_project_labels` | Project labels | — |

### Reading Details

| Tool | Purpose |
|------|---------|
| `get_issue` | Full issue details by ID/identifier |
| `get_project` | Project details |
| `get_team` | Team details |
| `get_user` | User details |
| `get_document` | Document details |
| `get_issue_status` | Workflow state details |

### Creating

| Tool | Required | Optional |
|------|----------|----------|
| `create_issue` | `title`, `teamId` | `description` (markdown), `assigneeId`, `priority` (0=none,1=urgent,2=high,3=normal,4=low), `stateId`, `labelIds`, `projectId`, `cycleId`, `estimate` |
| `create_project` | `name`, `teamIds` | `description`, `state` |
| `create_comment` | `issueId`, `body` | — |
| `create_issue_label` | `name`, `teamId` | `color` (hex), `description` |

### Updating

| Tool | Required | Optional |
|------|----------|----------|
| `update_issue` | `issueId` | `title`, `description`, `stateId`, `assigneeId`, `priority`, `labelIds`, `projectId`, `cycleId`, `estimate` |
| `update_project` | `projectId` | `name`, `description`, `state` |

### Knowledge

| Tool | Purpose |
|------|---------|
| `search_documentation` | Search Linear's docs for feature/workflow help |

## Priority Values

| Value | Meaning |
|-------|---------|
| 0 | No priority |
| 1 | Urgent |
| 2 | High |
| 3 | Normal |
| 4 | Low |

## Workflows

**Create issue for someone**:
`list_teams` → `list_users` → `list_issue_labels` → `create_issue`

**Triage my issues**:
`list_issues` (assigneeId=`"me"`) → `get_issue` for details → `update_issue` to reprioritize

**Sprint planning**:
`list_cycles` → `list_issues` (cycleId) → assess workload

**Update issue status**:
`list_issue_statuses` (teamId) → `update_issue` (stateId)

**Project overview**:
`list_projects` → `get_project` → `list_issues` (projectId)

## Tips

- Use `"me"` as `assigneeId` value to query the authenticated user's issues
- Always resolve human names to IDs via `list_users` / `list_teams` before create/update calls
- Use `list_issue_statuses` to discover valid state IDs before changing issue status
- Markdown is supported in `description` and `body` fields
- `search_documentation` helps answer "how does X work in Linear?" questions
