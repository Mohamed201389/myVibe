# 01 — Plan

The plan is the spine of the project. A bad plan produces a confused codebase. A good plan makes every later decision obvious.

---

## The PLAN.md template

Create `PLAN.md` at the project root with exactly these sections, in this order:

```markdown
# <Project Name>

> One-sentence description of what this is.

## Goals
- The 3–5 outcomes this project must deliver.

## Non-goals
- The 3–5 things this project explicitly does NOT do (yet).

## Users & use cases
- Primary user: <who>
- Primary use case: <walkthrough in 2-3 sentences>
- Secondary use cases (if any): bullet list

## Stack
- Frontend: <e.g. React 19 + Vite 8 + TypeScript + Tailwind>
- Backend: <e.g. Node.js + Fastify + Zod>
- Database: <e.g. SQLite via Prisma>
- Tests: <e.g. Vitest + Playwright>
- Why this stack: <2 sentences>

## Architecture (one paragraph)
How data flows. Where state lives. Client–server boundaries.

## Features (priority-ordered)
### Must-have (v1)
1. Feature A — one-line description
2. Feature B — one-line description
3. ...

### Nice-to-have (post-v1)
- Feature X
- Feature Y

## Milestones
- M1: Scaffold + foundation E2E works
- M2: Must-have features 1–3
- M3: Must-have features 4–N
- M4: Polish + quality gate

## Out of scope
- Anything specifically excluded (auth, multi-tenant, mobile app, etc.)

## Open questions
- Anything you need user input on before proceeding.
```

---

## How to derive the plan from a one-line command

When the user says *"build me a Kanban app"*, the planning model has to expand that into 5+ inferred details. Apply this expansion in order:

### Step 1 — Identify the project archetype
Match the request to one of these archetypes:
- **Marketing site / landing page** — content + form, no auth, public
- **Portfolio / personal site** — content + work showcase
- **Internal tool / dashboard** — auth, CRUD, charts
- **Productivity app** — auth, multi-resource CRUD, real-time-ish UI (kanban, notes, todo, planner)
- **Two-sided marketplace** — auth, listings, transactions
- **API service** — endpoints + docs, no UI
- **SaaS product** — auth, billing, multi-tenant, settings
- **CLI tool** — terminal-first, configuration files
- **Data/analytics app** — ETL, charts, filters

Archetype determines stack, layout, and ~70% of the architecture.

### Step 2 — Infer must-have features
For a productivity app like Kanban, the must-haves are obvious:
1. Create/edit/delete boards
2. Create/edit/delete columns
3. Create/edit/delete cards
4. Drag-and-drop reordering
5. Local persistence so refresh doesn't lose data

Don't list every imaginable feature. Five must-haves is enough for v1.

### Step 3 — Cut ruthlessly to non-goals
Explicitly list what you're *not* building:
- "No user accounts in v1"
- "No collaboration / multi-user"
- "No mobile-specific app, but responsive web"
- "No notifications"
- "No file uploads"

A good non-goals list prevents scope creep mid-build.

### Step 4 — Pick the stack
Apply `03-scaffolding.md` archetype → stack table.

### Step 5 — Milestones (3–6 only)
Each milestone must be:
- **Demoable** — you can show the user a working slice
- **Independent** — completing M2 doesn't require M3's code
- **Sized to one checkpoint** — typically 2–8 hours of focused work

---

## Planning anti-patterns to avoid

- **Architecture astronautics.** Don't design microservices for a Kanban app. Start as a monolith. Split when forced.
- **Premature optimization.** Don't add Redis, queues, or workers in v1 unless the user asks.
- **Framework-of-the-week syndrome.** Use boring, battle-tested tools by default.
- **Feature inflation.** Five must-haves. Be honest about what's optional.
- **Vague success criteria.** Each feature must have a one-line acceptance condition.

---

## Validating the plan

Before showing the plan to the user, sanity-check:
- Can I imagine the final UI in my head? If not, the features are underspecified.
- Does each must-have map to a concrete UI screen or interaction?
- Does the stack match the project type? (Don't use Next.js for a CLI tool.)
- Is the first milestone a working app skeleton, not just "set up files"?
- Have I been honest about non-goals?

If any answer is "no", revise before showing.

---

## When the user changes their mind mid-build

This *will* happen. When it does:
1. Acknowledge the change in one sentence.
2. Update `PLAN.md` (don't just memorize the change).
3. Add a `CHANGELOG.md` entry: "scope: pivot from X to Y because Z".
4. Re-validate the milestones — some may collapse, others may emerge.
5. Continue from the nearest stable checkpoint.

Never silently change the plan in your head while pretending nothing happened.
