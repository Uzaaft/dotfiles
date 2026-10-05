---
name: operating-amp-factory
description: Builds and operates an Amp-only personal software factory in Rex using `rex do` for scripted workspaces, test stations, servers, logs, diffs, and review. Use when asked to set up a software factory, orchestrate development work in Rex, or keep an Amp task moving with visible supporting terminals.
compatibility: Requires Amp and Rex CLIs and a live Rex session.
---

# Operating an Amp Factory

Use Amp as the only agent runtime and Rex as the visible control plane. The default factory is one useful Amp agent plus purpose-built terminals for tests, servers, logs, diffs, and review.

## Boundaries

- Keep implementation in the current Amp thread unless a genuinely independent workstream justifies another native Amp thread.
- Use Amp's thread and subagent tools for agent coordination. Do not launch, continue, or message Amp agents through shell commands or Rex.
- Do not support Claude Code, Codex, OpenCode, or other agent runtimes.
- Use Rex to operate terminals and layouts, not to bypass Amp's approval, thread, or delegation rules.
- Default to one coding agent. Add parallel Amp work only when the tasks are independent and their checkouts and file ownership are explicit.
- Preserve existing panes and processes. Create only the stations the task needs.

## Orient

Read the inherited Rex context once:

```sh
env | sort | rg '^REX_(SERVER|SESSION|BLOCK)='
rex session inspect "$REX_SESSION" --json
rex block inspect "$REX_BLOCK" --json
```

Treat `REX_SESSION` and `REX_BLOCK` as the factory's origin, not necessarily the currently focused pane. Rename a generic session to two to four lowercase hyphenated words describing the work.

Find the project root, repository guidance, actual development commands, and existing running stations before changing the layout. Do not invent `npm`, `pnpm`, test, server, or log commands.

## Design the smallest factory

Choose stations from the work rather than creating a fixed dashboard:

- **Agent:** the current Amp terminal; never replace or close it incidentally.
- **Test:** the narrowest useful test or watch command.
- **Server:** a long-lived development server when the work needs one.
- **Logs:** output that must remain visible while Amp works.
- **Review:** a finite diff, status, or verification command.

Prefer a new Rex window for each long-lived concern. Use splits only when two streams must be watched together. Create support stations with `focus = false` so the user's current work is not interrupted.

## Use `rex do` as the orchestration primitive

Use one `rex do` Lua script for a cohesive layout change. Pass dynamic values through JSON arguments; do not interpolate project paths, labels, or commands into Lua source.

This pattern creates several visible stations in the inherited session:

```sh
factory_args=$(jq -nc \
  --arg session "$REX_SESSION" \
  --arg cwd "$project_dir" \
  --argjson stations "$stations_json" \
  '{session_id: $session, cwd: $cwd, stations: $stations}')

cat <<'LUA' | rex do -s "$REX_SESSION" - --args "$factory_args" --json
local function terminal(command, cwd)
    return rex.layout.block({
        flavor = "com.superlogical.terminal.shell",
        options = {
            command = command,
            cwd = cwd,
            exit = { on_completion = false },
        },
    })
end

local created = {}
for _, station in ipairs(rex.args.stations) do
    local result, err = rex.call("session.new_window", {
        session_id = rex.args.session_id,
        window_label = station.label,
        focus = false,
        layout = terminal(station.command, station.cwd or rex.args.cwd),
    })
    if err ~= nil then
        error(err, 0)
    end
    table.insert(created, result)
end
return created
LUA
```

Build `stations_json` with `jq`. Each `command` is an argument array, for example:

```sh
stations_json=$(jq -nc \
  --argjson test '["pnpm", "vitest", "--watch"]' \
  --argjson diff '["git", "--no-pager", "diff"]' \
  '[
    {label: "Tests", command: $test},
    {label: "Review", command: $diff}
  ]')
```

Use `sh -c` only when the command genuinely needs shell syntax such as a pipeline. For one station or one split, a direct Rex command is simpler and should be preferred.

## Operate the factory

After creation, keep the returned full block IDs. Verify the relevant state instead of assuming creation means readiness:

```sh
rex capture -s "$REX_SESSION" -b "$block_id" --trim --unwrap
rex block call -s "$REX_SESSION" -b "$block_id" process
rex session inspect "$REX_SESSION" --json
```

- A server is ready only after its output or endpoint says so.
- A finite check passes only when its process reports exit status 0 and its output is correct.
- A Rex wait timeout means the process is still running, not that it failed.
- Stop a foreground process with `rex send-key ... ctrl+c`; close its pane only when cleanup is requested or clearly safe.
- Reuse or restart a station when possible. Do not accumulate duplicate test, server, or log windows.

Keep the human in control of interruptions. Leave background stations unfocused and summarize their state at natural milestones rather than generating notifications.

## Native Amp parallelism

When the task truly benefits from independent Amp work, use Amp's native thread tools. Give each coding thread a separate worktree or checkout and disjoint file ownership. Rex may display supporting processes for those checkouts, but it must not start or control the Amp agents themselves.

Do not create another Amp thread merely to run tests, inspect a diff, or access the same local checkout. Those are Rex stations or work for the current thread.

## Finish

Run the task's real verification, inspect the relevant station output, and report:

- what Amp completed;
- which Rex stations remain running;
- any failed or unavailable check;
- whether delivery is only local or has also been committed, pushed, merged, or deployed.

Do not claim a factory is useful merely because the layout exists. The factory's output is completed, verified software.
