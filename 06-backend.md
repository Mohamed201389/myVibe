# 06 — Backend

The backend exists to: validate input, run business logic, persist state, return predictable shapes. Nothing more in v1.

---

## Stack defaults

- **Node.js 22 LTS** + **TypeScript 5.x**
- **Fastify** (preferred over Express — faster, built-in schema validation, better TS)
- **Zod** for runtime validation
- **Prisma** as ORM (Postgres or SQLite)
- **Pino** for logging (Fastify's default)
- **vitest** + **supertest** (or Fastify's `inject`) for tests

For Next.js projects, use **Route Handlers** (`app/api/**/route.ts`) or **Server Actions**. Same principles apply.

For Python projects: **FastAPI** + **pydantic** + **SQLAlchemy 2.x** + **uv** as package manager.

---

## Project structure

```
src/
├── server.ts              (entry, plugin registration, listen)
├── config.ts              (env loader with Zod)
├── routes/
│   ├── health.ts
│   ├── boards.ts
│   ├── columns.ts
│   └── cards.ts
├── schemas/               (Zod schemas, shared with client if same repo)
│   ├── board.ts
│   └── card.ts
├── services/              (business logic, no HTTP knowledge)
│   ├── boardService.ts
│   └── cardService.ts
├── db/
│   ├── client.ts          (prisma client)
│   └── seed.ts
├── lib/
│   ├── errors.ts          (typed error classes)
│   └── auth.ts            (when auth is added)
└── plugins/
    ├── cors.ts
    └── errorHandler.ts
```

---

## API design rules

### URLs
- Plural nouns: `/boards`, `/boards/:id`, `/boards/:id/columns`, `/columns/:id/cards`
- Verbs only at the resource leaf if RPC-ish action: `/cards/:id/move`, `/boards/:id/archive`
- No trailing slashes
- No URL versioning in v1 (add `/v1` only when you have a v2)

### Methods
- `GET /resource` — list
- `GET /resource/:id` — read one
- `POST /resource` — create
- `PATCH /resource/:id` — partial update (preferred over PUT)
- `PUT /resource/:id` — full replacement (rare)
- `DELETE /resource/:id` — delete

### Status codes
- `200` — success with body
- `201` — created (POST)
- `204` — success no body (DELETE)
- `400` — validation failed
- `401` — not authenticated
- `403` — authenticated but forbidden
- `404` — resource not found
- `409` — conflict (duplicate, version mismatch)
- `422` — semantically invalid (rare; usually 400 covers it)
- `500` — server bug

### Response shape
**Success:**
```json
{ "data": { ... } }
```
or for lists:
```json
{ "data": [...], "pagination": { "total": 120, "page": 1, "perPage": 20 } }
```

**Error:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Title is required",
    "details": [{ "field": "title", "issue": "required" }]
  }
}
```

Consistent shapes across all endpoints. Client code can rely on `response.data` always existing on success.

---

## Validation with Zod

Every endpoint validates **body, params, and querystring**. No exceptions.

```ts
import { z } from 'zod';
import { FastifyInstance } from 'fastify';

const CreateBoardBody = z.object({
  title: z.string().min(1).max(120),
  description: z.string().max(1000).optional(),
});

export async function boardRoutes(app: FastifyInstance) {
  app.post('/boards', async (req, reply) => {
    const body = CreateBoardBody.parse(req.body);
    const board = await boardService.create(body);
    return reply.code(201).send({ data: board });
  });
}
```

Use Fastify's built-in JSON-schema validation OR Zod with `fastify-type-provider-zod`. Either is fine; pick one per project.

---

## Error handling

One global error handler. Throws inside services bubble up to it.

```ts
class AppError extends Error {
  constructor(public code: string, public statusCode: number, message: string) {
    super(message);
  }
}

class NotFoundError extends AppError {
  constructor(resource: string) { super('NOT_FOUND', 404, `${resource} not found`); }
}

app.setErrorHandler((err, req, reply) => {
  if (err instanceof ZodError) {
    return reply.code(400).send({ error: { code: 'VALIDATION_ERROR', message: 'Invalid input', details: err.issues } });
  }
  if (err instanceof AppError) {
    return reply.code(err.statusCode).send({ error: { code: err.code, message: err.message } });
  }
  req.log.error(err);
  return reply.code(500).send({ error: { code: 'INTERNAL', message: 'Internal server error' } });
});
```

**Rules:**
- Services throw typed errors. They do NOT know about HTTP.
- Routes catch nothing — the global handler does.
- Never return a generic 500 with a stack trace. Log internally, return a generic message externally.
- Don't wrap everything in try/catch defensively. Only catch when you can do something meaningful.

---

## Authentication (when needed)

Default: **session cookies** for monolith apps, **JWT** for separate API + SPA, **NextAuth/Auth.js** for Next.js.

- Hash passwords with `argon2id` (not bcrypt — argon2 is current best practice).
- Sessions in Redis or DB with a `sessions` table.
- Cookies: `httpOnly`, `secure`, `sameSite: 'lax'`, 7-day expiry rolling.
- CSRF: double-submit cookie pattern OR use Fastify's `@fastify/csrf-protection`.
- Rate-limit auth endpoints aggressively (5 attempts / 15 min per IP).

**Do NOT** add auth in v1 unless the plan demands it. Local single-user apps don't need login.

---

## Logging

- Pino is Fastify's default. Log to stdout in dev, JSON in production.
- Levels: `trace`, `debug`, `info`, `warn`, `error`, `fatal`.
- Log requests automatically (Fastify does this).
- Log business events at `info` (e.g. "card_moved").
- Log errors with the original error object: `req.log.error({ err }, 'failed to X')`.
- NEVER log passwords, tokens, full request bodies of sensitive endpoints, PII.

---

## Config & env

`src/config.ts`:
```ts
import { z } from 'zod';
const Env = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().default(3001),
  DATABASE_URL: z.string(),
  SESSION_SECRET: z.string().min(32).optional(),
});
export const config = Env.parse(process.env);
```

- `.env` is in `.gitignore`. `.env.example` is committed with placeholder values.
- Validate env on startup. Crash loudly if invalid. Don't run with bad config.

---

## CORS

- Default: same-origin only (frontend and backend on the same port via Vite proxy in dev).
- When separate origins are needed, allowlist explicitly:
```ts
await app.register(import('@fastify/cors'), {
  origin: ['http://localhost:5173'],
  credentials: true,
});
```
- Never use `origin: '*'` with `credentials: true` (browser will block, but it's a sign you're confused).

---

## File uploads

Not in v1 unless required. When required:
- Use Fastify multipart with size limits (`fileSize: 5 * 1024 * 1024` for 5MB).
- Store on disk in a `uploads/` folder (gitignored) for dev. S3/R2 later.
- Validate content-type by sniffing the file, not just trusting the header.

---

## Background jobs

Not in v1. When required: **BullMQ + Redis**. Define jobs in `src/jobs/` with a clear naming convention.

---

## Tests for backend

- Unit-test services (no HTTP, no DB — mock the repository layer).
- Integration-test routes with `fastify.inject()` against an in-memory SQLite or a test container.
- Reset DB between tests (transaction rollback or table truncation).
- Test happy path + at least one error path per endpoint.

See `08-testing.md` for full strategy.

---

## What to refuse

- "Add a microservice" — no, monolith until pain demands split
- "Use MongoDB" — only if data is truly document-shaped; default Postgres
- "Add GraphQL" — only when REST genuinely fails (rare in v1)
- "Add gRPC" — internal use only, not for browser clients
- "Cache everything in Redis" — measure first, cache last
