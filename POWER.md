---
name: mempalace
displayName: MemPalace - Persistent AI Memory
description: Gives Kiro persistent memory across sessions using semantic search and knowledge graphs. Remembers context, decisions, and knowledge from past conversations.
version: 1.0.0
author: kiro-mempalace contributors
keywords:
  - memory
  - palace
  - remember
  - recall
  - knowledge
  - context
  - search
  - history
  - persistent
---

# MemPalace Memory System

You have access to a persistent memory system via the `mempalace` MCP server. This memory persists across all Kiro sessions and projects.

## When to use memory

**Search memory before responding** when the user asks about:
- Something they've worked on before ("that project we discussed", "remember when we...")
- Preferences or decisions already made
- Technical context about their codebase, team, or architecture
- Any question where past context would improve your answer

**Write to memory** when you encounter:
- Key architectural decisions or rationale
- User preferences (coding style, tools, workflows)
- Recurring problems and their solutions
- Project context that would be valuable next session
- Explicit requests to remember something

## Workflow

### Session start
Call `mempalace_wake_up` at the start of sessions where the user is continuing past work. Inject the returned context naturally into your understanding — do not dump it verbatim.

### During session
- Use `mempalace_search` with natural language queries when past context would help
- Write to the diary (`mempalace_write_diary`) for significant decisions or discoveries
- Store structured knowledge with `mempalace_write` for facts that should be easily retrievable

### Session end
When the conversation wraps up or the agent stops, write a brief diary entry summarizing what was accomplished and any key context future sessions should know.

## Memory principles

- Be selective — only store what has lasting value
- Be concise — memory entries should be scannable, not verbose
- Be specific — vague memories are useless memories
- Prefer structured entries over prose for facts
- Always search before asking the user to repeat themselves
