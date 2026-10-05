---
name: operating-amp-factory
description: Builds and operates an Amp-only personal software factory in Rex using `rex do` to arrange split panes for tests, servers, logs, diffs, and review. Use when asked to set up a software factory, orchestrate development work in Rex, or keep an Amp task moving with visible supporting terminals.
compatibility: Requires Amp and Rex CLIs and a live Rex session.
---

# Operating an Amp Factory

Use Amp as the only agent runtime and Rex as the visible control plane. Treat the current Amp pane as the factory anchor and arrange purpose-built terminal splits around it for tests, servers, logs, diffs, and review.

## Boundaries

- Keep implementation in the current Amp thread unless a genuinely independent workstream justifies another native Amp thread.
- Use Amp's thread and subagent tools for agent coordination. Do not launch, continue, or message Amp agents through shell commands or Rex.
- Do not support Claude Code, Codex, OpenCode, or other agent runtimes.
- Use Rex to operate terminals and layouts, not to bypass Amp's approval, thread, or delegation rules.
- Default to one coding agent. Add parallel Amp work only when the tasks are independent and their checkouts and file ownership are explicit.
- Preserve existing panes and processes. Create only the stations the task needs, and never type into a pane without first establishing what it is running.

## Orient

Read the inherited Rex context once:

```sh
env | sort | rg '^REX_(SERVER|SESSION|BLOCK)='
rex session inspect "$REX_SESSION" --json
rex block inspect "$REX_BLOCK" --json
```

Treat `REX_SESSION` and `REX_BLOCK` as the factory's origin, not necessarily the currently focused pane. Rename a generic session to two to four lowercase hyphenated words describing the work.

Find the project root, repository guidance, actual development commands, and existing running stations before changing the layout. Do not invent `npm`, `pnpm`, test, server, or log commands.

## Design the split layout

Choose stations from the work rather than creating a fixed dashboard:

- **Agent:** the current Amp terminal and stable layout anchor; never replace, split by guessed focus, or close it incidentally.
- **Test:** the narrowest useful test or watch command.
- **Server:** a long-lived development server when the work needs one.
- **Logs:** output that must remain visible while Amp works.
- **Review:** a finite diff, status, or verification command.

Default to one tab with a small, readable binary split tree:

```diagram
┌────────────────────────────┬──────────────┐
│                            │ Server/Logs  │
│ Amp                        │              │
│                            ├──────────────┤
│                            │ Secondary    │
├────────────────────────────┤ long-lived   │
│ Tests/Review               │ station      │
└────────────────────────────┴──────────────┘
```

- Split **right** for a long-lived sibling such as a server or log stream. Give the new pane about 30% of the width.
- Split **down** from the Amp anchor for tests, review output, or another compact feedback loop. Give the new pane about 30% of the anchor's height.
- Split an existing support pane when two related streams belong together, such as server over logs.
- Use a new window only for a genuinely separate subcontext, not as the default station container.
- Create every support split with `focus = false` so Amp remains focused.

Inspect the current session before creating anything. Reuse a pane whose label, working directory, and process already match the required role. Never infer the anchor from global focus; use the inherited `REX_BLOCK` or an explicitly resolved full block ID.

## Use `rex do` as the orchestration primitive

Use one `rex do` Lua script for a cohesive layout change. Pass dynamic values through a generated JSON argument file; do not interpolate project paths, labels, or commands into Lua source.

Never construct JSON-encoded command arrays in shell variables and feed them back through `--argjson`. In particular, do not write nested expressions such as `'["sh","-c",("..." + $value)]'`. That crosses shell, jq, JSON, and shell-command quoting layers and is easy to over-escape.

For a complex command, put the shell program in a literal heredoc and pass it to jq as one opaque string. Let a single jq invocation construct the complete argument document. Direct commands such as `pnpm dev` may remain literal JSON arrays inside that same jq program.

Represent each station with a stable logical role, an anchor role, split geometry, and an argument-vector command. This pattern builds a split tree around the inherited Amp pane:

```sh
factory_args_file=$(mktemp "${TMPDIR:-/tmp}/amp-factory.XXXXXX.json")
trap 'rm -f "$factory_args_file"' EXIT

hardware_script=$(cat <<'SH'
system_profiler SPHardwareDataType SPDisplaysDataType
printf '\nMetal tools:\n'
xcrun -f metal 2>/dev/null || true
exec "${SHELL:-/bin/zsh}" -l
SH
)

review_script=$(cat <<'SH'
printf 'Repository: '
git rev-parse --show-toplevel
printf '\nBranch/status:\n'
git status --short --branch
exec "${SHELL:-/bin/zsh}" -l
SH
)

jq -n \
  --arg session "$REX_SESSION" \
  --arg anchor "$REX_BLOCK" \
  --arg cwd "$project_dir" \
  --arg hardware_script "$hardware_script" \
  --arg review_script "$review_script" \
  '{
    session_id: $session,
    anchor_block_id: $anchor,
    cwd: $cwd,
    stations: [
      {
        role: "hardware", label: "Apple Hardware", anchor: "amp",
        direction: "horizontal", side: "after", ratio: 0.70,
        command: ["sh", "-c", $hardware_script]
      },
      {
        role: "review", label: "Audit Review", anchor: "amp",
        direction: "vertical", side: "after", ratio: 0.72,
        command: ["sh", "-c", $review_script]
      }
    ]
  }' >"$factory_args_file"

cat <<'LUA' | rex do -s "$REX_SESSION" - --args "@$factory_args_file" --json
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

local known_roles = { amp = true }
for index, station in ipairs(rex.args.stations) do
    if type(station.role) ~= "string" or station.role == "" or known_roles[station.role] then
        error("station " .. index .. " has an invalid or duplicate role", 0)
    end
    if not known_roles[station.anchor or "amp"] then
        error("station " .. index .. " has an unknown anchor role", 0)
    end
    if station.direction ~= "horizontal" and station.direction ~= "vertical" then
        error("station " .. index .. " has an invalid direction", 0)
    end
    if type(station.command) ~= "table" or #station.command == 0 then
        error("station " .. index .. " has an empty command", 0)
    end
    for argument_index, argument in ipairs(station.command) do
        if type(argument) ~= "string" then
            error("station " .. index .. " command argument " .. argument_index .. " is not a string", 0)
        end
    end
    known_roles[station.role] = true
end

local blocks = { amp = rex.args.anchor_block_id }
local created = {}
for _, station in ipairs(rex.args.stations) do
    local anchor = blocks[station.anchor or "amp"]
    if anchor == nil then
        error("unknown anchor role: " .. tostring(station.anchor), 0)
    end

    local result, err = rex.call("session.new_split", {
        session_id = rex.args.session_id,
        anchor_block_id = anchor,
        direction = station.direction,
        side = station.side or "after",
        ratio = station.ratio,
        focus = false,
        layout = terminal(station.command, station.cwd or rex.args.cwd),
    })
    if err ~= nil then
        error(err, 0)
    end
    local block_id = result.block_ids[1]
    blocks[station.role] = block_id

    local _, label_err = rex.call("session.set_block_label", {
        session_id = rex.args.session_id,
        block_id = block_id,
        label = station.label,
    })
    if label_err ~= nil then
        error(label_err, 0)
    end

    table.insert(created, {
        role = station.role,
        block_id = block_id,
        split_ids = result.split_ids,
    })
end
return created
LUA
```

The temporary file avoids command-line quoting and size limits. Remove it after `rex do` returns; Rex has already copied the terminal options by then. Validate it before mutation when constructing a more dynamic document:

```sh
jq -e '
  .session_id != "" and
  .anchor_block_id != "" and
  (.stations | type == "array" and length > 0) and
  all(.stations[]; .command | type == "array" and length > 0)
' "$factory_args_file" >/dev/null
```

In Rex, `horizontal` divides width and `vertical` divides height. The ratio belongs to the `before` side, so `side = "after", ratio = 0.70` leaves 70% for the existing anchor and 30% for the new station. Station order matters because later stations may anchor to earlier roles. Use `sh -c` only when the command genuinely needs shell syntax. For one station, a direct `rex split -s "$REX_SESSION" -b "$REX_BLOCK" ...` command is simpler and should be preferred.

## Operate the factory

Keep the returned role-to-block mapping. Full Rex IDs are stable for the resource lifetime, but never guess or reconstruct them. Verify the relevant state instead of assuming creation means readiness:

```sh
rex capture -s "$REX_SESSION" -b "$block_id" --trim --unwrap
rex block call -s "$REX_SESSION" -b "$block_id" process
rex session inspect "$REX_SESSION" --json
```

- A server is ready only after its output or endpoint says so.
- A finite check passes only when its process reports exit status 0 and its output is correct.
- A Rex wait timeout means the process is still running, not that it failed.
- Read existing output before waiting for new output or retrying a command. A timeout or connection failure can have happened after the operation succeeded.
- A multi-split Lua script validates all station data before mutating Rex, but the individual API calls are not an atomic transaction. If it fails after execution begins, inspect labels and block IDs before deciding whether anything was created or retrying.
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
