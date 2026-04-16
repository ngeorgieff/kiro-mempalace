# Memory Save Protocol

When a session ends (agent stops, user says goodbye, task is complete), write a diary entry to persist key context.

## What to save

Write a concise diary entry using `mempalace_write_diary` that captures:

- **What was accomplished** — the concrete outcome, not just "we discussed X"
- **Key decisions made** — and the reasoning behind them
- **Blockers or open questions** — anything unresolved the next session should know about
- **User preferences revealed** — coding style choices, tool preferences, naming conventions
- **Codebase context** — file structures, architectural patterns, important functions discovered

## Format

Keep entries under 200 words. Use bullet points for facts, short prose for narrative context.

## What NOT to save

- Transient debugging steps that led nowhere
- Information already stored in the codebase (comments, docs, tests)
- Exact code snippets — reference file paths instead
- Anything the user can find easily with a search

## Structured knowledge

For facts that should be directly retrievable (not just journaled), use `mempalace_write` to store them as structured entries in addition to or instead of diary entries.

Examples of structured facts worth writing:
- User's preferred test framework: pytest, not unittest
- Project uses pnpm, not npm
- DB schema is in `infra/schema.sql`
- Auth is handled by `src/middleware/auth.ts`
