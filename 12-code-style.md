# 12 — Code Style

Style rules that apply across every language and stack used in the kit. Keep code boring, predictable, and easy to delete.

---

## The three commandments

1. **Keep functions short.** If a function exceeds ~50 lines, ask whether it does one thing.
2. **Keep files short.** If a file exceeds ~400 lines, ask whether it has one responsibility.
3. **Delete more than you add.** Every PR should leave the codebase smaller if possible.

---

## Naming

### General
- **Variables and functions** — `camelCase` in JS/TS, `snake_case` in Python
- **Classes and types** — `PascalCase`
- **Constants** — `SCREAMING_SNAKE_CASE` (only when truly constant; not for every config)
- **Files** — `kebab-case.ts` for utilities, `PascalCase.tsx` for React components
- **Folders** — `kebab-case`
- **Booleans** — start with `is`, `has`, `can`, `should`: `isLoading`, `hasError`, `canEdit`
- **Event handlers** — `handleX` for the prop, `onX` for the prop name: `<Button onClick={handleSubmit} />`
- **Async functions** — verb-first, no `Async` suffix: `fetchUser`, not `getUserAsync`
- **Collections** — plural nouns: `users`, `boards`, `cards`

### Avoid
- Single-letter names except for `i`, `j`, `k` in tight loops and `x`, `y` for coordinates
- Hungarian notation (`strName`, `bIsValid`)
- Abbreviations beyond established ones (`url`, `id`, `db`, `api`) — write out `category`, not `cat`
- Names that lie: `getUser` that also writes to a cache is misnamed

---

## Comments

**Default: don't write them.** Code should explain itself. Names + structure carry the load.

When to comment:
- **Why**, not what: `// We retry once because the upstream API has a known cold-start lag`
- **Workarounds**: `// HACK: Safari 17 mis-fires touchmove on initial render — debouncing fixes`
- **Non-obvious constraints**: `// Must run before the migration in 20260418_add_index.sql`
- **Public API doc comments** (JSDoc / TSDoc / Python docstrings) for libraries and exported functions

When to NOT comment:
- "Here we loop through the array" — yes, anyone can see that
- Restating the function signature in different words
- Commented-out code — delete it. Git remembers.
- TODOs without a ticket reference and a date

---

## Error handling

### Three patterns

**1. Throw it (let the global handler catch)**
For exceptional, unrecoverable-here errors. The route, the page, or the entrypoint catches.
```ts
if (!board) throw new NotFoundError('board');
```

**2. Return Result type (when you need both paths)**
For operations where the caller must distinguish success from failure cleanly.
```ts
type Result<T, E = Error> = { ok: true; value: T } | { ok: false; error: E };
```
Useful for validation results, parsed user input.

**3. Catch and handle (rare)**
Only when the caller can actually do something better than crash.
```ts
try {
  await sendEmail();
} catch (err) {
  logger.warn({ err }, 'email failed, queueing for retry');
  await emailQueue.enqueue(payload);
}
```

### Anti-patterns
- `try { ... } catch (e) { console.log(e) }` — swallowing errors silently
- `catch (e) { throw e }` — pointless
- `catch (e: any)` everywhere — narrow the type
- Wrapping every async call in try/catch "just in case" — most errors should bubble

---

## Imports

Order in every file:
1. Standard library / node built-ins
2. Third-party packages
3. Absolute path aliases (`@/...`)
4. Relative imports (`./...` and `../...`)
5. Type-only imports last in their group

Group with blank lines between. Example:
```ts
import { readFile } from 'node:fs/promises';

import { z } from 'zod';
import { Fastify } from 'fastify';

import { config } from '@/config';
import { db } from '@/db/client';

import { boardService } from './boardService';
import type { Board } from './types';
```

Configure ESLint + Prettier to enforce this. Don't do it manually.

---

## TypeScript

### Use real types, not `any`
- No `any` in committed code. Use `unknown` and narrow.
- `as` casts only when you've proven the type through context — never as a shortcut.
- Prefer `interface` for object shapes that may be extended; `type` for unions, intersections, primitives.

### Strict mode on
`tsconfig.json`:
```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "exactOptionalPropertyTypes": true
  }
}
```

### Schemas are the source of truth
For inputs (forms, API bodies, env), define a Zod schema and derive the TS type:
```ts
const CreateBoardSchema = z.object({ title: z.string().min(1) });
type CreateBoardInput = z.infer<typeof CreateBoardSchema>;
```
Never define the type and schema separately — they'll drift.

---

## React

### Component rules
- One component per file (top-level), additional small subcomponents in the same file if tightly coupled
- Use `function ComponentName()` declarations, not arrow functions assigned to const (better stack traces, hoisting, and `React.DevTools` naming)
- Props typed inline if simple, extracted as `type Props = { ... }` if used elsewhere
- No default exports — always named exports (find-as-you-type, refactor-friendly)

### Hooks
- Custom hooks live next to the components that use them, or in `src/lib/hooks/` if shared
- One hook per concern. Don't write `useEverything()`.
- Hooks call hooks; components call hooks. Never call a hook from a regular function.
- Effects: keep them small. One effect per concern.

### Avoid
- Inline arrow functions in JSX when the component re-renders often AND has memoized children
- `useMemo` / `useCallback` without measurable benefit — premature optimization
- Storing derived state — compute it during render
- Storing server data in `useState` — use react-query

---

## Async / await

- `async`/`await` everywhere over `.then().catch()`
- `Promise.all([a, b, c])` for parallel work; never sequence independent awaits
- No mixing of `.then` and `await` in the same function

```ts
// Good
const [boards, users] = await Promise.all([fetchBoards(), fetchUsers()]);

// Bad — serial when they could be parallel
const boards = await fetchBoards();
const users = await fetchUsers();
```

---

## File organization within a module

```ts
// 1. Imports
// 2. Types / interfaces
// 3. Constants
// 4. Helper functions (un-exported)
// 5. Main exported function / component
// 6. Additional exports if any
```

---

## Linting & formatting

Every project uses:
- **Prettier** with the default config (or one shared `.prettierrc` across all projects)
- **ESLint** with `@typescript-eslint/recommended` and `eslint-plugin-react-hooks` for React
- Pre-commit hook (`husky` + `lint-staged`) — optional but recommended

Settings:
- Prettier: `printWidth: 100, semi: true, singleQuote: true, trailingComma: 'all'`
- ESLint: `"no-warnings": "error"` — every warning is a fail

---

## Python style

- **uv** as package manager. Always.
- **ruff** for linting + formatting (replaces black, isort, flake8, pyupgrade)
- **mypy** with `strict = true`
- Type hints on every function signature
- f-strings, not `.format()` or `%`
- `pathlib.Path` over `os.path`
- Modern features: `match` statements (3.10+), `|` union (3.10+), `Self` (3.11+)

---

## What to refuse

When asked to break style:
- "Just disable the linter for this line" — fix the underlying issue
- "Use `any` to ship faster" — narrow the type, it takes 2 minutes
- "Skip the test for this PR" — write the test
- "Big PR is fine, we'll review" — split it
- "Let's add a config flag" — every flag is debt; only add when it's truly needed
- "Comment it out for now" — delete it, git remembers

---

## When in doubt

Boring wins. Smart code is hard to read tomorrow. Clear code stays clear.
