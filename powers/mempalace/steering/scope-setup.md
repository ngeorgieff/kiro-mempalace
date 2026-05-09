# Scope Setup

How to configure MemPalace MCP registration scope — global vs workspace.

## Scope Options

| Scope | Config Path | When to Use |
|-------|------------|-------------|
| **Global** | `~/.kiro/settings/mcp.json` | You want MemPalace in every Kiro workspace |
| **Workspace** | `.kiro/settings/mcp.json` | You want MemPalace only in this project |

## Choosing a Scope

**Global (recommended for most users):**
- Memory persists and is accessible from any workspace
- One configuration to maintain
- Agent always has access to the full palace

**Workspace:**
- Useful if you only want memory for specific projects
- Keeps the MCP server list clean in other workspaces
- Each workspace can have its own palace path via `MEMPALACE_PALACE_PATH`

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

## Manual Configuration

If you prefer to configure manually, add this to the appropriate `mcp.json`:

```json
{
  "mcpServers": {
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
}
```

## Important Notes

- Only have the `mempalace` entry in ONE scope at a time to avoid conflicts
- Workspace-level config takes precedence over global in Kiro's merge rules
- Write tools are never auto-approved regardless of scope
- The `MEMPALACE_PALACE_PATH` env var is optional — defaults to `~/.mempalace/palace/`
