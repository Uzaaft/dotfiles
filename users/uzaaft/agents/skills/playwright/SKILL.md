---
name: playwright
description: Browser automation for testing, screenshots, and web interaction. Use when navigating pages, clicking elements, filling forms, taking screenshots, or automating browser tasks.
metadata:
  version: '1'
---

# Playwright

## Tools

| Category | Tools |
|----------|-------|
| **Navigate** | `browser_navigate`, `browser_navigate_back`, `browser_tabs`, `browser_close` |
| **Observe** | `browser_snapshot` (accessibility tree), `browser_take_screenshot` (visual) |
| **Interact** | `browser_click`, `browser_hover`, `browser_type`, `browser_fill_form`, `browser_select_option`, `browser_press_key`, `browser_drag`, `browser_file_upload` |
| **Control** | `browser_resize`, `browser_wait_for`, `browser_handle_dialog` |
| **Debug** | `browser_evaluate` (run JS), `browser_run_code`, `browser_console_messages`, `browser_network_requests` |
| **Setup** | `browser_install` (if browser missing) |

All tools prefixed with `mcp__playwright__`.

## Workflows

**Interact**: `browser_navigate` → `browser_snapshot` (get `ref` values) → use `ref` in `browser_click`/`browser_type`

**Screenshot**: `browser_navigate` → `browser_take_screenshot` (opts: element, fullPage)

**Forms**: `browser_navigate` → `browser_snapshot` → `browser_fill_form` with field refs

## Key Concepts

- **Snapshot**: Accessibility tree—use for actions/element discovery; returns `ref` values
- **Screenshot**: Visual only—use for verification
- **Element refs**: Always get via `browser_snapshot`; pass to interaction tools with `element` description

## Tips

- Always `browser_snapshot` before interacting
- `browser_wait_for` for dynamic content
- `browser_evaluate` runs JS in page context
- Form field types: textbox, checkbox, radio, combobox, slider
