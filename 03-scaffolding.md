# 03 — Scaffolding

The scaffolding phase has one job: produce a project that runs on `localhost` with the latest stable stack on the first try.

---

## Stack selection matrix

Match the project archetype (from `01-plan.md`) to a stack. Defaults are chosen for: modern, well-maintained, opinionated, low setup friction.

| Archetype | Frontend | Backend | DB | Tests |
|---|---|---|---|---|
| Marketing site / portfolio | React 19 + Vite 8 + TypeScript | none / static | none | Vitest + Playwright |
| Internal tool / dashboard | React 19 + Vite + TypeScript + Tailwind | Node + Fastify + Zod | SQLite + Prisma | Vitest + Playwright |
| Productivity app (Kanban/Notes/Todo) | React 19 + Vite + TypeScript + Tailwind + dnd-kit (if drag-drop) | Node + Fastify + Zod | SQLite + Prisma | Vitest + Playwright |
| SaaS product | Next.js 15 (App Router) + TypeScript + Tailwind + shadcn/ui | Next.js API routes OR separate Fastify | Postgres (local Docker) + Prisma | Vitest + Playwright |
| API service | n/a | Node + Fastify + Zod + OpenAPI | Postgres + Prisma | Vitest + supertest |
| Data / analytics dashboard | React + Vite + TypeScript + Tailwind + Recharts or visx | Fastify + DuckDB or Postgres | DuckDB (local) or Postgres | Vitest |
| CLI tool (Node) | n/a | Node + Commander + TypeScript | n/a | Vitest |
| CLI tool (Python) | n/a | Python 3.12 + Typer + Rich | n/a | pytest |
| Mobile-first PWA | React + Vite + TypeScript + Tailwind | depends | depends | Vitest + Playwright |

> Avoid Next.js when a Vite SPA suffices. Avoid Postgres when SQLite suffices. **Prefer simpler tools by default.**

---

## Bootstrap commands

### React + Vite + TypeScript (most projects)
```bash
npm create vite@latest <project-name> -- --template react-ts
cd <project-name>
npm install
npm install -D tailwindcss@latest @tailwindcss/vite@latest
npm install lucide-react clsx
# Optional based on plan:
npm install zustand          # state management
npm install @tanstack/react-query  # server state
npm install react-router-dom # routing
npm install framer-motion    # animations
npm install @dnd-kit/core @dnd-kit/sortable  # drag and drop
```

Add Tailwind via the new Vite plugin entry in `vite.config.ts`:
```ts
import tailwindcss from '@tailwindcss/vite'
export default defineConfig({ plugins: [react(), tailwindcss()] })
```
In `src/index.css`: `@import "tailwindcss";`

### Next.js 15 (SaaS / full-stack)
```bash
npx create-next-app@latest <project-name> --typescript --tailwind --app --src-dir --import-alias "@/*"
cd <project-name>
npm install
```

### Node + Fastify backend (separate service)
```bash
mkdir <project-name>-api && cd <project-name>-api
npm init -y
npm install fastify @fastify/cors zod
npm install -D typescript tsx @types/node vitest
npx tsc --init
```
Add `dev` script: `"dev": "tsx watch src/server.ts"`.

### Python (CLI or data)
```bash
mkdir <project-name> && cd <project-name>
uv init
uv add typer rich
uv add --dev pytest ruff
```
> Always use `uv` for Python. Never `pip`. Never `python -m venv`.

---

## Standard folder structure

### React/Vite SPA
```
src/
├── main.tsx
├── App.tsx
├── index.css
├── components/   (shared UI primitives)
├── features/     (feature-scoped folders, each with its own components + hooks + tests)
├── lib/          (utilities, hooks, api client)
├── routes/       (route components if using react-router)
├── store/        (zustand stores)
└── styles/       (design tokens, global styles)
public/
PLAN.md
FEATURES.md
CHANGELOG.md
README.md
```

### Next.js
```
src/
├── app/          (routes, layouts, pages)
├── components/
├── features/
├── lib/
└── styles/
```

### Fastify API
```
src/
├── server.ts     (entry)
├── routes/       (one file per resource)
├── schemas/      (Zod schemas)
├── services/     (business logic)
├── db/           (prisma client, migrations)
└── lib/          (utilities)
```

---

## Verification checklist

After scaffold, before declaring Phase 3 done:

- [ ] `git status` is clean except the new files
- [ ] `npm run dev` (or equivalent) starts without warnings
- [ ] Browser opens `http://localhost:<port>` and shows the placeholder page
- [ ] No console errors in the browser
- [ ] `npm run build` succeeds
- [ ] `npm run lint` and `npm run typecheck` pass (or the equivalents)
- [ ] First commit: "chore: scaffold project"

If any item fails, fix before proceeding to Phase 4.

---

## Latest-version verification

Before installing any package, if you're unsure of the current major:
- Check the actual project's `package.json` if running inside an existing workspace
- Otherwise, install with `@latest` and let npm resolve

**Reject** any AI suggestion to use:
- React < 19
- Vite < 7
- Next.js < 15
- Node < 20 LTS
- TypeScript < 5.4
- Prisma < 6

These are 2026 floors. Any lower means you're being given stale advice — verify and update.

---

## Anti-patterns

- **Create-React-App** — dead. Use Vite.
- **Webpack from scratch** — use Vite or Next.
- **Gulp/Grunt** — use npm scripts.
- **Express** — fine, but Fastify is faster, has built-in validation, and a better TS story.
- **Lodash** — modern JS covers 90% of it. Drop it.
- **Moment.js** — use `date-fns` or `Temporal` (when stable).
- **Bootstrap / Material UI / Chakra** — for futuristic or modern looks, use Tailwind + shadcn/ui or hand-rolled CSS.
- **Mongoose + MongoDB by default** — relational fits 90% of products. Default to Postgres or SQLite.
