---
name: sentry
description: Queries Sentry for issues, events, traces, and error analysis. Use when debugging production errors, searching issues, analyzing traces, or getting AI root cause analysis with Seer.
metadata:
  version: '1'
---

# Sentry

Query and analyze production errors from Sentry.

## Available Tools

| Tool | Purpose |
|------|---------|
| `mcp__sentry__whoami` | Get authenticated user info |
| `mcp__sentry__find_organizations` | List accessible organizations |
| `mcp__sentry__find_projects` | List projects in an organization |
| `mcp__sentry__find_teams` | List teams in an organization |
| `mcp__sentry__find_releases` | Find releases/versions |
| `mcp__sentry__get_issue_details` | Get full issue details with stacktrace |
| `mcp__sentry__search_issues` | Search/filter grouped issues (returns list) |
| `mcp__sentry__search_events` | Search events + counts/aggregations |
| `mcp__sentry__search_issue_events` | Filter events within a specific issue |
| `mcp__sentry__get_trace_details` | Get trace overview |
| `mcp__sentry__get_event_attachment` | Download event attachments |
| `mcp__sentry__analyze_issue_with_seer` | AI root cause analysis with code fixes |

## Workflow

### Debugging a Production Error

1. **Get issue details** → `get_issue_details` with URL or issue ID
2. **Analyze root cause** → `analyze_issue_with_seer` for AI-powered fix recommendations
3. **Search related events** → `search_issue_events` to find patterns

### Finding Issues

1. **Search issues** → `search_issues` with natural language query
2. **Get details** → `get_issue_details` for stacktrace and context

### Performance Analysis

1. **Get trace** → `get_trace_details` with trace ID
2. **Search spans** → `search_events` with spans dataset

## Query Examples

### search_issues (returns issue list)
- "unresolved errors from last week"
- "critical bugs affecting 100+ users"
- "issues assigned to me"
- "user feedback from production"

### search_events (returns counts/events)
- "how many errors today"
- "count of database failures this week"
- "error logs from the last hour"
- "total tokens used by model"

## Tips

- Always pass `issueUrl` directly when user provides a Sentry URL
- Use `organizationSlug` from `find_organizations` if not known
- `search_issues` returns grouped issues; `search_events` returns raw events/counts
- `analyze_issue_with_seer` provides actual code fixes, not just descriptions
- Results are cached—subsequent Seer calls return instantly
