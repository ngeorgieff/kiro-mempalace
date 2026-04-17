---
inclusion: fileMatch
fileMatchPattern: ".kiro/settings/mcp.json"
---

# MemPalace Scope Model

This steering file is loaded when editing `.kiro/settings/mcp.json` to provide context about the MemPalace MCP scope model.

## Scope Overview

MemPalace MCP registration can live in one of two locations:

| Scope | Config Path | Effect |
|-------|------------|--------|
| **Global** | `~/.kiro/settings/mcp.json` | MemPalace available in every Kiro workspace on this machine |
| **Workspace** | `.kiro/settings/mcp.json` | MemPalace available only in this project |

Only one scope should be active at a time. Having the `mempalace` entry in both files will cause a conflict (workspace takes precedence per Kiro's merge rules).

## Toggling Scope

Use the provided script to switch between scopes:

```bash
# Switch to global (all workspaces)
./scripts/mempalace-scope.sh global

# Switch to workspace (this project only)
./scripts/mempalace-scope.sh workspace
```

The script will:
1. Read the `mempalace` entry from the current scope
2. Merge it into the target scope's `mcp.json`
3. Remove it from the source scope's `mcp.json`
4. Preserve all other `mcpServers` entries in both files

## MCP Registration Schema

The `mempalace` server entry uses this format:

```json
{
  "mempalace": {
    "command": "python",
    "args": ["-m", "mempalace.mcp_server"],
    "env": {
      "MEMPALACE_PALACE_PATH": "${PALACE_PATH}"
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
```

## Important Rules

- **Read-only tools** are auto-approved for frictionless context loading.
- **Write tools** (`add_drawer`, `delete_drawer`, `kg_add`, `kg_invalidate`, `diary_write`) always require user approval.
- **Never auto-approve `mempalace_delete_drawer`** — data deletion must be intentional.
- When editing this file, **merge** the mempalace entry — do not overwrite other servers.
- Use `$HOME` for global paths, never hardcoded absolute paths.
