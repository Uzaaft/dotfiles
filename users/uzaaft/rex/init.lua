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
    name = "dev_session",
    title = "Dev Layout",
    category = "Layouts",
    keywords = "layout dev session harness claude hunk nvim",
    args = { harness = "string?", cwd = "string?" },
    run = function(ctx, args)
        local cwd = args.cwd
        local harness = args.harness or "claude"

        local result, err = rex.call("session.create", {
            label = basename(cwd) or "dev",
            initial_windows = {
                { window_label = harness, layout = term({ harness }, cwd) },
                { window_label = "nvim", layout = term({ "nvim" }, cwd) },
            },
        })
        if err ~= nil then
            error(err, 0)
        end

        return result
    end,
})

rex.mode("prefix")

rex.bind("ctrl+a", "client.mode.enter", { name = "prefix", once = true })
rex.bind("ctrl+space", "client.tab.previous")

rex.bind("prefix/a", "pane.send_key", { key = "ctrl+a" })
rex.bind("prefix/shift+[Quote]", "pane.split.down")
rex.bind("prefix/shift+[Digit5]", "pane.split.right")
rex.bind("prefix/c", "client.tab.new")
rex.bind("prefix/shift+s", "session.switch")
rex.bind("prefix/r", "client.config.reload")

rex.bind("prefix/h", "pane.focus.left")
rex.bind("prefix/j", "pane.focus.down")
rex.bind("prefix/k", "pane.focus.up")
rex.bind("prefix/l", "pane.focus.right")

rex.bind("prefix/n", "client.tab.next")
rex.bind("prefix/p", "client.tab.previous")
rex.bind("prefix/x", "pane.close")
rex.bind("prefix/z", "pane.zoom")
