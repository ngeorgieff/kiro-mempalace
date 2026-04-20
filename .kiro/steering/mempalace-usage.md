---
inclusion: always
---

# MemPalace Usage — Steering Rules

This steering file instructs the Kiro agent on when and how to use MemPalace tools for persistent memory across sessions.

## Session Start — Load Context (L0 + L1)

On every new session (first message), immediately call these two tools to orient yourself:

1. `mempalace_status` — get palace overview (total drawers, wings, rooms)
2. `mempalace_list_wings` — get all wings with drawer counts

This gives you L0 (palace exists, rough size) and L1 (which projects/topics have memory). Use this to understand what the user has been working on.

**This is enforced by the `mempalace-auto-context` promptSubmit hook** — it fires on every message and reminds you to load context on the first message and search memory on subsequent ones.

## Proactive Memory Search — Every Message

On EVERY user message (not just memory-dependent ones), you should:

1. Extract 2-4 keywords from the user's query
2. Determine if those keywords could match anything in the palace
3. If yes, call `mempalace_search` with wing filter and max_distance=0.8
4. Weave relevant results into your response naturally

This ensures past context is always surfaced without the user needing to explicitly ask "what did we decide about X". The goal is seamless continuity across sessions.

## Before Answering Memory-Dependent Questions

When the user references past work using phrases like:
- "we decided", "last time", "our approach", "remember when"
- "what did we do about", "the plan was", "previously"
- Any reference to decisions, discussions, or context from prior sessions

**You MUST call `mempalace_search` BEFORE answering.** Do not guess or hallucinate past context.

### Search Best Practices — Token Optimization

- **Always filter by wing.** Unfiltered search returns irrelevant results from every wing, wasting tokens. Use `wing` parameter set to the current project name.
- **Add room filter when the topic is clear.** If the user asks about "backend decisions", filter by room="decisions" or room="backend".
- **Keep queries short and keyword-focused.** The `query` parameter is embedded for semantic search — use 2-4 keywords, not full sentences.
- **Set `max_distance` to 0.8** to cut low-relevance noise. Default 1.5 is too permissive.
- **Set `limit` to 3** for most queries. Only use 5 if the first 3 aren't sufficient.
- **Never run unfiltered search when a wing is known.** Always pass the wing parameter.
- **Summarize results, don't echo them.** Extract the key facts from results and present concisely — never dump raw drawer content to the user.

Example:
```
mempalace_search(query="auth approach", wing="my-project", room="decisions", limit=3, max_distance=0.8)
```

## After Significant Events — Propose Saving

After any of these events, propose a `mempalace_add_drawer` call:

- Architecture decision made
- Bug fix completed with root cause identified
- Configuration change applied
- Design pattern chosen
- Trade-off discussed and resolved

**How to propose:**
1. Summarize the decision/change in verbatim form
2. Suggest appropriate wing (workspace name) and room (topic area)
3. Present the proposed `mempalace_add_drawer` call to the user
4. **Wait for user approval** — this is a write tool, never auto-execute

Example:
```
mempalace_add_drawer(
  wing="my-project",
  room="decisions",
  content="Decided to use JWT for auth instead of sessions. Reason: stateless API, multi-service architecture. Trade-off: token revocation complexity accepted."
)
```

## Session End — Auto-Save via agentStop Hook

The `mempalace-autosave` hook fires on `agentStop` and automatically:
1. Reviews the conversation for significant decisions, bug fixes, config changes
2. Saves key context via `mempalace_add_drawer` (wing = workspace basename, room = topic)
3. Writes a diary entry in AAAK format via `mempalace_diary_write`
4. Skips saving if nothing significant happened

This mirrors the Claude plugin's Stop hook behavior — no user action required.

## Mining Projects

When the user triggers the "MemPalace Mine" hook or asks to mine a project:
1. Run `mempalace instructions mine` to get the latest CLI instructions
2. Follow those instructions step by step
3. Default to the current workspace directory if no path specified
4. Report results (wings/rooms created, drawers indexed)

Mining indexes project files with auto-classification. Use it at milestones, not continuously.

## Dynamic Instructions

For any MemPalace operation, the CLI provides up-to-date instructions:
```bash
mempalace instructions <command>
```

Where `<command>` is: `help`, `init`, `mine`, `search`, `status`.

Use this when a user-triggered hook fires to get the latest guidance from the CLI itself, ensuring instructions never go stale.

## AAAK Awareness

MemPalace uses AAAK (compressed memory format) for diary entries and some drawers. When you encounter AAAK-encoded content:

- **Read it as-is.** AAAK is designed to be agent-readable.
- **Do NOT ask the user to decode it.** You can interpret the compressed notation.
- **Use `mempalace_get_aaak_spec` if you need the dialect reference.**
- Entity codes, emotion markers, and session tags are all part of the format.

## Wing and Room Conventions

- **Wing** = project or domain name (typically `basename $PWD` for workspace projects)
- **Room** = topic area within a wing (e.g., "decisions", "backend", "frontend", "bugs", "config")

When saving new drawers, use consistent wing/room naming:
- Wing: lowercase, hyphenated project name
- Room: lowercase, descriptive topic area

## Knowledge Graph

Use `mempalace_kg_query` to find relationships between entities (people, projects, concepts). Use `mempalace_kg_timeline` to see chronological history of an entity.

These are read-only and auto-approved — use them freely when the user asks about relationships or history.

## Tools Quick Reference

### Auto-Approved (read-only, use freely)
| Tool | When to Use |
|------|------------|
| `mempalace_status` | Session start, health check |
| `mempalace_list_wings` | Session start, discover projects |
| `mempalace_list_rooms` | Explore a wing's structure |
| `mempalace_search` | Before answering memory questions |
| `mempalace_get_taxonomy` | Full palace structure overview |
| `mempalace_get_aaak_spec` | Need AAAK format reference |
| `mempalace_kg_query` | Entity relationships |
| `mempalace_kg_timeline` | Entity chronological history |
| `mempalace_diary_read` | Read agent diary entries |

### Requires Approval (write, always ask user)
| Tool | When to Use |
|------|------------|
| `mempalace_add_drawer` | Save decisions, context, exchanges |
| `mempalace_delete_drawer` | Remove incorrect/outdated entries |
| `mempalace_kg_add` | Record new entity relationships |
| `mempalace_kg_invalidate` | Mark facts as no longer true |
| `mempalace_diary_write` | Write agent session diary |
