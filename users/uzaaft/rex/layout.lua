-- rex --autostart=false do ~/.config/rex/layout.lua action=save
-- rex --autostart=false do ~/.config/rex/layout.lua action=restore dry_run=true
-- Floating panes and scrollback are omitted. Restore re-runs recorded commands.

local function must(value, err)
    if value == nil then
        error(err, 0)
    end
    return value
end

local function api(method, args)
    return must(rex.call(method, args or {}))
end

local function exec(argv)
    local result = must(rex.exec(argv))
    if not result.ok then
        error(result.stderr, 0)
    end
    return result.stdout
end

local home = os.getenv("HOME")
local state = (os.getenv("XDG_STATE_HOME") or home .. "/.local/state") .. "/rex-layout"
local file = rex.args.file or state .. "/snapshot.json"
file = file:gsub("^~/", home .. "/")
local flavor = "com.superlogical.terminal.shell"

local function read_json(path)
    local stream, err = io.open(path, "r")
    if stream == nil then
        return nil, err
    end
    local text = stream:read("*a")
    stream:close()
    return rex.json.decode(text)
end

local function write_snapshot(snapshot)
    local text = must(rex.json.encode(snapshot, { indent = true })) .. "\n"
    local dir = file:match("^(.*)/") or "."
    exec({ "mkdir", "-p", "--", dir })
    -- mktemp creates a private file on the same filesystem for atomic replacement.
    local temp = exec({ "mktemp", dir .. "/.rex-layout.XXXXXX" }):gsub("\n$", "")
    local ok, err = pcall(function()
        local stream = must(io.open(temp, "w"))
        must(stream:write(text))
        must(stream:close())
        must(os.rename(temp, file))
    end)
    if not ok then
        os.remove(temp)
        error(err, 0)
    end
end

local function layout(node, blocks)
    if node.block_id ~= nil then
        return blocks[node.block_id]
    end
    return { split = {
        direction = node.split.direction,
        ratio = node.split.ratio,
        before = layout(node.split.before, blocks),
        after = layout(node.split.after, blocks),
    } }
end

local function check_directories(tree)
    if tree.block ~= nil then
        local options = tree.block.options or {}
        if options.initial_input ~= nil and not must(rex.exec({ "test", "-d", options.cwd })).ok then
            error("Command directory is missing: " .. options.cwd, 0)
        end
    else
        check_directories(tree.split.before)
        check_directories(tree.split.after)
    end
end

local function save()
    local host = api("server.status").host_id
    local sessions = {}
    for _, session in ipairs(api("session.list").sessions) do
        local windows = {}
        local view = api("session.attach", { session_id = session.session_id }).view
        for _, window in ipairs(view.windows) do
            local blocks, tiled = {}, nil
            for _, layer in ipairs(window.layers) do
                if layer.kind == "tiled" and layer.layout ~= nil then
                    tiled = tiled or layer.layout
                    for _, block in ipairs(layer.blocks or {}) do
                        local process = {}
                        if block.flavor == flavor and block.host_id == host then
                            process = api("block.method", {
                                session_id = session.session_id, block_id = block.block_id, method = "process",
                            })
                        end
                        local running = read_json(state .. "/running/" .. block.block_id .. ".json")
                        local child, foreground = process.child or {}, process.foreground or {}
                        local replay = false
                        if running ~= nil and block.block_id ~= os.getenv("REX_BLOCK") then
                            replay = running.pid == child.pid or running.pid == foreground.pid
                            for _, ancestor in ipairs(process.ancestors or {}) do
                                replay = replay or running.pid == ancestor.pid
                            end
                        end
                        local options = { cwd = foreground.cwd or child.cwd or "" }
                        if replay then
                            options.cwd = running.cwd
                            options.shell = running.shell
                            -- Bracketed paste preserves literal text against shell keybindings.
                            options.initial_input = "\27[200~" .. running.command .. "\27[201~\r"
                        end
                        blocks[block.block_id] = { block = {
                            flavor = flavor, label = block.label, options = options,
                        } }
                    end
                end
            end
            local saved = { layout = tiled and layout(tiled, blocks) or { block = { flavor = flavor } } }
            if not window.label:match("^Window [0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$") then
                saved.window_label = window.label
            end
            table.insert(windows, saved)
        end
        if #windows > 0 then
            table.insert(sessions, { ids = { session.session_id }, label = session.label, initial_windows = windows })
        end
    end
    if #sessions == 0 then
        print("Nothing to save")
        return
    end
    write_snapshot({ host_id = host, sessions = sessions })
    print("Saved " .. #sessions .. " sessions to " .. file)
end

local function restore()
    local snapshot = must(read_json(file))
    if snapshot.host_id ~= api("server.status").host_id then
        error("Snapshot belongs to another Rex host", 0)
    end
    local live = {}
    for _, session in ipairs(api("session.list").sessions) do
        live[session.session_id] = true
    end
    for _, session in ipairs(snapshot.sessions) do
        local exists = false
        for _, id in ipairs(session.ids) do
            exists = exists or live[id] == true
        end
        if exists then
            print("Skipped " .. session.label)
        elseif rex.args.dry_run then
            print("Would restore " .. session.label)
        else
            for _, window in ipairs(session.initial_windows) do
                check_directories(window.layout)
            end
            local created = api("session.create", { label = session.label, initial_windows = session.initial_windows })
            table.insert(session.ids, created.session_id)
            write_snapshot(snapshot)
            print("Restored " .. session.label)
        end
    end
end

if rex.args.action == "save" then
    save()
elseif rex.args.action == "restore" then
    restore()
else
    error("Use action=save or action=restore; optional file=PATH and dry_run=true", 0)
end
