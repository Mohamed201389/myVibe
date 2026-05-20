# 13 — Debugging Playbook

When something doesn't work, do NOT guess. Follow this protocol.

---

## The five-step debug protocol

### Step 1 — Reproduce
You cannot fix what you cannot reproduce. If the bug only "sometimes" appears, find the conditions.

- What exact steps produce the bug?
- Does it happen on a fresh DB? On a fresh browser session?
- Does it happen in incognito? On a different browser?
- Does it happen with the exact same input every time?

**Output of this step:** A repro recipe. If you can't write one, you don't understand the bug yet.

### Step 2 — Isolate
Narrow the surface area. Bisect ruthlessly.

- Comment out half the code. Does it still break? If yes, the bug is in the remaining half. If no, in the commented half.
- Strip the input to the smallest case that reproduces.
- Disable plugins, middlewares, recent changes.
- `git bisect` to find the introducing commit if it used to work.

**Output of this step:** The smallest possible code path that triggers the bug.

### Step 3 — Form a hypothesis
Based on the isolation, what do you *believe* is happening?

State it as a falsifiable claim: "I believe the bug is X causing Y because Z."

Then design the test that would prove or disprove it. Common tests:
- `console.log` / `print` to verify a value at the suspected line
- Inspect network requests in DevTools
- Inspect DB state directly via Prisma Studio or psql
- Read the source of the third-party library you suspect

**Do not skip this step.** Most failed debugging sessions are an agent applying random fixes hoping one sticks.

### Step 4 — Prove it
Run the test designed in step 3. Confirm or reject the hypothesis.

If confirmed → proceed to fix.
If rejected → return to step 2 with new information.

### Step 5 — Fix at the root
- Fix the cause, not the symptom.
- Add a test that would have caught the bug (regression test).
- Verify the fix doesn't break other tests.
- Verify the fix works in the original repro.
- Commit with a clear message: `fix(scope): brief description of what broke and why`

Optional but recommended: **document the lesson** in a project-level `NOTES.md` or session memory, especially for non-obvious bugs.

---

## The "it works locally but not deployed" pattern (this kit avoids it)

This kit is localhost-first, so this category mostly doesn't apply during v1. When deploying later, the most common causes are:
- Env vars missing or different in production
- Case-sensitive filesystem (Mac is case-insensitive by default, Linux is case-sensitive)
- Build optimizations stripping code referenced via string names
- Different Node version
- CORS / cookies differ between same-origin (dev proxy) and cross-origin (prod)

But during v1 (localhost), these aren't your problem.

---

## Common bug categories and where to look

### "It used to work, now it doesn't"
- `git log --oneline -10` → review recent commits
- `git bisect start ... good ... bad` → find the breaking commit
- Most common cause: a refactor changed behavior subtly

### "Nothing happens when I click"
- Check the browser console for errors
- Check the network tab — is the request even firing?
- Is the handler attached? (DevTools → element → Event Listeners)
- Is the element actually clickable? (overlay, disabled state, pointer-events: none)

### "Data isn't saving"
- Network tab: did the request fire? What status?
- Inspect the request payload — is it what you expect?
- Check the server logs — did the request arrive?
- Check the DB directly — did the row land?
- Check the response — is the client re-fetching?

### "Animation isn't running on deployed site"
- Is the user's OS "Reduce motion" enabled? (Windows Accessibility → Visual effects → Animation effects)
- Does your CSS have `@media (prefers-reduced-motion: reduce)` killing it?
- For critical animations, use JS-driven `requestAnimationFrame` instead of CSS animations (bypasses the media query)

### "Looks weird only on Safari"
- Check `-webkit-` prefixes for newer CSS features
- Check `gap` on flex/grid (Safari is fine on modern versions, but legacy issues)
- Check date parsing — Safari is strict about ISO format
- Check sticky positioning quirks

### "Hydration mismatch" (Next.js / SSR)
- Random IDs generated on server differ from client
- `Date.now()` or `Math.random()` in render
- Different content based on `window`/`navigator` (use `useEffect` to set after mount)
- Server-side rendering of dates without timezone control

### "Test passes locally, fails in CI"
- Timezone differences (always set `TZ=UTC` in tests)
- Locale differences (always set `LC_ALL=en_US.UTF-8`)
- Race conditions (parallel test workers, shared DB state)
- Filesystem case sensitivity

### "Slow page load"
- DevTools Network tab — what's the largest resource? What's the slowest?
- Lighthouse — what does it flag?
- React DevTools Profiler — what's re-rendering and how often?
- Check bundle size: `npm run build` outputs sizes; anything > 500KB JS is suspect

### "Memory leak / browser slows down"
- DevTools Memory tab — take heap snapshots before/after the suspected operation
- Common causes: event listeners not cleaned up, setInterval not cleared, growing refs/maps
- Check `useEffect` cleanup functions
- Check WebSocket / EventSource connections being recreated without close

---

## When stuck (genuinely, not just frustrated)

You're "stuck" when 30 minutes of debug protocol haven't produced a working hypothesis.

1. **Step away physically** (if a human) or **switch context** (if an agent — read the spec, re-read the code, look at recent commits in full).
2. **Rubber-duck:** explain the bug out loud (or write it out for an agent) as if to a colleague. Often you'll realize the answer mid-explanation.
3. **Search the exact error message** — Google / GitHub issues / Stack Overflow.
4. **Try a minimal reproduction in a fresh project** — sometimes the bug isn't in your code at all.
5. **Ask the user** with the repro recipe and your top hypothesis.

**Never:**
- Wholesale rewrite the suspect code "to see if that helps"
- Add try/catch to suppress the error
- Change unrelated code "just in case"
- Pretend the bug is fixed when you only suppressed it

---

## Tools to know

### Frontend
- **Browser DevTools** (Chrome/Edge) — Elements, Console, Network, Performance, Memory, Application, Sources (breakpoints)
- **React DevTools** extension — Components tab, Profiler tab
- **Redux DevTools** (if using Redux) — time travel
- **Why Did You Render** — find unnecessary re-renders

### Backend
- **Server logs** (Pino in JSON, pretty in dev)
- **Prisma Studio** (`npx prisma studio`) — browse DB visually
- **psql / sqlite3** CLI — direct DB queries
- **httpie** or **curl** — manual API requests

### Network
- **wireshark** / **mitmproxy** — when DevTools isn't enough (rare)
- **ngrok inspector** — when working with webhooks

### Performance
- **Chrome Lighthouse** — frontend perf
- **WebPageTest** — detailed waterfall
- **`autocannon`** (Node) — backend load testing
- **`hyperfine`** — CLI benchmarks

---

## What the user sees during debug

Brief, factual, no speculation:

```
Investigating: cards don't persist on refresh

Repro confirmed: create card → refresh → card gone.
Network: POST /api/cards returns 201 with id.
DB check: SELECT * FROM cards returns 0 rows.
Hypothesis: route returns success without awaiting prisma.create.
Reading src/routes/cards.ts...
```

Then either: confirmed + fix incoming, or: hypothesis wrong, here's the next step.

No "Hmm, let me think..." filler. No "I'll try a few things." Be specific.

---

## After every nontrivial bug

Write a one-paragraph postmortem in `CHANGELOG.md` (under `### Fixed`) or in session notes:

- What broke
- Why it broke (root cause, one sentence)
- How it was fixed (one sentence)
- What test prevents regression

This costs 2 minutes. It saves hours when the same class of bug returns.
