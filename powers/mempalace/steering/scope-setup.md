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

Use the provided script:

```bash
# Switch to global
./scripts/mempalace-scope.sh global

# Switch to workspace
./scripts/mempalace-scope.sh workspace
```

The script merges the `mempalace` entry into the target config and removes it from the source, preserving all other MCP servers.

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

## Important Notes

- Only have the `mempalace` entry in ONE scope at a time to avoid conflicts
- Workspace-level config takes precedence over global in Kiro's merge rules
- Write tools are never auto-approved regardless of scope
- The `MEMPALACE_PALACE_PATH` env var is optional — defaults to `~/.mempalace/palace/`
