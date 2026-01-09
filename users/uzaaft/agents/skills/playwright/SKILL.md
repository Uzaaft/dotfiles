---
name: playwright
description: Browser automation for testing, screenshots, and web interaction. Use when navigating pages, clicking elements, filling forms, taking screenshots, or automating browser tasks.
metadata:
  version: '1'
---

# Playwright

Automate browser interactions for testing and web tasks.

## Available Tools

| Tool | Purpose |
|------|---------|
| `mcp__playwright__browser_navigate` | Navigate to a URL |
| `mcp__playwright__browser_navigate_back` | Go back to previous page |
| `mcp__playwright__browser_snapshot` | Capture accessibility snapshot (preferred over screenshot for actions) |
| `mcp__playwright__browser_take_screenshot` | Take visual screenshot |
| `mcp__playwright__browser_click` | Click an element |
| `mcp__playwright__browser_hover` | Hover over an element |
| `mcp__playwright__browser_type` | Type text into an element |
| `mcp__playwright__browser_fill_form` | Fill multiple form fields |
| `mcp__playwright__browser_select_option` | Select dropdown option |
| `mcp__playwright__browser_press_key` | Press keyboard key |
| `mcp__playwright__browser_drag` | Drag and drop between elements |
| `mcp__playwright__browser_file_upload` | Upload files |
| `mcp__playwright__browser_tabs` | List, create, close, or select tabs |
| `mcp__playwright__browser_resize` | Resize browser window |
| `mcp__playwright__browser_wait_for` | Wait for text/time |
| `mcp__playwright__browser_handle_dialog` | Accept/dismiss dialogs |
| `mcp__playwright__browser_evaluate` | Run JavaScript on page |
| `mcp__playwright__browser_run_code` | Run Playwright code snippet |
| `mcp__playwright__browser_console_messages` | Get console messages |
| `mcp__playwright__browser_network_requests` | Get network requests |
| `mcp__playwright__browser_close` | Close the page |
| `mcp__playwright__browser_install` | Install browser if missing |

## Workflow

### Navigate and Interact

1. **Navigate** → `browser_navigate` to URL
2. **Snapshot** → `browser_snapshot` to get element refs
3. **Interact** → Use `ref` from snapshot for `browser_click`, `browser_type`, etc.

### Take Screenshots

1. **Navigate** → `browser_navigate` to URL
2. **Screenshot** → `browser_take_screenshot` (optional: element, fullPage)

### Fill Forms

1. **Navigate** → `browser_navigate` to form page
2. **Snapshot** → `browser_snapshot` to identify fields
3. **Fill** → `browser_fill_form` with field refs and values

## Key Concepts

### Element References
- Use `browser_snapshot` to get element `ref` values
- Pass `ref` to interaction tools (`browser_click`, `browser_type`, etc.)
- Always include human-readable `element` description for permission

### Snapshot vs Screenshot
- **Snapshot**: Accessibility tree—use for actions and element discovery
- **Screenshot**: Visual image—use for visual verification only

## Tips

- Always call `browser_snapshot` before interacting with elements
- Use `browser_wait_for` when content loads dynamically
- `browser_install` if you get "browser not installed" errors
- `browser_evaluate` runs JS in page context—useful for complex interactions
- For form fields: identify `type` (textbox, checkbox, radio, combobox, slider)
