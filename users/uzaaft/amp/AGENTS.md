- In all interaction and commit messages, be extremely concise and sacrifice grammar for the sake of con
cision.

## Code Quality Standards

- Make minimal, surgical changes
- **Never compromise type safety**: No `any`, no non-null assertion operator (`!`), no type assertions (
`as Type`)
- **Prefer proper enums over string unions and literal**
- **Never propose defaults. Throw errors instead.**
- **Never add dependencies manually.** Use package manager commands.

## Testing

- Write tests that verify semantically correct behavior
- **Failing tests are acceptable** when they expose genuine bugs and test correct behavior

## Plans

- At the end of each plan, give me a list of unresolved questions to answer, if any. Make the questions
extremely concise. Sacrifice grammar for the sake of concision.

## Logging
- Log only meaningful, goal-aligned events; avoid noise.
- Use consistent structure (e.g., JSON) and proper log levels.
- Add contextual metadata (request ID, user ID, stack traces).
- Centralize, aggregate, and sample logs for high-volume systems.
- Secure logs and follow clear retention policies.
- Avoid logging sensitive data or impacting performance.
