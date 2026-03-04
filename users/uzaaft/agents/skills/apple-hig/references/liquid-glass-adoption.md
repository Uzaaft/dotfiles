# Adopting Liquid Glass

Source: https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass

## What to do first

1. Build with the latest Xcode and SDKs.
2. Run on latest platform releases to inspect automatic framework updates.
3. Audit custom components that bypass standard SwiftUI/UIKit/AppKit behavior.

## Key guidance

1. Leverage system frameworks to get Liquid Glass behavior automatically for bars, sheets, popovers, and controls.
2. Avoid overusing custom glass effects because heavy usage reduces focus on underlying content.
3. Test translucency and motion under accessibility settings such as Reduce Transparency and Reduce Motion.
4. Use system colors or fully-specified light, dark, and increased-contrast variants for custom colors.
5. Keep spacing standard and avoid layering many glass elements on top of each other.
6. Remove custom bar and toolbar backgrounds that compete with system-provided scroll-edge and Liquid Glass behavior.

## App icon updates

1. Rework icons as layered compositions so the system can apply reflections, blur, and depth effects.
2. Keep icon content centered to avoid clipping under system masks.
3. Use Icon Composer to preview light, dark, clear, and tinted variants.

## Navigation and layout

1. Maintain a clear navigation hierarchy separate from content.
2. Prefer split views for sidebar and inspector layouts.
3. Validate safe-area behavior near sidebars and inspectors.
4. Use background extension effects where needed for edge-to-edge continuity.
5. If tab-based navigation can become sidebar navigation in larger contexts, use adaptive tab-to-sidebar APIs.

## Menus, toolbars, and modals

1. Use standard selectors so menu items receive system action icons.
2. Group related toolbar actions consistently across platforms.
3. Provide accessibility labels for icon-only actions.
4. Hide entire toolbar items rather than only their internal views.
5. Anchor action sheets to source controls.
6. Match top contextual-menu actions with row swipe actions for consistency.

## API quick reference

1. Custom glass effects: `glassEffect(_:in:)` (SwiftUI), `UIGlassEffect` (UIKit), `NSGlassEffectView` (AppKit).
2. Grouping and performance: `GlassEffectContainer` (SwiftUI), `UIGlassContainerEffect` (UIKit).
3. Scroll-edge legibility support: `safeAreaBar(edge:alignment:spacing:content:)` (SwiftUI), `UIScrollEdgeElementContainerInteraction` (UIKit).
4. Background extension for sidebars and inspectors: `backgroundExtensionEffect()` (SwiftUI), `UIBackgroundExtensionView` (UIKit), `NSBackgroundExtensionView` (AppKit).
5. Concentric corner alignment: `rect(corners:isUniform:)` and concentric rectangle options in SwiftUI, `UICornerConfiguration` in UIKit.
6. Split views for adaptive navigation: `NavigationSplitView` (SwiftUI), `UISplitViewController` (UIKit), `NSSplitViewController` (AppKit).

## Performance and compatibility

1. Profile performance when adopting the newest SDK.
2. For custom glass effects, combine them in a glass effect container to improve rendering.
3. If you need temporary visual compatibility behavior, use the `UIDesignRequiresCompatibility` Info key.
