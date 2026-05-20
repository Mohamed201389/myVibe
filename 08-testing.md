# 08 — Testing & Validation Scheme

Tests are part of the feature, not a separate task. A feature without a test is a draft. This file defines what to test, with what tools, and how to know coverage is enough.

---

## The three layers

```
        E2E tests (Playwright)        ← few (1–5 per project)
       ─────────────────────
     Integration tests (vitest)       ← many (1 per route + 1 per service flow)
   ──────────────────────────────
  Unit tests (vitest)                 ← lots (utilities, schemas, pure functions)
─────────────────────────────────────
```

Cover **every layer of the pyramid**. Don't skip the base. Don't over-invest at the top.

---

## Tools

| Layer | Tool | Why |
|---|---|---|
| Unit + Integration | Vitest | Fast, Vite-native, Jest-compatible API |
| Backend HTTP | Fastify `inject()` or supertest | In-process, no real network |
| Component (UI) | Vitest + Testing Library | Test user behavior, not implementation |
| E2E | Playwright | Real browser, real flows, parallel |
| Visual regression (optional) | Playwright screenshots | Catch unintended layout shifts |
| Performance (web) | Lighthouse CI | Track LCP, CLS, INP over time |
| Accessibility | `axe-core` via Playwright | Catch a11y regressions |

For Python: pytest + hypothesis + httpx test client.

---

## What to test (and not)

### Test
- Pure functions and utility helpers
- Zod schemas (good input + bad input cases)
- Business logic in services (happy + at least one error per branch)
- API routes (status codes, response shapes, validation)
- Database queries with side effects (use a transaction-rolled-back DB)
- React components: user-facing behavior (clicking, typing, seeing)
- Critical user journeys end-to-end (auth, primary CRUD flow, payment if applicable)

### Don't test
- Third-party library internals
- React framework code
- CSS visual exactness (use visual regression sparingly)
- Trivial getters/setters
- Implementation details ("the component calls `useEffect`")

---

## Test file conventions

- Test files live next to the code: `src/lib/utils.ts` + `src/lib/utils.test.ts`
- E2E tests live in `e2e/` at the repo root
- Use `.test.ts` extension (Vitest picks up automatically)
- One `describe` per module, one `it` per behavior
- `it` names start with "should" or describe the behavior: `it('creates a card with default position at end')`

---

## Unit test example

```ts
// src/lib/position.ts
export function midpoint(a: number, b: number) {
  return (a + b) / 2;
}

// src/lib/position.test.ts
import { describe, it, expect } from 'vitest';
import { midpoint } from './position';

describe('midpoint', () => {
  it('returns the average of two numbers', () => {
    expect(midpoint(0, 4)).toBe(2);
  });
  it('handles floats', () => {
    expect(midpoint(1.5, 2.5)).toBe(2);
  });
});
```

---

## API integration test (Fastify)

```ts
import { describe, it, expect, beforeEach } from 'vitest';
import { buildApp } from '../src/server';
import { prisma } from '../src/db/client';

describe('POST /boards', () => {
  let app: Awaited<ReturnType<typeof buildApp>>;

  beforeEach(async () => {
    app = await buildApp();
    await prisma.board.deleteMany();
  });

  it('creates a board with valid input', async () => {
    const res = await app.inject({
      method: 'POST',
      url: '/boards',
      payload: { title: 'Roadmap' },
    });
    expect(res.statusCode).toBe(201);
    const body = res.json();
    expect(body.data.title).toBe('Roadmap');
    expect(body.data.id).toBeTruthy();
  });

  it('returns 400 for missing title', async () => {
    const res = await app.inject({
      method: 'POST',
      url: '/boards',
      payload: {},
    });
    expect(res.statusCode).toBe(400);
    expect(res.json().error.code).toBe('VALIDATION_ERROR');
  });
});
```

---

## Component test example (Testing Library)

```tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { CardEditor } from './CardEditor';

it('saves on Enter and clears the input', async () => {
  const onSave = vi.fn();
  render(<CardEditor onSave={onSave} />);
  const input = screen.getByPlaceholderText(/card title/i);
  await userEvent.type(input, 'New card{Enter}');
  expect(onSave).toHaveBeenCalledWith('New card');
  expect(input).toHaveValue('');
});
```

**Rule:** Query by role, label, or text — not by `data-testid` unless absolutely necessary. If you need a test-id, the component probably lacks semantic markup.

---

## E2E test example (Playwright)

```ts
// e2e/board-flow.spec.ts
import { test, expect } from '@playwright/test';

test('user can create a board, add columns and cards', async ({ page }) => {
  await page.goto('http://localhost:5173');
  await page.getByRole('button', { name: /new board/i }).click();
  await page.getByLabel(/board title/i).fill('My First Board');
  await page.getByRole('button', { name: /create/i }).click();
  await expect(page.getByRole('heading', { name: 'My First Board' })).toBeVisible();

  await page.getByRole('button', { name: /add column/i }).click();
  await page.getByLabel(/column title/i).fill('To Do');
  await page.keyboard.press('Enter');
  await expect(page.getByText('To Do')).toBeVisible();

  await page.getByRole('button', { name: /add card/i }).click();
  await page.getByPlaceholder(/card title/i).fill('First task');
  await page.keyboard.press('Enter');
  await expect(page.getByText('First task')).toBeVisible();
});
```

**Rules:**
- Use `getByRole` and `getByLabel`, not CSS selectors.
- Each test is independent — set up its own state, clean up afterwards.
- One critical journey per spec file.
- Run against the dev server with a seeded DB (or reset before each test).

---

## Coverage targets

Hard targets are misleading, but as a sanity check:
- Lib utilities: 90%+
- Services: 80%+
- Routes: every endpoint has at least one happy + one error test
- Components: every interactive component has at least one test
- E2E: every must-have feature has at least one E2E test

Don't chase 100% — diminishing returns. Don't fall below the above — you're underinvesting.

---

## Anti-patterns

- **Snapshot tests for components** — brittle, low signal
- **Mocking everything** — you end up testing the mocks
- **Testing implementation details** ("useState was called twice") — refactor and they break
- **Skipping the failing test** — `it.skip()` in committed code is a code smell, address or delete
- **Asserting on console output** — use proper assertions
- **Sleeping in tests** — use Playwright's auto-wait, Testing Library's `findBy*`, or mock timers

---

## Test data

- Use a factory pattern for creating test entities:
```ts
function makeBoard(overrides: Partial<Board> = {}): Board {
  return { id: 'b1', title: 'Test board', createdAt: new Date(), ...overrides };
}
```
- Test data should look realistic — not "asdf" or "test1".
- Don't share state between tests. Each `it` builds its own setup.

---

## Continuous validation during the feature loop

In the Builder phase, run tests **every time** you change a file:

```bash
# Option 1: watch mode
npx vitest

# Option 2: every commit
npm test
```

If a test fails:
1. Read the failure message carefully
2. Diagnose: is the code wrong, or the test wrong, or the spec wrong?
3. Fix at the right level
4. Re-run

Never commit with a failing test. Never skip a failing test "to come back later".

---

## What "tests pass" means

Before checking off a feature:
- [ ] All unit tests for the feature pass
- [ ] All integration tests for the feature pass
- [ ] The E2E for the feature pass (if it's a primary flow)
- [ ] Full test suite passes (you didn't break something else)
- [ ] Lint + typecheck pass
- [ ] Manual smoke in browser confirms acceptance criteria

If any item fails, the feature isn't done.
