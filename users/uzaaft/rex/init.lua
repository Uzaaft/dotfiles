local function term(command, cwd)
    return rex.layout.block({
        flavor = "com.superlogical.terminal.shell",
        options = {
            command = command,
            cwd = cwd,
        },
    })
end

local function basename(path)
    return (path or ""):gsub("/+$", ""):match("([^/]+)$")
end

rex.action({
    name = "project_session",
    title = "New Session from Git Project…",
    category = "Session",
    keywords = "new session project repository picker",
    run = function(ctx)
        local result, err = rex.call("session.new_layer", {
            session_id = ctx.session_id,
            bounds = { x = 0.1, y = 0.1, w = 0.8, h = 0.8 },
            focus = true,
            layout = term({ "bash", "-c", [=[
set -euo pipefail
trap 'printf "\nProject picker failed. Press Enter to close.\n" >&2; read -r' ERR

client=$(rex client ls --json | jq -er '
    [.clients[] | select(.info.kind == "app")]
    | if length == 1 then .[0].client_id
      else error("Expected one Rex app client") end
')

# Leave room for Rex floating terminals whose reported grid exceeds the viewport.
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-}
    --height=80% --layout=reverse --margin=0,15%,0,0 --border=rounded
    --color=bg:#1a1b26,bg+:#292e42,fg:#c0caf5,fg+:#c0caf5,gutter:#1a1b26,border:#565f89"

project=$("$HOME/.local/bin/git-project")
[[ -n "$project" ]] || exit 0

created=$(rex new "$(basename -- "$project")" -c "$project" --json)
session=$(printf '%s' "$created" | jq -er '.session_id')
if ! rex -C "$client" do session.select session_id="$session"; then
    printf '\nSession created: %s\nSelect it with Ctrl-a s. Press Enter to close.\n' "$session" >&2
    read -r
fi
]=] }),
        })
        if err ~= nil then
            error(err, 0)
        end
        return result
    end,
})

rex.action({
    name = "swap_pane",
    title = "Swap Pane",
    category = "Pane",
    keywords = "swap rotate pane previous next",
    args = { direction = "string" },
    run = function(ctx, args)
        local view, err = rex.call("session.view", { session_id = ctx.session_id })
        if err ~= nil then
            error(err, 0)
        end

        local window = view.focused_window
        local panes = {}
        local function collect(node)
            if node.block_id ~= nil then
                table.insert(panes, node.block_id)
            elseif node.split ~= nil then
                collect(node.split.before)
                collect(node.split.after)
            end
        end

        for _, layer in ipairs(window.layers) do
            if layer.kind == "tiled" and layer.layout ~= nil then
                collect(layer.layout)
            end
        end

        for index, pane in ipairs(panes) do
            if pane == window.focused_block_id and #panes > 1 then
                local offset = args.direction == "previous" and -1 or 1
                local other = panes[((index - 1 + offset) % #panes) + 1]
                local result, swap_err = rex.call("session.swap_blocks", {
                    session_id = ctx.session_id,
                    block_id = pane,
                    other_block_id = other,
                })
                if swap_err ~= nil then
                    error(swap_err, 0)
                end
                return result
            end
        end
    end,
})

rex.action({
    name = "rotate_panes",
    title = "Rotate Pane Layout",
    category = "Pane",
    keywords = "cycle rotate pane location position horizontal vertical",
    run = function(ctx)
        local view, err = rex.call("session.view", { session_id = ctx.session_id })
        if err ~= nil then
            error(err, 0)
        end

        local panes = {}
        local horizontal = true
        local function collect(node)
            if node.block_id ~= nil then
                table.insert(panes, node.block_id)
            elseif node.split ~= nil then
                horizontal = horizontal and node.split.direction == "horizontal"
                collect(node.split.before)
                collect(node.split.after)
            end
        end

        for _, layer in ipairs(view.focused_window.layers) do
            if layer.kind == "tiled" and layer.layout ~= nil then
                collect(layer.layout)
            end
        end

        if #panes < 2 then
            return
        end

        table.insert(panes, 1, table.remove(panes))
        local direction = horizontal and "vertical" or "horizontal"
        for index = #panes, 2, -1 do
            local _, move_err = rex.call("session.move_block", {
                session_id = ctx.session_id,
                block_id = panes[index],
                anchor_block_id = panes[1],
                direction = direction,
                side = "after",
                ratio = (index - 1) / index,
            })
            if move_err ~= nil then
                error(move_err, 0)
            end
        end
    end,
})

rex.mode("prefix")

rex.bind("ctrl+a", "client.mode.enter", { name = "prefix", once = true })
rex.bind("ctrl+space", "client.tab.previous")

rex.bind("prefix/a", "pane.send_key", { key = "ctrl+a" })
rex.bind("prefix/shift+[Quote]", "pane.split.down")
rex.bind("prefix/shift+[Digit5]", "pane.split.right")
rex.bind("prefix/c", "client.tab.new")
rex.bind("prefix/shift+[Semicolon]", "client.palette.toggle")
rex.bind("prefix/shift+[Digit4]", "session.rename")
rex.bind("prefix/s", "session.switch")
rex.bind("prefix/[Comma]", "client.tab.rename")
rex.bind("prefix/shift+s", "project_session")
rex.bind("prefix/r", "client.config.reload")

rex.bind("prefix/h", "pane.focus.left")
rex.bind("prefix/j", "pane.focus.down")
rex.bind("prefix/k", "pane.focus.up")
rex.bind("prefix/l", "pane.focus.right")
rex.bind("prefix/[Space]", "rotate_panes")

rex.bind("prefix/n", "client.tab.next")
rex.bind("prefix/p", "client.tab.previous")
rex.bind("prefix/x", "pane.close")
rex.bind("prefix/z", "pane.zoom")
