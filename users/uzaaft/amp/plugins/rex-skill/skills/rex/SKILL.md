---
name: rex
description: Operates Rex through the rex CLI to manage sessions, open tabs, arrange panes, run commands, inspect terminal output, and control connected Rex apps. Use when asked to manage a Rex workspace or show work in Rex.
---

# Rex

Run `rex __internal skill` and follow the guide it prints. The guide comes from
the installed CLI, so its commands and API discovery match that version instead
of a snapshot bundled with this plugin.

If the command fails, start with `rex whoami --json`, then use `rex --help`,
`rex COMMAND --help`, and `rex api describe METHOD --json`.

For Lua configuration and automation beyond the guide, consult the
[documentation index](https://www.superlogical.com/rex/docs/llms.txt) and read the
relevant pages. Discover client actions with `rex -C CLIENT actions --json`;
server API methods and client UI actions are separate surfaces. Verify the
connected server's schemas before using examples from the website.
