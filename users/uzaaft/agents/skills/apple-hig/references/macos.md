# Designing for macOS

Source: https://developer.apple.com/design/human-interface-guidelines/designing-for-macos

## Platform characteristics

1. Display: large high-resolution displays, often including multi-display setups.
2. Ergonomics: mostly stationary desktop or laptop usage at moderate viewing distance.
3. Inputs: keyboard, pointer, game controllers, and voice in flexible combinations.
4. App sessions: short tasks and long deep-focus workflows.

## macOS system features to account for

1. Menu bar
2. File management
3. Full-screen mode
4. Dock menus

## Best-practice checklist

1. Present more content with fewer nested layers and less modality than mobile layouts.
2. Support resizing, hiding, showing, moving, and full-screen windows.
3. Expose complete command access through menu bar integration.
4. Support high-precision pointer workflows for detailed edits.
5. Implement keyboard shortcuts for efficient keyboard-first operation.
6. Allow personalization of toolbars, windows, colors, and typography where it improves workflow.

## Implementation notes

1. Design window layouts that remain useful at very small and very large sizes.
2. Keep command naming consistent between menu items, toolbar actions, and shortcuts.
3. Treat multiwindow and multiscreen use as standard behavior, not edge cases.
