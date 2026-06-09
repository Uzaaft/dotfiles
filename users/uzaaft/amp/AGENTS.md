# Philosophy
Safety→Perf→DX. Zero debt. Think twice, code once.

## Environment

- This is a Nix system.
- If a project does not provide a dev shell, run needed binaries thats not installed with `nix run nixpkgs#<package>`.

## Code Quality Standards

- Make minimal, surgical changes
- **Never compromise type safety**: No `any`, no non-null assertion operator (`!`), no type assertions (`as Type`)
- **Make illegal states unrepresentable**: Model domain with ADTs/discriminated unions; parse inputs at boundaries into typed structures; if state can't exist, code can't mishandle it
- **Abstractions**: Consciously constrained, pragmatically parameterised, doggedly documented

## Log Quality Standards

- **Context**: What, why, how. Not just what changed, but why it changed and how it works.
- **Clarity**: Clear, concise, unambiguous. Avoid jargon and abbreviations. Dont use arrows, emojies, or other symbols that humans wont use. I.e ===>, -> , ===, etc

### **ENTROPY REMINDER**
This codebase will outlive you. Every shortcut you take becomes
someone else's burden. Every hack compounds into technical debt
that slows the whole team down.

You are not just writing code. You are shaping the future of this
project. The patterns you establish will be copied. The corners
you cut will be cut again.

**Fight entropy. Leave the codebase better than you found it.**

## Plans
At the end of each plan, give me a list of unresolved questions to answer, if any. Make the questions extremely concise. Sacrifice grammar for the sake of concision.

## Code
- Minimal surgical changes; match existing style
- No implicit defaults→throw; use pkg manager for deps
- **Deps**: Never edit manifests manually. Use CLI: `cargo add`, `pnpm add`, `go get`, etc.
- **Types**: No escapes (any/unknown/casts). Prove, don't assume. Explicit>inferred. Sum types>magic strings. Hard type=redesign.
- **Safety**: Fail-fast. Bounded loops/queues. ≥2 asserts/fn (args+ret, pre/post, invariants). Pair asserts at multiple checkpoints.
- **Perf**: No alloc in hot paths. Batch ops. Cache-friendly layouts (arrays>pointers). Pre-alloc buffers. No hidden allocs (strings/closures/iterators). Avoid branches in critical loops. Measure first.
- **Flow**: ifs↑ fors↓. State in parents, leaves pure. Min scope.
- **Naming**: Correct nouns/verbs. Units last: `latency_ms_max`. No abbrevs (except ID/URL). Comments=why.

## Test
Verify semantic correctness. Failing tests OK if exposing real bugs.
