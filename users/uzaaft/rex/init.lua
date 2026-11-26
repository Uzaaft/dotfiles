-- Home Manager generates this module with hosts for the current platform.
require("hosts")

-- Layout helpers

local function must(result, err)
    if err ~= nil then
        error(err, 0)
    end
    return result
end

local function active_window()
    local view = must(rex.session.view{})
    for _, window in ipairs(view.windows or {}) do
        if window.window_id == view.active_window_id then
            return window
        end
    end
    error("no active window", 0)
end

-- Tiled panes of a window in layout order, and whether every split is horizontal.
local function tiled_panes(window)
    local panes, horizontal = {}, true
    local function collect(node)
        if node.block_id ~= nil then
            table.insert(panes, node.block_id)
        elseif node.split ~= nil then
            horizontal = horizontal and node.split.direction == "horizontal"
            collect(node.split.before)
            collect(node.split.after)
        end
    end

    for _, layer in ipairs(window.layers or {}) do
        if layer.kind == "tiled" and layer.layout ~= nil then
            collect(layer.layout)
        end
    end
    return panes, horizontal
end

-- Projects: one session per checkout under ~/repositories/HOST/OWNER/REPO.
-- jj workspaces from open_workspace sit beside their repository as REPO@NAME.

local project_root = (os.getenv("GIT_PATH") or os.getenv("HOME") .. "/repositories"):gsub("/+$", "")

-- The output of a finished command, or its error if it failed.
local function output(result)
    if result.code ~= 0 then
        error(result.stderr ~= "" and result.stderr or "exited with " .. result.code, 0)
    end
    return (result.stdout:gsub("\n$", ""))
end

-- A macOS server has launchd's PATH, so add the Nix profiles that hold jj.
-- NixOS has no /bin/zsh, but every host has /bin/sh.
local function jj(cwd, ...)
    return must(rex.exec({
        "/bin/sh", "-c",
        'PATH="$PATH:/etc/profiles/per-user/$(id -un)/bin:/run/current-system/sw/bin" exec jj "$@"',
        "jj", ...
    }, { cwd = cwd }))
end

-- "OWNER/REPO" or "OWNER/REPO [BRANCH]"; jwsr in rex.zsh builds the same label.
local function project_label(dir)
    local owner, repo = dir:match("([^/]+)/([^/]+)$")
    return ((owner .. "/" .. repo):gsub("@(.+)$", " [%1]"))
end

local function pick_project(title)
    local items, seen = {}, {}
    -- Secondary workspaces of a non-colocated jj repo have only .jj.
    local find = { "find", project_root, "-mindepth", "2", "-maxdepth", "5", "(", "-name", ".git", "-o", "-name", ".jj", ")", "-prune" }
    for marker in output(must(rex.exec(find))):gmatch("[^\n]+") do
        local dir = marker:match("^(.*)/[^/]+$")
        local owner, repo = dir:match("([^/]+)/([^/]+)$")
        local name, workspace = repo:match("^(.-)@(.+)$")
        if not seen[dir] then
            seen[dir] = true
            table.insert(items, {
                id = dir,
                title = name or repo,
                subtitle = workspace,
                detail = owner,
                icon = workspace and "branch" or "folder",
            })
        end
    end
    -- Keep each repository's workspaces directly after it.
    table.sort(items, function(a, b)
        return a.id:gsub("@", " ") < b.id:gsub("@", " ")
    end)
    return rex.ui.pick{ title = title, placeholder = "Filter projects", confirm = "Open", items = items }
end

-- The session labelled for DIR, created with a shell there when it is missing.
local function project_session(dir)
    local label = project_label(dir)
    for _, session in ipairs(must(rex.call("session.list")).sessions) do
        if session.label == label then
            return session.session_id
        end
    end
    return must(rex.call("session.create", {
        label = label,
        initial_windows = {
            {
                window_label = "shell",
                layout = rex.layout.block{
                    flavor = "com.superlogical.terminal.shell",
                    options = { cwd = dir },
                },
            },
        },
    })).session_id
end

-- With cwd, as from jws in a shell, return the session for the caller to select.
local function open(dir, from_shell)
    local session_id = project_session(dir)
    if from_shell then
        return { session_id = session_id }
    end
    rex.client.queue("session.select", { session_id = session_id })
end

rex.action{
    name = "open_project",
    title = "Open Project…",
    category = "Session",
    keywords = "new session project repository workspace picker sessionizer",
    args = { cwd = "string?" },
    run = function(_, args)
        local dir = args.cwd or pick_project("Open project")
        if dir then
            return open(dir, args.cwd ~= nil)
        end
    end,
}

-- The jj workspace of the terminal that ran the action, if it is in one.
local function block_workspace(ctx)
    if ctx.block_id == nil then
        return nil
    end
    local process = rex.call("com.superlogical.terminal.process", {
        session_id = ctx.session_id,
        block_id = ctx.block_id,
    })
    local cwd = process and process.foreground and process.foreground.cwd
    if cwd == nil then
        return nil
    end
    local result = jj(cwd, "workspace", "root", "--ignore-working-copy")
    return result.code == 0 and output(result) or nil
end

-- The directory of workspace NAME in the repo at REPO, added as REPO@NAME on top
-- of bookmark NAME, or of trunk() when there is no such bookmark, if it is missing.
local function workspace_dir(repo, name)
    local existing = jj(repo, "workspace", "root", "--ignore-working-copy", "--name", name)
    if existing.code == 0 then
        return output(existing)
    end
    local root = output(jj(repo, "workspace", "root", "--ignore-working-copy", "--name", "default"))
    local dir = root .. "@" .. name:gsub("/", "-")
    local quoted = string.format("%q", name)
    output(jj(root, "workspace", "add", "--name", name, "--revision",
        string.format('coalesce(bookmarks(exact:%s), remote_bookmarks(exact:%s, exact:"origin"), trunk())', quoted, quoted),
        dir))
    return dir
end

rex.action{
    name = "open_workspace",
    title = "Open jj Workspace…",
    category = "Session",
    keywords = "new jj jujutsu workspace worktree bookmark branch session",
    args = { name = "string?", cwd = "string?" },
    run = function(ctx, args)
        local repo = args.cwd or block_workspace(ctx) or pick_project("Open workspace in")
        if repo == nil then
            return
        end
        local name = args.name or rex.ui.input{
            title = "Workspace in " .. project_label(repo),
            placeholder = "Workspace or bookmark name",
            confirm = "Open",
        }
        if name == nil or name == "" then
            return
        end
        return open(workspace_dir(repo, name), args.cwd ~= nil)
    end,
}

-- Pane layout actions

rex.action{
    name = "swap_pane",
    title = "Swap Pane",
    category = "Pane",
    keywords = "swap rotate pane previous next",
    args = {
        type = "object",
        properties = { direction = { type = "string", enum = { "previous", "next" } } },
        required = { "direction" },
        additionalProperties = false,
    },
    run = function(_, args)
        local offset = ({ previous = -1, next = 1 })[args.direction]
        -- The server exposes the schema but does not enforce enum values yet.
        if offset == nil then
            error("direction must be previous or next", 0)
        end

        local window = active_window()
        local panes = tiled_panes(window)
        if #panes < 2 then
            return
        end

        for index, pane in ipairs(panes) do
            if pane == window.focused_block_id then
                return must(rex.session.swap_blocks{
                    block_id = pane,
                    other_block_id = panes[((index - 1 + offset) % #panes) + 1],
                })
            end
        end
    end,
}

rex.action{
    name = "rotate_panes",
    title = "Rotate Pane Layout",
    category = "Pane",
    keywords = "cycle rotate pane location position horizontal vertical",
    run = function()
        local panes, horizontal = tiled_panes(active_window())
        if #panes < 2 then
            return
        end

        table.insert(panes, 1, table.remove(panes))
        local direction = horizontal and "vertical" or "horizontal"
        for index = #panes, 2, -1 do
            must(rex.session.move_block{
                block_id = panes[index],
                anchor_block_id = panes[1],
                direction = direction,
                side = "after",
                ratio = (index - 1) / index,
            })
        end
    end,
}

-- tmux-style ctrl+a prefix. Physical key codes keep the US positions on any layout.

-- Filled after the bindings are declared: rex.bindings is load-time only.
local leader_keys = {}

rex.action{
    name = "show_keys",
    title = "Show Leader Keys",
    category = "Keys",
    run = function()
        -- Help only: selecting a row closes it without running the action.
        local _, reason, detail = rex.ui.pick{
            title = "Ctrl-a leader keys",
            placeholder = "Filter keys and actions",
            confirm = "Close",
            items = leader_keys,
        }
        if reason ~= nil and reason ~= "cancelled" then
            error(detail or ("Could not show leader keys: " .. reason), 0)
        end
    end,
}

-- App controls and activity
rex.bind("ctrl+a>a", "pane.send_key", { key = "ctrl+a" })
rex.bind("ctrl+a>shift+[Slash]", "show_keys")
rex.bind("ctrl+a>r", "client.config.reload")
rex.bind("ctrl+a>shift+[Semicolon]", "client.palette.toggle")
rex.bind("ctrl+a>v", "client.sidebar.activity.toggle")
rex.bind("ctrl+a>shift+v", "pane.view_activity")
rex.bind("ctrl+a>b", "client.sidebar.toggle")
rex.bind("ctrl+a>t", "client.theme.change")
rex.bind("ctrl+a>shift+[Comma]", "client.settings")
rex.bind("ctrl+a>ctrl+h", "client.setting.terminal.keyboard.sequence_hints")

-- Session and window pickers
rex.bind("ctrl+a>s", "session.switch")
rex.bind("ctrl+a>shift+s", "open_project")
rex.bind("ctrl+a>shift+w", "open_workspace")
rex.bind("ctrl+a>shift+[Digit4]", "session.rename")
rex.bind("ctrl+a>w", "pane.go_to")

-- Tabs: new tabs and splits inherit the focused terminal's working directory.
rex.bind("ctrl+a>c", "client.tab.new")
rex.bind("ctrl+a>[Comma]", "client.tab.rename")
rex.bind("ctrl+a>n", "client.tab.next")
rex.bind("ctrl+a>p", "client.tab.previous")
rex.bind("ctrl+a>shift+left", "client.tab.move.backward")
rex.bind("ctrl+a>shift+right", "client.tab.move.forward")
-- Rex exposes previous-in-order, not tmux's most-recently-used last-window.
rex.bind("ctrl+space", "client.tab.previous")
rex.bind("ctrl+a>ctrl+space", "client.tab.previous")
for index = 1, 9 do
    rex.bind("ctrl+a>[Digit" .. index .. "]", "client.tab.goto", { index = index })
end

-- Pane navigation and layout
rex.bind("ctrl+a>shift+[Quote]", "pane.split.down")
rex.bind("ctrl+a>shift+[Digit5]", "pane.split.right")
rex.bind("ctrl+a>h", "pane.focus.left")
rex.bind("ctrl+a>j", "pane.focus.down")
rex.bind("ctrl+a>k", "pane.focus.up")
rex.bind("ctrl+a>l", "pane.focus.right")
-- Move the pane itself, not just focus; preserve the custom cyclic swaps below.
for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
    rex.bind("ctrl+a>shift+" .. key, "pane.move", { direction = direction })
end
rex.bind("ctrl+a>o", "pane.focus_next")
rex.bind("ctrl+a>shift+o", "pane.focus_previous")
rex.bind("ctrl+a>shift+[BracketLeft]", "swap_pane", { direction = "previous" })
rex.bind("ctrl+a>shift+[BracketRight]", "swap_pane", { direction = "next" })
rex.bind("ctrl+a>[Space]", "rotate_panes")
rex.bind("ctrl+a>shift+e", "pane.balance")
rex.bind("ctrl+a>x", "pane.close")
rex.bind("ctrl+a>z", "pane.zoom")
rex.bind("ctrl+a>f", "pane.float")
rex.bind("ctrl+a>shift+f", "pane.new_floating")
rex.bind("ctrl+a>shift+m", "pane.minimize_floating")
rex.bind("ctrl+a>ctrl+m", "pane.minimize_all_floating")
rex.bind("ctrl+a>shift+[Digit1]", "pane.move_to_new_tab")
rex.bind("ctrl+a>m", "pane.move_to_tab")
rex.bind("ctrl+a>g", "pane.go_to_directory")
rex.bind("ctrl+a>i", "pane.insert_path")

-- Native copy mode supplies vi motions, v/V/Ctrl-v selection, y/Enter to yank,
-- and q/Escape to leave. Keep PageUp available for scrolling without copy mode.
rex.bind("ctrl+a>up", "client.prompt.previous")
rex.bind("ctrl+a>down", "client.prompt.next")
rex.bind("ctrl+a>[BracketLeft]", "pane.copy_mode.enter")
rex.bind("ctrl+a>pageup", "client.scroll.page_up")
rex.bind("ctrl+a>pagedown", "client.scroll.page_down")
rex.bind("ctrl+a>[Slash]", "client.find.open")
rex.bind("ctrl+a>[BracketRight]", "pane.paste")
rex.bind("ctrl+a>y", "pane.copy")

-- Persistent resize mode; exclusive keys cannot leak into the terminal.
rex.mode("resize", { exclusive = true })
rex.bind("ctrl+a>shift+r", "client.mode.enter", { name = "resize" })
for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
    rex.bind("resize/" .. key, "pane.resize", { direction = direction })
    rex.bind("resize/shift+" .. key, "pane.resize", { direction = direction, amount = 15 })
    rex.bind("resize/" .. direction, "pane.resize", { direction = direction })
    rex.bind("resize/shift+" .. direction, "pane.resize", { direction = direction, amount = 15 })
end
rex.bind("resize/=", "pane.balance")
rex.bind("resize/enter", "client.mode.exit")
rex.bind("resize/escape", "client.mode.exit")
rex.bind("resize/ctrl+c", "client.mode.exit")

for _, binding in ipairs(rex.bindings()) do
    local key = binding.key:match("^ctrl%+a>(.+)$")
    if binding.mode == nil and key then
        table.insert(leader_keys, {
            id = binding.key,
            title = key,
            subtitle = binding.action,
            detail = binding.args and must(rex.json.encode(binding.args)) or nil,
        })
    end
end
table.sort(leader_keys, function(a, b) return a.title < b.title end)
