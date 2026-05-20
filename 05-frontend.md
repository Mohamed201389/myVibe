# 05 — Frontend

The frontend has two modes: **product UI** (functional apps, dashboards, SaaS) and **marketing UI** (landing pages, portfolios, agency sites). Both share foundations but optimize for different things.

For **futuristic marketing/portfolio sites** with heavy scroll storytelling, also reference the companion file `futuristic-website-instructions.md` if it ships with the kit — it has the full motion playbook.

This file focuses on **product UI** by default and notes where marketing differs.

---

## Stack defaults

- React 19 + TypeScript + Vite 8
- Tailwind CSS (latest, via `@tailwindcss/vite` plugin) for product UI
- Custom CSS modules + design tokens for marketing UI (more bespoke)
- `lucide-react` icons
- `clsx` for conditional classes
- `zustand` for client state (sparingly — most state should be server state)
- `@tanstack/react-query` for server state
- `react-router-dom` for SPA routing, or Next.js App Router for full-stack
- `framer-motion` for animations
- `react-hook-form` + `zod` for forms
- `@dnd-kit/core` for drag-and-drop
- `react-hot-toast` or `sonner` for toasts

---

## Design system foundations

### Tokens
Define in a single CSS file or Tailwind config. **Never hard-code colors, radii, or spacing in component code.**

```css
:root {
  /* Light theme defaults */
  --color-bg: #ffffff;
  --color-fg: #0a0a0c;
  --color-muted: #6b7280;
  --color-border: #e5e7eb;
  --color-accent: #4f46e5;
  --color-success: #10b981;
  --color-warning: #f59e0b;
  --color-danger: #ef4444;
  --radius-sm: 6px;
  --radius-md: 10px;
  --radius-lg: 16px;
  --shadow-sm: 0 1px 2px rgba(0,0,0,0.04);
  --shadow-md: 0 4px 12px rgba(0,0,0,0.06);
  --shadow-lg: 0 12px 32px rgba(0,0,0,0.08);
}

[data-theme="dark"] {
  --color-bg: #0a0a0c;
  --color-fg: #f4f4f6;
  --color-muted: #9ca3af;
  --color-border: #1f2128;
  --color-accent: #818cf8;
}
```

### Typography
- Single sans family (Inter, Geist, General Sans) for everything by default.
- Mono family (JetBrains Mono, Geist Mono) for numbers, code, kbd, IDs.
- Fluid type scale via `clamp()`.
- Body: 14–16px, `line-height: 1.55`.
- All-caps labels: `letter-spacing: 0.08em`, slightly smaller.

### Spacing
Use the 4px base scale: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96, 128.

### Radii
- Inputs/buttons: `--radius-md` (10px)
- Cards: `--radius-lg` (16px)
- Pills/badges: `--radius-pill` (999px)

---

## Component library

For product UI, lean on **shadcn/ui** (copy components into your repo) over installing a UI library. Reasons:
- Owns the components, no version-lock
- Full Tailwind, full theming
- No bundle bloat from unused components

Install pattern:
```bash
npx shadcn@latest init
npx shadcn@latest add button input card dialog dropdown-menu select toast
```

Build your own primitives only when shadcn doesn't cover it.

---

## Layout patterns

### App shell (dashboards, SaaS, internal tools)
```
+-----------------------------------------+
| Top bar: logo, search, user menu        |
+-----+-----------------------------------+
|     |                                   |
| Nav | Content area                      |
|     |                                   |
|     |                                   |
+-----+-----------------------------------+
```
- Top bar height: 56–64px, sticky
- Side nav width: 240–280px, collapsible to 64px icon-only
- Content area: max-width 1400px, padding 24–32px
- On mobile: side nav becomes a slide-over drawer

### Marketing
- Top: thin nav pill, sticky, blur-backdrop
- Center: hero
- Stacked sections, each full-width, max content width 1200–1280px
- Footer: minimal, mono font

---

## States — the four every component must have

Every interactive component must explicitly handle:
1. **Empty** — no data yet (illustration + CTA)
2. **Loading** — skeleton placeholders, not spinners (spinners are last resort)
3. **Error** — meaningful message + retry button
4. **Success** — the populated, working state

**Never** ship a component that only renders the success state. Test all four during development.

---

## Forms

- Use `react-hook-form` + Zod schema.
- Validate on `onBlur` for individual fields, on `submit` for the whole form.
- Show inline error messages directly under the field.
- Disable the submit button when invalid OR submitting.
- After submit success: clear form OR navigate OR show toast (pick one, be consistent across the app).
- After submit failure: focus the first invalid field.

```tsx
const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});
const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm({
  resolver: zodResolver(schema),
});
```

---

## Server state with react-query

- Every API call goes through a query or mutation hook in `src/lib/queries/`.
- Query keys: `['<resource>', <id?>, <filters?>]`.
- Mutations call `invalidateQueries` for affected resources.
- Set `staleTime: 30000` as a sensible default.
- Use optimistic updates for snappy interactions (drag-drop, toggles, deletes).

---

## Routing

### SPA (Vite)
Use `react-router-dom` v7. File-based routing is not native — define routes in `src/router.tsx`.

### Full-stack (Next.js)
App Router only. Server Components by default. Mark `'use client'` only when interactivity is needed.

### Rules
- URL is part of state — searchable lists put filters in the query string.
- No `#hash` navigation for app sections; use real routes.
- Each route lazy-loads its component (`React.lazy` or Next.js dynamic).

---

## Animation discipline

- Use Framer Motion for: page transitions, modal/drawer entrances, item reorders, success/error feedback.
- Do NOT animate every hover. Hover should be a 150ms transition at most.
- Reveal animations: 400–600ms, easing `[0.22, 1, 0.36, 1]`.
- Lists: stagger 30–50ms per item, max 8 items animated (after that, skip animation).
- Drag-drop: spring physics, not linear. `{ stiffness: 350, damping: 30 }`.
- Always respect `prefers-reduced-motion` — provide a static fallback for any motion-driven feature.

For futuristic, scroll-storytelling marketing sites: see the companion `futuristic-website-instructions.md`.

---

## Accessibility

- All inputs have `<label htmlFor=>`.
- Buttons that show icons only have `aria-label`.
- Modals trap focus and restore it on close.
- Dropdowns: full keyboard support (arrows, Escape, Enter).
- Color contrast WCAG AA minimum (4.5:1 for body, 3:1 for large text).
- Focus rings visible — never `outline: none` without a replacement.
- Skip-to-content link as the first focusable element.

---

## Performance

- Lazy-load routes (`React.lazy` + `Suspense`).
- Code-split heavy libraries (charts, editors).
- Use `<img loading="lazy" decoding="async">` for non-hero images.
- Use modern image formats (AVIF, WebP).
- Hero images preloaded (`<link rel="preload" as="image">`).
- Fonts: self-hosted woff2, `font-display: swap`.
- Avoid `box-shadow` on hover for many items (paint-heavy).
- Keep main bundle < 200KB gzipped.

---

## File layout per feature

```
src/features/board/
├── BoardPage.tsx
├── components/
│   ├── BoardHeader.tsx
│   ├── ColumnList.tsx
│   └── CardItem.tsx
├── hooks/
│   ├── useBoards.ts
│   └── useUpdateCard.ts
└── lib/
    └── boardUtils.ts
```

Keep feature folders self-contained. Cross-feature imports go through `src/lib/` or `src/components/` (shared).

---

## What to refuse

- "Add Material UI" → propose shadcn/ui or hand-rolled
- "Add Redux" → propose zustand + react-query
- "Add styled-components" → propose Tailwind or CSS modules
- "Make it a 3D scene" → only if the brief justifies; budget the performance cost
- "Add a custom font that's 400KB" → use a subset or a system font
- "Make every element animated" → propose specific animation purposes
