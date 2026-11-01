local shell = "com.superlogical.terminal.shell"

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

rex.action{
    name = "project_session",
    title = "New Session from Git Project…",
    category = "Session",
    keywords = "new session project repository picker",
    run = function(ctx)
        return must(rex.session.new_layer{
            bounds = { x = 0.1, y = 0.1, w = 0.8, h = 0.8 },
            focus = true,
            layout = rex.layout.block{
                flavor = shell,
                options = {
                    command = { "bash", "-c", [=[
set -euo pipefail
trap 'printf "\nProject picker failed. Press Enter to close.\n" >&2; read -r' ERR

client=${1:-}

# Leave room for Rex floating terminals whose reported grid exceeds the viewport.
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-}
    --height=80% --layout=reverse --margin=0,15%,0,0 --border=rounded
    --color=bg:#1a1b26,bg+:#292e42,fg:#c0caf5,fg+:#c0caf5,gutter:#1a1b26,border:#565f89"

project=$("$HOME/.local/bin/git-project")
[[ -n "$project" ]] || exit 0

session=$(rex new "$(basename -- "$project")" -c "$project" --json | jq -er '.session_id')
if ! rex ${client:+-C "$client"} do session.select session_id="$session"; then
    printf '\nSession created: %s\nSelect it with Ctrl-a s. Press Enter to close.\n' "$session" >&2
    read -r
fi
]=], "project_session", ctx.client_id },
                },
            },
        })
    end,
}

rex.action{
    name = "swap_pane",
    title = "Swap Pane",
    category = "Pane",
    keywords = "swap rotate pane previous next",
    args = { direction = "string" },
    run = function(_, args)
        local offset = ({ previous = -1, next = 1 })[args.direction]
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

rex.bind("ctrl+space", "client.tab.previous")

-- tmux-style ctrl+a prefix. Physical key codes keep the US positions on any layout.
rex.bind("ctrl+a>a", "pane.send_key", { key = "ctrl+a" })
rex.bind("ctrl+a>r", "client.config.reload")
rex.bind("ctrl+a>shift+[Semicolon]", "client.palette.toggle")

rex.bind("ctrl+a>s", "session.switch")
rex.bind("ctrl+a>shift+s", "project_session")
rex.bind("ctrl+a>shift+[Digit4]", "session.rename")

rex.bind("ctrl+a>c", "client.tab.new")
rex.bind("ctrl+a>[Comma]", "client.tab.rename")
rex.bind("ctrl+a>n", "client.tab.next")
rex.bind("ctrl+a>p", "client.tab.previous")

rex.bind("ctrl+a>shift+[Quote]", "pane.split.down")
rex.bind("ctrl+a>shift+[Digit5]", "pane.split.right")
rex.bind("ctrl+a>h", "pane.focus.left")
rex.bind("ctrl+a>j", "pane.focus.down")
rex.bind("ctrl+a>k", "pane.focus.up")
rex.bind("ctrl+a>l", "pane.focus.right")
rex.bind("ctrl+a>o", "pane.focus_next")
rex.bind("ctrl+a>shift+[BracketLeft]", "swap_pane", { direction = "previous" })
rex.bind("ctrl+a>shift+[BracketRight]", "swap_pane", { direction = "next" })
rex.bind("ctrl+a>[Space]", "rotate_panes")
rex.bind("ctrl+a>shift+e", "pane.balance")
rex.bind("ctrl+a>x", "pane.close")
rex.bind("ctrl+a>z", "pane.zoom")

-- Persistent resize mode; exclusive keys cannot leak into the terminal.
rex.mode("resize", { exclusive = true })
rex.bind("ctrl+a>shift+r", "client.mode.enter", { name = "resize" })
for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
    rex.bind("resize/" .. key, "pane.resize", { direction = direction })
    rex.bind("resize/shift+" .. key, "pane.resize", { direction = direction, amount = 15 })
    rex.bind("resize/" .. direction, "pane.resize", { direction = direction })
end
rex.bind("resize/=", "pane.balance")
rex.bind("resize/enter", "client.mode.exit")
rex.bind("resize/escape", "client.mode.exit")
