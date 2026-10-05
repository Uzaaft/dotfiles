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

rex.bind("prefix/n", "client.tab.next")
rex.bind("prefix/p", "client.tab.previous")
rex.bind("prefix/x", "pane.close")
rex.bind("prefix/z", "pane.zoom")
