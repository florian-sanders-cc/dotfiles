# Review File Format

The review file is GitHub-flavored markdown. Agent lines are quoted (`>`); the human writes plain text. Status lives in each item title.

## Template

```markdown
# Review <branch>  (<base>..<head> · <YYYY-MM-DD>)

## Global feedbacks

> One short paragraph on the change overall.
> One sentence per line.

## 1 — [OPEN] <short item title>

> What and where, citing `path/to/file.ext:42`.
> Why it matters.
> Suggestion or question.

## 2 — [OPEN] <short item title>

> ...
```

Rules:
- Item numbers are stable and never reused. New items in apply mode append with the next number.
- Title status is one of `[OPEN]` `[DONE]` `[WONTFIX]` `[DISCUSS]`.
- Group nothing; a flat numbered list keeps annotation simple.
- Get the date from `date +%F` — do not rely on model-internal knowledge of the date.

## Annotated round-trip example

### After write mode

```markdown
# Review feat-auth-cache  (a1b2c3d..e4f5g6h · 2026-06-14)

## Global feedbacks

> Solid change overall, the cache layer is clean.
> Two correctness concerns and one open question below.

## 1 — [OPEN] Cache never invalidated on logout

> `AuthService.logout()` clears the session but not the token cache (`auth-service.ts:88`).
> A re-login within TTL would reuse a stale token.
> Suggest clearing `tokenCache` in `logout()`.

## 2 — [OPEN] Off-by-one in TTL check

> `isExpired()` uses `>` where `>=` is likely intended (`token.ts:31`).
> A token expiring exactly now is treated as valid for one extra tick.

## 3 — [OPEN] Why in-memory rather than the existing Redis layer?

> The repo already wraps Redis in `cache/redis-store.ts`.
> Is in-memory deliberate for this path, or worth reusing the shared store?
```

### Human annotates (plain text, between the lines)

```markdown
## 1 — [OPEN] Cache never invalidated on logout

> `AuthService.logout()` clears the session but not the token cache (`auth-service.ts:88`).
> A re-login within TTL would reuse a stale token.
> Suggest clearing `tokenCache` in `logout()`.

Yes, good catch — clear it. Do it.

## 2 — [OPEN] Off-by-one in TTL check

> `isExpired()` uses `>` where `>=` is likely intended (`token.ts:31`).

Intentional — we grant a 1-tick grace window on purpose, documented in the RFC.

## 3 — [OPEN] Why in-memory rather than the existing Redis layer?

> Is in-memory deliberate for this path, or worth reusing the shared store?

Not sure. What's the latency cost of Redis on the hot auth path?
```

### After apply mode

```markdown
## 1 — [DONE] Cache never invalidated on logout

> `AuthService.logout()` clears the session but not the token cache (`auth-service.ts:88`).
> A re-login within TTL would reuse a stale token.
> Suggest clearing `tokenCache` in `logout()`.

Yes, good catch — clear it. Do it.

> done: added `this.tokenCache.delete(userId)` in `logout()` (`auth-service.ts:91`).

## 2 — [WONTFIX] Off-by-one in TTL check

> `isExpired()` uses `>` where `>=` is likely intended (`token.ts:31`).

Intentional — we grant a 1-tick grace window on purpose, documented in the RFC.

> wontfix: confirmed deliberate grace window per RFC.

## 3 — [DISCUSS] Why in-memory rather than the existing Redis layer?

> Is in-memory deliberate for this path, or worth reusing the shared store?

Not sure. What's the latency cost of Redis on the hot auth path?

> Redis adds a network round-trip (~0.5-2ms) per check versus ~microseconds in-memory.
> For a per-request auth check, in-memory is the right call; Redis only helps if you need cross-instance sharing.
> Do you run multiple instances that must share session state?
```

The loop continues: the reviewer answers the new `>` question, re-invokes, and the agent resolves item 3 (and appends any new items found on rescan).
