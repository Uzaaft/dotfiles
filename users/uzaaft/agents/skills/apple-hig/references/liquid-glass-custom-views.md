# Liquid Glass Custom Views (SwiftUI)

Sources:
1. https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views
2. https://developer.apple.com/documentation/technologyoverviews/liquid-glass

## Core APIs

1. `glassEffect(_:in:)` to apply Liquid Glass to a custom view.
2. `interactive(_:)` to add touch and pointer responsiveness similar to system controls.
3. `GlassEffectContainer` to blend nearby effects and improve rendering performance.
4. `glassEffectUnion(id:namespace:)` to merge multiple views into one shared glass shape.
5. `glassEffectID(_:in:)` with `GlassEffectTransition` for morphing transitions.
6. `GlassButtonStyle` and `GlassProminentButtonStyle` for native-feeling button treatment.

## Practical usage rules

1. Apply `glassEffect` after visual modifiers that affect the view appearance.
2. Choose one shape family and keep it consistent across custom controls.
3. Use tint only for semantic emphasis on primary actions.
4. Keep custom effects limited to high-value controls in the navigation or interaction layer.

## Transitions and morphing

1. Use a shared namespace and stable IDs so morphing maps correctly between states.
2. Tune `GlassEffectContainer` spacing to control when shapes merge or stay distinct.
3. Use matched-geometry style transitions for related nearby controls.
4. Use materialize transitions for farther or unrelated effects.

## Performance guardrails

1. Avoid creating many glass containers in one screen.
2. Avoid scattering standalone glass effects outside containers.
3. Keep concurrent on-screen glass effects bounded and profile with Instruments.
4. Prefer system controls first, then custom effects only where differentiation is necessary.
