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

Toggling scope is a manual edit: there is no script for this in the repo.

1. Open the **source** `mcp.json` (where the `mempalace` entry currently lives).
2. Copy the entire `"mempalace": { ... }` block from `mcpServers`.
3. Open the **target** `mcp.json` (the scope you want to move to, creating the file with `{ "mcpServers": {} }` if needed).
4. Paste the `mempalace` block into the target's `mcpServers`, preserving all other server entries.
5. Delete the `mempalace` block from the source `mcp.json`.
6. Restart Kiro.

The two scope files are:
- Global: `~/.kiro/settings/mcp.json`
- Workspace: `.kiro/settings/mcp.json`

Keep the `mempalace` entry in only one of them at a time.

## MCP Registration Schema

The `mempalace` server entry uses this format:

```json
{
  "mempalace": {
    "command": "uvx",
    "args": ["--from", "mempalace", "python", "-m", "mempalace.mcp_server"],
    "env": {},
    "disabled": false,
    "autoApprove": [
      "mempalace_status",
      "mempalace_list_wings",
      "mempalace_list_rooms",
      "mempalace_get_taxonomy",
      "mempalace_search",
      "mempalace_check_duplicate",
      "mempalace_get_aaak_spec",
      "mempalace_get_drawer",
      "mempalace_list_drawers",
      "mempalace_kg_query",
      "mempalace_kg_timeline",
      "mempalace_kg_stats",
      "mempalace_traverse",
      "mempalace_find_tunnels",
      "mempalace_graph_stats",
      "mempalace_list_tunnels",
      "mempalace_follow_tunnels",
      "mempalace_diary_read",
      "mempalace_hook_settings",
      "mempalace_memories_filed_away",
      "mempalace_reconnect"
    ]
  }
}
```

## Important Rules

- **Read/safe tools** (21 total) are auto-approved for frictionless context loading.
- **Write tools** (`mempalace_add_drawer`, `mempalace_update_drawer`, `mempalace_delete_drawer`, `mempalace_kg_add`, `mempalace_kg_invalidate`, `mempalace_create_tunnel`, `mempalace_delete_tunnel`, `mempalace_diary_write`) always require user approval.
- **Never auto-approve `mempalace_delete_drawer`**: data deletion must be intentional.
- When editing this file, **merge** the mempalace entry: do not overwrite other servers.
- Use `$HOME` for global paths, never hardcoded absolute paths.
- `MEMPALACE_PALACE_PATH` can be set in `env`, or you can pass `--palace <path>` as an additional arg.
