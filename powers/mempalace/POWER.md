---
name: "mempalace"
displayName: "MemPalace"
description: "Persistent AI memory for Kiro agents via MemPalace MCP server. Stores decisions, context, and knowledge across sessions using semantic search, a knowledge graph, and compressed AAAK diary format."
keywords: ["mempalace", "memory", "persistent", "knowledge-graph", "aaak", "semantic-search"]
author: "MemPalace Community"
---

# MemPalace

## Overview

MemPalace is a local-first AI memory system that gives Kiro agents persistent memory across sessions. It stores conversations, decisions, and knowledge in a structured palace of wings (projects), rooms (topics), and drawers (individual memories), backed by ChromaDB for semantic search and SQLite for the knowledge graph.

This power integrates MemPalace's 19 MCP tools into Kiro with proper steering — the agent knows when to search memory, when to save context, and how to read the compressed AAAK diary format without bothering you.

## Available Steering Files

- **session-workflow** — Step-by-step guide for session start, mid-session memory queries, and session-end saving
- **scope-setup** — How to configure MemPalace globally vs per-workspace, and toggle between scopes

## Onboarding

### Prerequisites

- Python 3.9+
- `pip` or `pipx` available

### Installation

#### Via pip (user-level, recommended)
```bash
pip install --user mempalace
```

#### Via pipx (isolated environment)
```bash
pipx install mempalace
```

#### Verify installation
```bash
mempalace --version
```

### Initialize the Palace

```bash
mempalace init
```

This creates the palace database at `~/.palace/` (default). You can override with `MEMPALACE_PALACE_PATH` env var.

### Configuration

The MCP server is configured automatically when this power is installed. The `MEMPALACE_PALACE_PATH` environment variable controls where the palace database lives. If unset, it defaults to `~/.palace/`.

To use a custom path, edit the `env` section in the MCP config:
```json
"env": {
  "MEMPALACE_PALACE_PATH": "/path/to/your/palace"
}
```

## Common Workflows

### Session Start — Load Context

At the beginning of every session, the agent loads palace context automatically:

1. `mempalace_status` — palace overview (total drawers, wings, rooms)
2. `mempalace_list_wings` — all wings with drawer counts

This gives the agent L0 (palace exists) and L1 (which projects have memory) context without any user action.

### Search Past Decisions

When you reference past work ("we decided", "last time", "our approach"), the agent searches memory before answering:

```
mempalace_search(query="auth approach", wing="my-project", room="decisions")
```

Best practices:
- Always filter by wing when the project is known (+34% recall)
- Add room filter when the topic is clear
- Keep queries short and keyword-focused

### Save a Decision

After architecture decisions, bug fixes, or config changes, the agent proposes saving:

```
mempalace_add_drawer(
  wing="my-project",
  room="decisions",
  content="Decided to use JWT for auth. Reason: stateless API. Trade-off: token revocation complexity."
)
```

Write tools always require your approval — the agent will ask before saving.

### Knowledge Graph Queries

Find relationships between entities:
```
mempalace_kg_query(entity="AuthService", direction="both")
```

View chronological history:
```
mempalace_kg_timeline(entity="AuthService")
```

### Agent Diary

The agent can write session notes in compressed AAAK format:
```
mempalace_diary_write(agent_name="kiro", entry="SESSION:2026-04-17|built.mempalace.power|scope:global|★★★")
```

Read past diary entries:
```
mempalace_diary_read(agent_name="kiro", last_n=5)
```

## AAAK Format

MemPalace uses AAAK (compressed memory format) for diary entries. When the agent encounters AAAK content, it reads it as-is — the format is designed to be agent-readable. Use `mempalace_get_aaak_spec` to see the full dialect specification.

Key conventions:
- `|` separates fields
- `.` separates compound concepts
- `+` joins parallel items
- `★` marks importance (1-5 stars)
- Entity codes are defined in the spec

## Wing and Room Conventions

- **Wing** = project or domain name (e.g., `my-project`, `kiro-mempalace`)
- **Room** = topic area within a wing (e.g., `decisions`, `backend`, `bugs`, `config`)

Use lowercase, hyphenated names for consistency.

## Tool Reference

### Auto-Approved (read-only)

| Tool | Purpose |
|------|---------|
| `mempalace_status` | Palace overview — drawers, wings, rooms |
| `mempalace_list_wings` | All wings with drawer counts |
| `mempalace_list_rooms` | Rooms within a wing |
| `mempalace_search` | Semantic search across drawers |
| `mempalace_get_taxonomy` | Full wing → room → drawer structure |
| `mempalace_get_aaak_spec` | AAAK compressed format reference |
| `mempalace_kg_query` | Knowledge graph entity relationships |
| `mempalace_kg_timeline` | Chronological entity history |
| `mempalace_diary_read` | Read agent diary entries |
| `mempalace_kg_add` | Record new entity relationships |
| `mempalace_kg_invalidate` | Mark facts as no longer true |
| `mempalace_diary_write` | Write agent session diary |
| `mempalace_add_drawer` | Save decisions, context, exchanges |


### Requires Approval (write)

| Tool | Purpose |
|------|---------|
| `mempalace_delete_drawer` | Remove incorrect/outdated entries |


## Troubleshooting

### MCP Server Won't Start

**Symptoms:** "Connection refused" or server not responding

**Solutions:**
1. Verify installation: `mempalace --version`
2. Test the server directly: `python -m mempalace.mcp_server`
3. Check `MEMPALACE_PALACE_PATH` points to a valid directory
4. Run `mempalace init` if the palace hasn't been initialized

### Search Returns No Results

**Cause:** Wing or room name doesn't match stored data

**Solutions:**
1. Run `mempalace_list_wings` to see available wings
2. Run `mempalace_list_rooms(wing="your-wing")` to see rooms
3. Try a broader search without room filter
4. Check spelling of wing/room names

### AAAK Entries Look Like Gibberish

**This is normal.** AAAK is a compressed format for agent consumption. The agent reads it natively. Run `mempalace_get_aaak_spec` to see the format specification if you want to understand the encoding.

## Best Practices

- Let the agent search memory before answering history-dependent questions
- Use consistent wing names (match your project/repo name)
- Save decisions promptly — context fades between sessions
- Use room names that match your workflow: `decisions`, `bugs`, `config`, `architecture`
- Don't save trivial exchanges — focus on decisions and significant context
- Review proposed saves before approving — quality over quantity
