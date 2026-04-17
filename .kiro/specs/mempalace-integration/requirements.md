# MemPalace Integration — Requirements

## EARS-Format Requirements

### Ubiquitous Requirements

REQ-1: The integration SHALL register the MemPalace MCP server with Kiro using the standard `mcpServers` schema.

REQ-2: The integration SHALL never auto-approve write tools (`mempalace_add_drawer`, `mempalace_delete_drawer`, `mempalace_kg_add`, `mempalace_kg_invalidate`, `mempalace_diary_write`).

REQ-3: The integration SHALL auto-approve read-only tools (`mempalace_status`, `mempalace_list_wings`, `mempalace_list_rooms`, `mempalace_search`, `mempalace_get_taxonomy`, `mempalace_get_aaak_spec`, `mempalace_kg_query`, `mempalace_kg_timeline`, `mempalace_diary_read`).

REQ-4: The integration SHALL never install MemPalace with `sudo` or modify system packages.

REQ-5: The integration SHALL never hardcode absolute home directory paths — `$HOME` and `$PWD` must be used.

### Event-Driven Requirements

REQ-6: When a new Kiro agent session starts, the agent SHALL call `mempalace_status` and `mempalace_list_wings` to load palace context.

REQ-7: When the user asks a question referencing past work (e.g., "we decided", "last time", "our approach"), the agent SHALL call `mempalace_search` before answering, filtering by workspace wing when known.

REQ-8: When an architecture decision, bug fix, or configuration change is made, the agent SHALL propose a `mempalace_add_drawer` call with the verbatim exchange and wait for user approval.

REQ-9: When the user clicks the "Save to MemPalace" hook button, the agent SHALL summarize the session's decisions and call `mempalace_add_drawer` with wing derived from `basename $PWD`.

### State-Driven Requirements

REQ-10: While a workspace wing is known, the agent SHALL always use wing+room filtering for `mempalace_search` calls (never unfiltered).

REQ-11: While reading AAAK-encoded entries, the agent SHALL interpret them as-is and never ask the user to decode.

### Optional-Feature Requirements

REQ-12: Where the user selects global scope, the setup script SHALL write MCP config to `~/.kiro/settings/mcp.json` only after explicit user confirmation.

REQ-13: Where the user selects workspace scope, the setup script SHALL write MCP config to `.kiro/settings/mcp.json` directly.

REQ-14: Where an existing `mcp.json` contains other servers, the setup script SHALL merge the `mempalace` entry without overwriting existing servers.
