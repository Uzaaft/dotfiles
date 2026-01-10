---
name: sentry
description: Queries Sentry for issues, events, traces, and error analysis. Use when debugging production errors, searching issues, analyzing traces, or getting AI root cause analysis with Seer.
metadata:
  version: '1'
---

# Sentry

## Tools

| Tool | Purpose |
|------|---------|
| `mcp__sentry__whoami` | Auth user info |
| `mcp__sentry__find_organizations/projects/teams/releases` | List org resources |
| `mcp__sentry__get_issue_details` | Full issue + stacktrace |
| `mcp__sentry__search_issues` | Filter grouped issues (list) |
| `mcp__sentry__search_events` | Events + counts/aggregations |
| `mcp__sentry__search_issue_events` | Events within specific issue |
| `mcp__sentry__get_trace_details` | Trace overview |
| `mcp__sentry__get_event_attachment` | Download attachments |
| `mcp__sentry__analyze_issue_with_seer` | AI root cause + code fixes |

## Workflows

**Debug error**: `get_issue_details` → `analyze_issue_with_seer` → `search_issue_events` for patterns

**Find issues**: `search_issues` (natural language) → `get_issue_details` for stacktrace

**Performance**: `get_trace_details` → `search_events` with spans dataset

## Queries

| `search_issues` (grouped) | `search_events` (raw/counts) |
|---------------------------|------------------------------|
| "unresolved errors last week" | "how many errors today" |
| "critical bugs 100+ users" | "database failures this week" |
| "issues assigned to me" | "total tokens used by model" |

## Tips

- Pass `issueUrl` directly when user provides Sentry URL
- Use `organizationSlug` from `find_organizations` if unknown
- `analyze_issue_with_seer` returns actual code fixes; cached after first call
