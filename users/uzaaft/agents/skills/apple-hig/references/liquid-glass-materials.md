# Liquid Glass Materials

Sources:
1. https://developer.apple.com/design/human-interface-guidelines/materials
2. https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass

## Layering rules

1. Keep Liquid Glass in the functional layer for navigation and controls.
2. Do not use Liquid Glass for static content surfaces such as main app backgrounds.
3. Use standard materials in the content layer for depth without competing with controls.
4. Avoid glass-on-glass stacking unless you have a very specific, tested interaction.

## Variant selection

1. Use `regular` Liquid Glass by default for controls with labels or denser information.
2. Use `clear` only over visually rich media backgrounds where preserving background detail is the goal.
3. For `clear` over bright content, add a dark dimming layer around 35 percent opacity to maintain readability.
4. If media is already dark, or AVKit controls already dim content, skip extra dimming.

## Color and contrast

1. Prefer system vibrant colors on materials for stable contrast across settings.
2. Use custom tint sparingly for emphasis of primary actions, not for every control.
3. Test with Reduce Transparency, Increased Contrast, and Reduced Motion enabled.

## Platform notes for iOS, iPadOS, macOS

1. iOS and iPadOS provide four content-layer standard materials: `ultraThin`, `thin`, `regular`, and `thick`.
2. On thinner materials, avoid low-contrast label levels such as quaternary variants.
3. macOS material behavior depends on `NSVisualEffectView.Material` and blending mode choice.
4. On macOS, validate when vibrancy improves communication versus adding visual noise.
