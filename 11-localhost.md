# 11 — Localhost-First Workflow

Every project built with this kit must run on **localhost** end-to-end before any deployment conversation begins. This file defines the localhost-first contract.

---

## The contract

After a fresh `git clone`, the following sequence must work on any machine with Node 20+ installed:

```bash
git clone <repo>
cd <repo>
cp .env.example .env       # only if .env vars exist
npm install
npm run db:migrate          # if there's a DB
npm run db:seed             # if there's seed data
npm run dev
```

After the last command, opening `http://localhost:PORT` shows the working app.

**If any of these steps fail, the project is not localhost-ready.** Fix before claiming done.

---

## Ports (default convention)

| Service | Port |
|---|---|
| Frontend dev server (Vite) | 5173 |
| Frontend preview | 4173 |
| Backend API (separate) | 3001 |
| Next.js (frontend + API) | 3000 |
| Postgres (Docker) | 5432 |
| Redis (Docker) | 6379 |
| Playwright UI | 9323 |

Don't randomize ports. Conventions reduce cognitive load when juggling multiple projects.

---

## Frontend ↔ Backend communication in dev

### Same-origin via Vite proxy (preferred for SPA + separate API)

`vite.config.ts`:
```ts
export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:3001',
        changeOrigin: true,
      },
    },
  },
});
```

Frontend calls `/api/boards`. Vite forwards to `http://localhost:3001/boards`. No CORS issues. Production swap is trivial.

### Separate origins with CORS (for when proxy isn't an option)

Backend allows `http://localhost:5173` explicitly:
```ts
await app.register(import('@fastify/cors'), {
  origin: 'http://localhost:5173',
  credentials: true,
});
```

---

## Environment variables

### Three files
- `.env` — actual local values, **gitignored**
- `.env.example` — committed, has every key with placeholder values
- `.env.test` — committed (if tests need env), uses test-safe values

### Load and validate on startup
```ts
import { z } from 'zod';
import dotenv from 'dotenv';
dotenv.config();
const Env = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().default(3001),
  DATABASE_URL: z.string().url(),
});
export const env = Env.parse(process.env);
```

If env is invalid, the process crashes on boot with a clear message. No silent fallbacks.

---

## Database in dev

### SQLite (zero infrastructure)
- File at `prisma/dev.db`
- Gitignored
- `npm run db:migrate` runs migrations
- `npm run db:reset` wipes and reseeds

### Postgres via Docker (zero local install)
`docker-compose.yml`:
```yaml
services:
  db:
    image: postgres:17
    environment:
      POSTGRES_PASSWORD: dev
      POSTGRES_DB: appdev
    ports: ["5432:5432"]
    volumes: ["pgdata:/var/lib/postgresql/data"]
volumes:
  pgdata:
```

Bring up: `docker compose up -d`. Tear down: `docker compose down`. Wipe state: `docker compose down -v`.

---

## Scripts every project should have

`package.json`:
```json
{
  "scripts": {
    "dev": "concurrently \"npm:dev:*\"",
    "dev:api": "tsx watch src/server.ts",
    "dev:web": "vite",
    "build": "npm run build:api && npm run build:web",
    "build:api": "tsc -p tsconfig.api.json",
    "build:web": "vite build",
    "preview": "vite preview",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:e2e": "playwright test",
    "lint": "eslint . --max-warnings 0",
    "format": "prettier --write .",
    "typecheck": "tsc --noEmit",
    "db:migrate": "prisma migrate dev",
    "db:reset": "prisma migrate reset --force",
    "db:seed": "tsx prisma/seed.ts",
    "db:studio": "prisma studio"
  }
}
```

`concurrently` runs both servers with one `npm run dev`. Color-coded output, clean shutdown on Ctrl+C.

---

## Dev DX must-haves

1. **Hot reload** — frontend (Vite handles), backend (`tsx watch` or `nodemon`)
2. **Type errors visible in terminal AND editor** — both VS Code's TS server and CLI `tsc --watch`
3. **One command to start everything** — `npm run dev`
4. **One command to reset state** — `npm run db:reset`
5. **One command to run tests** — `npm test`
6. **Fast feedback** — first paint < 2s on dev server, tests under 5s for the watched file

If any of these takes more than a few seconds, the dev loop is broken. Fix the tooling before continuing feature work.

---

## What NOT to do in v1

- No Docker for the app itself in v1 — only the DB if needed
- No Kubernetes, no Helm, no Terraform
- No CI/CD pipelines yet (a checkpoint commit on main is fine)
- No staging environment
- No analytics, error tracking (Sentry), or monitoring
- No CDN, no asset optimization beyond what Vite does by default
- No multi-region anything
- No feature flags (unless they're part of the product itself)
- No A/B testing
- No auth in v1 unless explicitly in the plan
- No paid services (Stripe, SendGrid, Auth0) unless the product needs them

These all enter the conversation at deployment time, in a separate engagement. In v1 you're proving the product works.

---

## What to do when localhost isn't enough

Some features genuinely need external services:
- Email sending → use `nodemailer` + a local SMTP catcher like **Mailpit** running in Docker
- File storage → local disk in `uploads/` folder
- Auth → local sessions, don't reach for OAuth providers in v1
- Payments → use Stripe **test mode** with hardcoded test cards, no real money
- Webhooks → use **smee.io** or **ngrok** in dev

Each external service should be **optional in dev** — the app must run without it (with a clear "feature disabled" message in the UI if applicable).

---

## Multi-machine consistency

The kit assumes a developer might continue on a different machine tomorrow.

- Commit lock files (`package-lock.json`, `pnpm-lock.yaml`)
- Specify Node version in `package.json` `engines` and `.nvmrc`
  ```json
  "engines": { "node": ">=20.0.0" }
  ```
- Specify package manager: `"packageManager": "npm@10.x.x"`
- `.editorconfig` for consistent indentation
- `.prettierrc` and `.eslintrc.cjs` (or flat config) committed

A new machine should be productive in 5 minutes after clone.

---

## Health check page

Every project ships with a `/` placeholder that confirms end-to-end connectivity:
- Renders without errors
- Fetches `/api/health` (if there's a backend)
- Shows server status + DB connectivity

This is the smallest possible E2E proof that the stack works.

---

## When you hand the localhost-ready project to deployment

The handoff document (a section in README or a separate `DEPLOYMENT.md`) must answer:

- What runs and on which port
- What env vars are required (link to `.env.example`)
- What DB schema is expected (link to migrations)
- What ports/protocols the frontend expects from the backend
- What external services it talks to (if any)
- What memory/CPU it needs at idle (rough estimate)
- Where logs go
- Where uploaded files live (if any)

That's all deployment needs to take it from there. Anything more is overreach for v1.
