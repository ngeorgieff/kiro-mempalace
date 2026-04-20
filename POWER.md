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

This power integrates MemPalace's 19+ MCP tools into Kiro with proper steering, automatic hooks, and user-triggered commands — the agent knows when to search memory, when to save context, and how to read the compressed AAAK diary format without bothering you.

## Available Steering Files

- **session-workflow** — Step-by-step guide for session start, mid-session memory queries, and session-end saving
- **scope-setup** — How to configure MemPalace globally vs per-workspace, and toggle between scopes
- **mine-workflow** — How to mine projects and conversations into the palace for persistent memory

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

This creates the palace database at `~/.mempalace/palace/` (default). You can override with `MEMPALACE_PALACE_PATH` env var.

### Configuration

The MCP server is configured automatically when this power is installed. The `MEMPALACE_PALACE_PATH` environment variable controls where the palace database lives. If unset, it defaults to `~/.mempalace/palace/`.

To use a custom path, edit the `env` section in the MCP config:
```json
"env": {
  "MEMPALACE_PALACE_PATH": "/path/to/your/palace"
}
```

## Hooks

### Automatic Hooks (fire without user action)

| Hook | Event | What It Does |
|------|-------|-------------|
| MemPalace Auto Context | `promptSubmit` | Loads palace context on first message; searches memory for relevant past context on every subsequent message |
| MemPalace Auto-Save | `agentStop` | Saves significant decisions and writes a diary entry when the session ends |

### User-Triggered Hooks (click to activate)

| Hook | Equivalent Claude Command | What It Does |
|------|--------------------------|-------------|
| MemPalace Init | `/mempalace:init` | Install package, create palace, verify MCP server |
| MemPalace Mine | `/mempalace:mine` | Index projects/conversations into the palace |
| MemPalace Search | `/mempalace:search` | Semantic search across memories with filters |
| MemPalace Status | `/mempalace:status` | Palace overview — wings, rooms, drawer counts |
| MemPalace Help | `/mempalace:help` | Show tools, hooks, architecture overview |
| Save to MemPalace | — | Manually save session context (decisions, changes) |

## Common Workflows

### Session Start — Load Context

At the beginning of every session, the agent loads palace context automatically via the `promptSubmit` hook:

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

### Auto-Save on Session End

When the session ends (agent stops), the `agentStop` hook automatically:
1. Reviews the conversation for significant decisions
2. Saves key context via `mempalace_add_drawer`
3. Writes a diary entry in AAAK format via `mempalace_diary_write`

If nothing significant happened, it skips saving entirely.

### Mine a Project

Use the "MemPalace Mine" hook button or ask the agent to mine your project:

```bash
mempalace mine /path/to/project
```

This indexes files with auto-classification into wings and rooms. See the `mine-workflow` steering file for details.

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
mempalace_diary_write(agent_name="kiro", entry="SESSION:2026-04-20|built.mempalace.power|scope:global|★★★")
```

Read past diary entries:
```
mempalace_diary_read(agent_name="kiro", last_n=5)
```

## Dynamic Instructions

MemPalace provides up-to-date instructions via the CLI for any operation:

```bash
mempalace instructions <command>
```

Where `<command>` is one of: `help`, `init`, `mine`, `search`, `status`.

The hooks use this mechanism to get the latest instructions at runtime, ensuring the power never goes stale relative to the CLI.

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
| `mempalace_get_drawer` | Retrieve a specific drawer by ID |
| `mempalace_list_drawers` | List drawers in a room |
| `mempalace_update_drawer` | Update existing drawer content |
| `mempalace_check_duplicate` | Check if content already exists |
| `mempalace_hook_settings` | View/configure hook settings |
| `mempalace_traverse` | Traverse palace structure |
| `mempalace_find_tunnels` | Find connections between drawers |
| `mempalace_graph_stats` | Knowledge graph statistics |
| `mempalace_create_tunnel` | Create connections between drawers |
| `mempalace_list_tunnels` | List existing tunnels |
| `mempalace_delete_tunnel` | Remove a tunnel |
| `mempalace_follow_tunnels` | Navigate through tunnels |

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
- Use `mempalace mine` at project milestones to keep the palace current
