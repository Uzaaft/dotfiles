# Core Philosophy
Safety → Performance → Developer Experience. Zero technical debt. Think twice, code once.

## Communication
- Extremely concise; sacrifice grammar for brevity
- Plans end with unresolved questions (concise, if any)

## Code Quality

### Fundamentals
- Minimal, surgical changes
- Preserve existing code style/conventions
- No implicit defaults—throw errors instead
- Never add dependencies manually; use package manager

### Type Safety
- Never escape the type system (no `any`, `unknown`, type assertions, forced casts, unsafe coercions)
- Prove types, don't assume them—let the compiler verify
- Prefer explicit types over inferred when intent matters
- Use sum types/enums over string literals or magic values
- If a type is "too hard", redesign the data structure

### Safety
- Fail-fast: crash on programmer errors
- Fixed limits on all loops/queues (no unbounded iteration)
- Min 2 assertions per function
- Assert args, return values, pre/postconditions, invariants
- Pair assertions: validate at multiple checkpoints

### Control Flow
- Push `if`s up, `for`s down
- Centralize state in parent functions
- Keep leaf functions pure
- Minimize variable scope

### Naming
- Get nouns/verbs right
- Units/qualifiers last: `latency_ms_max`
- No abbreviations (except: ID, URL, etc.)
- Comments explain "why", not "what"

## Commits
- Conventional: `<type>[scope]: <description>`
- Commit frequently on big features
- No AI attribution

## Testing
- Verify semantically correct behavior
- Failing tests acceptable when exposing genuine bugs

## Logging
- Log meaningful, goal-aligned events only
- Consistent structure (JSON), proper levels
- Include metadata (request ID, user ID, traces)
- Never log sensitive data
