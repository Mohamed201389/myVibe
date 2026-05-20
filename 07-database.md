# 07 — Database

The database is where state survives. Get the schema wrong early and every later feature pays interest.

---

## Default choices

| Project type | DB | Why |
|---|---|---|
| Single-user productivity app | SQLite | Zero setup, one file, perfectly fine for 100k+ rows |
| Multi-user web app, internal tool | Postgres (local Docker) | Industry standard, every cloud supports it |
| Analytics / heavy reads | DuckDB or Postgres | DuckDB for embedded analytical workloads |
| Real-time presence / pub-sub | Postgres + LISTEN/NOTIFY, or Redis if heavy | Avoid Redis as a primary store |
| Search-heavy | Postgres `tsvector` + `pg_trgm` | Don't reach for Elastic in v1 |

**ORM:** Prisma (TypeScript) or SQLAlchemy 2.x (Python). Drizzle is fine if the team prefers SQL-first.

**Do not default to MongoDB.** Document stores fit some workloads, but most "I'll use Mongo" projects regret it within 6 months when they need joins.

---

## Schema design rules

### 1. Every table has these columns
```
id          uuid (or cuid2) primary key
createdAt   timestamp with time zone, default now()
updatedAt   timestamp with time zone, default now(), auto-update on write
```

Use **UUIDs** (or cuid2) for primary keys, not auto-increment integers. Reasons:
- Safe to expose in URLs
- No collisions across environments
- Easier to merge data from multiple sources

### 2. Foreign keys are explicit
```prisma
model Card {
  id        String   @id @default(cuid())
  columnId  String
  column    Column   @relation(fields: [columnId], references: [id], onDelete: Cascade)
}
```
- Always define `onDelete` behavior. Default Prisma is RESTRICT — usually too strict.
- For child rows that don't make sense without the parent: `Cascade`.
- For child rows that should preserve: `SetNull` (and make the FK nullable).

### 3. Indexes
Add an index when:
- A column is in a `WHERE`, `ORDER BY`, or `JOIN` clause frequently
- A foreign key column (Postgres does NOT auto-index FKs)
- A unique constraint that's queried

Don't add indexes preemptively. Wait until you have a query that's slow OR an obvious access pattern.

### 4. Soft delete vs hard delete
- Default: **hard delete**.
- Soft delete (`deletedAt` timestamp) only when:
  - The user might want to restore
  - Auditing or undo is part of the product
- Soft delete adds complexity to every query — don't add it by default.

### 5. Timestamps
- `createdAt` — set on insert, never modified
- `updatedAt` — auto-update on every row modification
- Domain-specific timestamps as needed: `completedAt`, `archivedAt`, `publishedAt`
- Store as `TIMESTAMP WITH TIME ZONE` (Postgres) or ISO 8601 string (SQLite)
- Always UTC in the DB. Format on the client.

### 6. Enums
- Prefer Postgres enums or Prisma enums over string columns with check constraints.
- Keep enum values short and lowercase: `'todo'`, `'in_progress'`, `'done'`.

### 7. JSON columns
- Use sparingly. JSON columns lose schema validation, type safety, and indexability.
- Acceptable for: settings blobs, audit log details, feature flags per row.
- Not acceptable for: anything you'll filter or join on regularly.

---

## Migrations

### Rules
1. Every schema change is a migration. **No manual DB edits.**
2. One concern per migration. Don't combine "add table" and "rename column" in one.
3. Migration filenames: `YYYYMMDDHHMM_description.sql` (Prisma does this automatically).
4. Migrations are immutable once committed. To fix a bad migration, write a new one that corrects it. Never edit a merged migration file.
5. Test the migration on a copy of dev data before claiming it works.

### Workflow with Prisma
```bash
# Edit schema.prisma
npx prisma migrate dev --name add_card_position
# Generated migration goes into prisma/migrations/
# Prisma client regenerates automatically
```

### Workflow without Prisma (raw SQL)
Use `node-pg-migrate` (Node) or Alembic (Python). Same rules.

---

## Seeding

Every project has a `seed` script that populates the DB with realistic dev data:
- Enough rows to exercise empty/few/many states (e.g. 0 boards, 1 board, 10 boards, 100 boards)
- Realistic content (not "test 1", "test 2", "test 3")
- Idempotent: running seed twice doesn't double the data
- Optional flag for "wipe and reseed" vs "incremental"

```ts
// prisma/seed.ts
const seedBoards = [
  { title: 'Product Roadmap', description: 'Q3 priorities' },
  { title: 'Bug Triage', description: 'Reported issues to investigate' },
];
await prisma.board.deleteMany();
for (const b of seedBoards) await prisma.board.create({ data: b });
```

Add `prisma db seed` (or equivalent) to `package.json` scripts.

---

## Common modeling patterns

### Hierarchical positions (Kanban, lists, ordered items)
Store a **floating-point `position`** column, sorted ascending.
```
position  Float
```
- Insert at end: `position = max(position) + 1`
- Insert between A (pos 3) and B (pos 5): `position = 4`
- Insert between A (pos 4) and B (pos 4.5): `position = 4.25`
- Periodically rebalance (rare in practice for human-scale lists)

Avoid the "swap two integers" approach — it requires N updates for a single move.

### Many-to-many
Use a join table with both FKs and any join-specific columns:
```prisma
model CardLabel {
  cardId   String
  labelId  String
  addedAt  DateTime @default(now())
  @@id([cardId, labelId])
}
```

### User-scoped data (multi-user apps)
Every resource that belongs to a user has `userId` as a NOT NULL FK with index. Every query filters by `userId`. Never trust the client to scope — always enforce server-side.

### Audit log
For products that need an audit trail:
```prisma
model AuditEvent {
  id         String   @id @default(cuid())
  userId     String?
  entity     String   // 'card', 'board', etc.
  entityId   String
  action     String   // 'create', 'update', 'delete', 'move'
  details    Json
  createdAt  DateTime @default(now())
}
```
Write to this from services, not from routes.

---

## Backups (even in dev)

For SQLite: the DB file is at e.g. `prisma/dev.db`. Copy it manually before a risky migration.
For Postgres: `pg_dump > backup.sql` before any destructive migration.

In v1, dev-level backup discipline is enough. Production backups are a deployment-phase concern.

---

## Local dev DB setup

### SQLite (zero setup)
- File path in `.env`: `DATABASE_URL="file:./prisma/dev.db"`
- Add `prisma/dev.db` and `prisma/dev.db-journal` to `.gitignore`

### Postgres via Docker
```bash
docker run --name pg-dev -e POSTGRES_PASSWORD=dev -e POSTGRES_DB=appdev -p 5432:5432 -d postgres:17
```
- `DATABASE_URL="postgresql://postgres:dev@localhost:5432/appdev"`
- Add a `docker-compose.yml` for one-command DB up

```yaml
services:
  db:
    image: postgres:17
    environment:
      POSTGRES_PASSWORD: dev
      POSTGRES_DB: appdev
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
volumes:
  pgdata:
```

---

## What to refuse

- "Just use Excel / Google Sheets as DB" — no, even if it's tempting for v1
- "Store JSON blobs for everything" — no, model the schema
- "We don't need migrations" — yes you do, from commit 1
- "Use Firebase" — viable but locks you in; only if explicitly chosen
- "Use one giant `data` table with `type` column" — no, model each entity
- "Mongo because flexible schema" — flexible schema is a debt, not an asset
