# Philosophy
Safety→Perf→DX. Zero debt. Think twice, code once.

## Comm
Concise; grammar optional. Plans end w/ open Qs.

## Code
- Minimal surgical changes; match existing style
- No implicit defaults→throw; use pkg manager for deps
- **Types**: No escapes (any/unknown/casts). Prove, don't assume. Explicit>inferred. Sum types>magic strings. Hard type=redesign.
- **Safety**: Fail-fast. Bounded loops/queues. ≥2 asserts/fn (args+ret, pre/post, invariants). Pair asserts at multiple checkpoints.
- **Perf**: No alloc in hot paths. Batch ops. Cache-friendly layouts (arrays>pointers). Pre-alloc buffers. No hidden allocs (strings/closures/iterators). Avoid branches in critical loops. Measure first.
- **Flow**: ifs↑ fors↓. State in parents, leaves pure. Min scope.
- **Naming**: Correct nouns/verbs. Units last: `latency_ms_max`. No abbrevs (except ID/URL). Comments=why.

## Commits
Conventional: `<type>[scope]: desc`. Frequent commits. No AI attribution.

## Test
Verify semantic correctness. Failing tests OK if exposing real bugs.

## Log
Meaningful events only. JSON, proper levels, metadata (reqID/userID/trace). No sensitive data.
