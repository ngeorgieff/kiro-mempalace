# MemPalace Integration — Design

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│                  Kiro IDE                        │
│                                                  │
│  ┌──────────┐  ┌───────────┐  ┌──────────────┐  │
│  │ Steering │  │   Hooks   │  │  MCP Client   │  │
│  │  Rules   │  │  Engine   │  │  (built-in)   │  │
│  └────┬─────┘  └─────┬─────┘  └──────┬───────┘  │
│       │              │               │           │
└───────┼──────────────┼───────────────┼───────────┘
        │              │               │
        │ guides       │ triggers      │ JSON-RPC
        │ behavior     │ agent         │ over stdio
        ▼              ▼               ▼
  ┌──────────┐  ┌───────────┐  ┌──────────────┐
  │ Agent    │  │ "Save to  │  │  MemPalace   │
  │ Context  │  │ MemPalace"│  │  MCP Server  │
  │ (L0+L1)  │  │  button   │  │  (19 tools)  │
  └──────────┘  └───────────┘  └──────┬───────┘
                                      │
                                      ▼
                               ┌──────────────┐
                               │  ChromaDB +  │
                               │  SQLite      │
                               │(~/.mempalace)│
                               └──────────────┘
```

## Component Design

### 1. MCP Wiring

The MemPalace MCP server runs as a stdio subprocess managed by Kiro's built-in MCP client.

**Registration schema:**
```json
{
  "mcpServers": {
    "mempalace": {
      "command": "python",
      "args": ["-m", "mempalace.mcp_server"],
      "env": {
        "MEMPALACE_PALACE_PATH": "~/.mempalace/palace"
      },
      "disabled": false,
      "autoApprove": [
        "mempalace_status",
        "mempalace_list_wings",
        "mempalace_list_rooms",
        "mempalace_search",
        "mempalace_get_taxonomy",
        "mempalace_get_aaak_spec",
        "mempalace_kg_query",
        "mempalace_kg_timeline",
        "mempalace_diary_read"
      ]
    }
  }
}
```

**Tool classification:**
- Read-only (auto-approved): status, list_wings, list_rooms, search, get_taxonomy, get_aaak_spec, kg_query, kg_timeline, diary_read
- Write (require approval): add_drawer, delete_drawer, kg_add, kg_invalidate, diary_write

### 2. Scope Model

Two mutually exclusive scopes for MCP registration:

| Scope | Config Path | Visibility |
|-------|------------|------------|
| Global | `~/.kiro/settings/mcp.json` | All Kiro workspaces |
| Workspace | `.kiro/settings/mcp.json` | Current project only |

**Toggle mechanism:** `scripts/mempalace-scope.sh [global|workspace]`
- Reads current config from source scope
- Merges `mempalace` entry into target scope
- Removes `mempalace` entry from source scope
- Preserves all other `mcpServers` entries in both files

### 3. Steering Rules

Two steering files guide agent behavior:

**`mempalace-usage.md`** (inclusion: always)
- Session start: load L0+L1 context via status + list_wings
- Memory-dependent questions: search before answering
- Decision capture: propose add_drawer after significant events
- Wing+room filtering: always filter when wing is known
- AAAK respect: read compressed entries as-is

**`mempalace-scope.md`** (inclusion: fileMatch on `.kiro/settings/mcp.json`)
- Explains global vs workspace scope
- Documents how to toggle between scopes
- Loaded only when editing MCP config

### 4. Hook Flow

```
User clicks "Save to MemPalace"
        │
        ▼
Hook triggers askAgent
        │
        ▼
Agent summarizes session decisions
        │
        ▼
Agent calls mempalace_add_drawer
  wing = basename($PWD)
  room = "decisions" or contextual
        │
        ▼
User approves (write tool, not auto-approved)
        │
        ▼
Drawer saved to palace
```

### 5. Setup Script Flow

```
setup-mempalace.sh
        │
        ├─ Detect: mempalace --version
        │   ├─ Found → skip install
        │   └─ Not found → pip install --user mempalace
        │
        ├─ Init: mempalace init (idempotent)
        │
        ├─ Scope prompt: G or W?
        │   ├─ G → merge into ~/.kiro/settings/mcp.json (with confirmation)
        │   └─ W → merge into .kiro/settings/mcp.json
        │
        └─ Verify: python -m mempalace.mcp_server --help
```
