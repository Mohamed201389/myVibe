# INTAKE — One-Shot Discovery (run BEFORE Phase 1)

The single most important file in the kit. Its job: **collect every decision the agent will need, in one round, before any code is written.**

If intake is sloppy, the agent ping-pongs questions for hours. If intake is thorough, the project ships in one run.

---

## How to use this file

1. The agent receives a one-line user command (e.g. *"build me a Kanban app"*).
2. The agent fills out the intake form below using **defaults** (marked `[default: X]`) for everything plausible.
3. The agent presents the **filled-in intake** to the user in one message and asks: *"Confirm these defaults, or override any line. Reply 'go' to start."*
4. The user replies once. The agent locks the intake into `INTAKE.md` at the project root and starts Phase 1 of `00-START-HERE.md` without asking anything else.

**Only one round of clarification is allowed.** After "go", the agent commits to the choices and builds.

---

## The intake form (fill every field)

Copy this exactly into the conversation, filling in defaults based on the user's one-line command. Mark `[CONFIRM]` next to anything the user must explicitly approve.

```markdown
# Project Intake

## 1. Project identity
- Project name: <slug-or-name>                                [CONFIRM]
- One-line pitch: <what it does in 12 words or less>
- Target user: <who uses it>                                  [CONFIRM if user unclear]
- Project type: [marketing-site | saas-app | internal-tool | dashboard | api | cli | portfolio | landing | other]

## 2. Scope (v1 = localhost-only)
- Must-have features (max 5–7, ordered by priority):
  1. <feature>
  2. <feature>
  3. <feature>
  4. <feature>
  5. <feature>
- Nice-to-have (deferred to v1.1):
  - <feature>
  - <feature>
- Explicit non-goals (will NOT be built):
  - <thing>
  - <thing>
- Single-user or multi-user? [default: single-user]            [CONFIRM]
- Auth required in v1? [default: no, single-user means no auth]

## 3. Stack defaults (override only if needed)
- Frontend: [default per project type — see 03-scaffolding.md]
- Backend: [default: Fastify + Node 22 LTS, OR none if static]
- Database: [default: SQLite for single-user, Postgres+Docker for multi-user]
- Styling: [default: Tailwind for product UI, custom CSS tokens for marketing]
- Animation: [default: Framer Motion + Lenis if marketing/portfolio]
- Tests: [default: Vitest + Playwright]
- Package manager: [default: npm]
- Language: [default: TypeScript]

## 4. Data model (rough sketch)
- Primary entities: <list, e.g. Board, Column, Card, User>
- Key relationships: <e.g. Board has many Columns, Column has many Cards>
- Approximate row counts at year 1: <e.g. 100 boards, 10k cards>

## 5. UI / design direction
- Aesthetic: [minimalist | brutalist | editorial | futuristic | corporate | playful]   [CONFIRM]
- Color theme: [light | dark | both, with toggle]                          [default: light + dark toggle]
- Brand colors: <hex codes or "pick neutral defaults">
- Typography: <font names, or "kit defaults: Inter + JetBrains Mono">
- Reference sites (optional): <urls>
- Hero/landing required? [yes | no]
- Marketing surface vs product surface ratio: [all-marketing | all-product | mixed]

## 6. Interactions / motion
- Heavy scroll storytelling? [yes | no]                                    [default: no for apps, yes for marketing]
- Drag-and-drop? [where]
- Real-time updates? [no | polling | websockets]                           [default: no in v1]
- Animations beyond basic transitions? [list specific surfaces]

## 7. Forms & validation
- Major forms in v1: <list, e.g. create-board form, login form>
- Validation library: [default: Zod + react-hook-form]
- File uploads? [yes/no]                                                   [default: no in v1]

## 8. External services
- Email sending? [no | mailpit-local | sendgrid-test]                      [default: no]
- Payments? [no | stripe-test-mode]                                        [default: no]
- Maps? [no | leaflet | mapbox]                                            [default: no]
- Auth provider? [no | local | oauth]                                      [default: no]
- Analytics? [no | plausible | umami]                                      [default: no in v1]

## 9. Accessibility & i18n
- WCAG target: [default: AA]
- Languages: <list, e.g. en, ar>                                           [default: en only]
- RTL support? [yes | no]                                                  [default: no unless Arabic/Hebrew listed]

## 10. Performance budget
- Lighthouse perf target: [default: ≥90 desktop, ≥80 mobile]
- Initial JS bundle budget: [default: <250KB gzipped]
- Hero LCP target: [default: <2s]

## 11. Browser & device targets
- Browsers: [default: last 2 versions Chrome/Edge/Firefox/Safari]
- Devices: [desktop-first | mobile-first | both equal]                     [default: both]
- Minimum viewport width: [default: 360px]

## 12. Localhost dev ports (lock now to avoid collisions)
- Frontend dev: [default: 5173]
- Frontend preview: [default: 4173]
- Backend API: [default: 3001]
- DB (if Postgres): [default: 5432]

## 13. Repo & tooling
- Repo: [new-local | existing-folder | monorepo-workspace]                 [default: new-local]
- Node version: [default: 22 LTS]
- Linter/formatter: [default: ESLint + Prettier; ruff for Python]
- Pre-commit hooks: [default: optional, not required for v1]
- CI: [default: none in v1]

## 14. Content & copy
- Who writes copy? [user-provides | agent-drafts-placeholder]              [default: agent-drafts-placeholder]
- Real content available at start? [yes | no]                              [default: no — use realistic seed]
- Brand voice: <one line, e.g. "confident, technical, no corporate fluff">

## 15. Quality gates (from 14-quality-gates.md)
- All tests passing: required
- Zero lint warnings: required
- Zero TS errors: required
- Manual smoke per feature: required
- Lighthouse run before handover: [yes | no]                                [default: yes for web]
- Cross-browser smoke: [yes | no]                                          [default: yes]

## 16. Output expectations
- Where the repo lives: <path>
- Final deliverables: [running-localhost | running-localhost + README + CHANGELOG] [default: all three]
- Demo data seeded: [yes | no]                                             [default: yes]

## 17. Decisions deferred to deployment phase (DO NOT do in v1)
- Hosting
- Domain
- SSL
- CDN
- Production DB
- Production secrets
- Monitoring / Sentry
- Backups
- Email DKIM/SPF
- OAuth production credentials

## 18. Risk flags & open questions
- <anything the agent flags as risky or unclear>
- <anything genuinely needing user input that defaults can't cover>
```

---

## The agent's intake message to the user (template)

After filling the form, the agent sends ONE message like this:

```
I've prepared the project intake based on your brief: "<one-line command>".

<paste the filled-in form here>

Defaults are pre-selected. Please:
1. Override any line you want changed (just paste the line with your change)
2. Or reply "go" to lock these in and start building

I will not ask again after you reply "go" — I'll commit to these choices and ship the project end-to-end.
```

That's it. One message in. One message out. Build.

---

## Rules

### For the agent
- **Fill every field.** Empty fields = lazy intake.
- **Defaults must be plausible.** If the user said "Kanban app", don't default to "marketing site".
- **Mark `[CONFIRM]` only for decisions you cannot reasonably default.**
- **Never ask >5 questions outside the form.** If you find yourself doing that, the form is the answer — fix and resend.
- **After "go", lock and ship.** Do not re-ask. Document any mid-build decision in `CHANGELOG.md` instead.

### For mid-build scope changes
If during build the user changes their mind:
1. Stop coding mid-feature only if the change invalidates current work.
2. Update `INTAKE.md` with a `## Amendment YYYY-MM-DD` section noting what changed and why.
3. Update `PLAN.md` accordingly.
4. Note in `CHANGELOG.md` under `### Changed`: `scope: <what changed>`.
5. Resume.

### For genuinely missing info
If a field has no reasonable default AND wasn't in the user's brief:
- Don't guess silently.
- Flag it under `## 18. Risk flags & open questions`.
- Propose 2–3 options.
- The user picks one in their reply.

---

## What this prevents

Without intake:
- Build starts, agent asks question #1, user replies, agent asks #2, user replies, etc.
- After 15 questions over 2 hours, project finally starts.
- Decisions made early conflict with answers given later.
- Rework is constant.

With intake:
- Build starts after one round.
- Every decision is documented before any code.
- The agent points to `INTAKE.md` when anything is ambiguous.
- The user knows up-front what they're signing off on.

---

## Persisting intake

After the user replies "go":
1. Create `INTAKE.md` at the project root with the **final, confirmed** form.
2. Commit it as the first commit: `chore: lock project intake`.
3. Every subsequent file references it as the source of truth.
4. The agent must re-read `INTAKE.md` at every Phase boundary and every Checkpoint.

This is the contract. Once locked, it's the law of the project until amended.
