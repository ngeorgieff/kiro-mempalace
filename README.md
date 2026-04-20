# kiro-mempalace

Persistent AI memory for [Kiro IDE and CLI](https://kiro.dev), powered by [MemPalace](https://github.com/MemPalace/mempalace).

Gives Kiro agents memory that persists across sessions — decisions, context, and knowledge stored locally via semantic search and a knowledge graph. Full feature parity with the [MemPalace Claude Code plugin](https://github.com/MemPalace/mempalace/tree/develop/.claude-plugin).

---

## What it does

- Remembers context, decisions, and knowledge across sessions
- Auto-loads relevant memory at session start via `promptSubmit` hook
- Auto-saves significant decisions when sessions end via `agentStop` hook
- Semantic search across all past sessions with wing/room filtering
- Knowledge graph for entity relationships and timelines
- Agent diary in compressed AAAK format
- Project mining — index entire codebases into the palace
- Dynamic CLI instructions — hooks call `mempalace instructions <cmd>` at runtime for fresh guidance
- Single shared memory palace at `~/.mempalace` (all projects)

---

## Claude Plugin Parity

This power mirrors the [MemPalace Claude Code plugin](https://github.com/MemPalace/mempalace/tree/develop/.claude-plugin) feature set:

| Claude Plugin | Kiro Power Equivalent |
|--------------|----------------------|
| Stop hook (auto-save every 15 msgs) | `agentStop` hook — auto-saves on session end |
| PreCompact hook | No Kiro equivalent — `agentStop` covers the intent |
| `/mempalace:init` | MemPalace Init hook (userTriggered) |
| `/mempalace:mine` | MemPalace Mine hook (userTriggered) |
| `/mempalace:search` | MemPalace Search hook (userTriggered) |
| `/mempalace:status` | MemPalace Status hook (userTriggered) |
| `/mempalace:help` | MemPalace Help hook (userTriggered) |
| SKILL.md (dynamic CLI delegation) | Hooks use `mempalace instructions <cmd>` |
| MCP server (19+ tools) | Same MCP server, 28 tools auto-approved |

---

## Install

### Option 1: Kiro Power (recommended)

1. Open Kiro → Powers panel → **Add power from GitHub**
2. Enter: `https://github.com/ngeorgieff/kiro-mempalace`
3. Select the `powers/mempalace` directory
4. Install and restart Kiro

### Option 2: Install script (Mac / Linux)

```bash
git clone https://github.com/ngeorgieff/kiro-mempalace
cd kiro-mempalace
chmod +x install.sh
./install.sh
```

### Option 3: Install script (Windows PowerShell)

```powershell
git clone https://github.com/ngeorgieff/kiro-mempalace
cd kiro-mempalace
powershell -ExecutionPolicy Bypass -File install.ps1
```

Then **restart Kiro**.

---

## What the installer does

1. Installs [`uv`](https://docs.astral.sh/uv/) if not present
2. Installs `mempalace` via `uv tool install mempalace`
3. Initializes the memory palace at `~/.mempalace`
4. Copies the Kiro Power to `~/.kiro/powers/mempalace/`
5. Registers the MCP server in `~/.kiro/settings/mcp.json`

---

## Requirements

- [Kiro IDE or CLI](https://kiro.dev)
- Python 3.9+ (3.11+ recommended)
- Internet connection (for install only)

---

## Hooks

### Automatic (fire without user action)

| Hook | Event | What It Does |
|------|-------|-------------|
| MemPalace Auto Context | `promptSubmit` | Loads palace context on first message; searches memory for relevant past context on every subsequent message |
| MemPalace Auto-Save | `agentStop` | Saves significant decisions and writes an AAAK diary entry when the session ends |

### User-Triggered (click to activate)

| Hook | What It Does |
|------|-------------|
| MemPalace Init | Install package, create palace, verify MCP server |
| MemPalace Mine | Index projects/conversations into the palace via CLI |
| MemPalace Search | Semantic search across memories with wing/room filters |
| MemPalace Status | Palace overview — wings, rooms, drawer counts |
| MemPalace Help | Show tools, hooks, architecture overview |
| Save to MemPalace | Manually save session context (decisions, changes) |

---

## How memory works

### Session start
The `promptSubmit` hook fires automatically. The agent calls `mempalace_status` and `mempalace_list_wings` to load palace context — which projects have memory, how many drawers, etc.

### During sessions
On every message, the agent extracts keywords and calls `mempalace_search` with wing/room filters to surface relevant past context. When you reference past work ("we decided", "last time"), it verifies against stored memories before answering. After significant decisions, it proposes saving via `mempalace_add_drawer`.

### Session end
The `agentStop` hook fires automatically. The agent reviews the conversation for significant decisions, saves key context via `mempalace_add_drawer`, and writes a diary entry in AAAK format via `mempalace_diary_write`. Trivial sessions are skipped.

### Mining projects
Use the "MemPalace Mine" hook to index an entire project directory into the palace. Files are auto-classified into wings (project name) and rooms (topic areas). The hook calls `mempalace instructions mine` for up-to-date CLI guidance.

---

## Steering Files

| File | Purpose |
|------|---------|
| `session-workflow.md` | Step-by-step guide for session start, mid-session queries, and session-end saving |
| `scope-setup.md` | Configure MemPalace globally vs per-workspace, toggle between scopes |
| `mine-workflow.md` | How to mine projects and conversations into the palace |
| `mempalace-usage.md` | Always-on steering with search best practices, AAAK awareness, tool reference |

---

## MCP Tools (28 auto-approved)

### Palace Operations
`mempalace_status` · `mempalace_list_wings` · `mempalace_list_rooms` · `mempalace_get_taxonomy`

### Search & Storage
`mempalace_search` · `mempalace_add_drawer` · `mempalace_get_drawer` · `mempalace_list_drawers` · `mempalace_update_drawer` · `mempalace_delete_drawer` · `mempalace_check_duplicate`

### Knowledge Graph
`mempalace_kg_query` · `mempalace_kg_add` · `mempalace_kg_invalidate` · `mempalace_kg_timeline` · `mempalace_kg_stats`

### Tunnels (cross-wing connections)
`mempalace_traverse` · `mempalace_find_tunnels` · `mempalace_graph_stats` · `mempalace_create_tunnel` · `mempalace_list_tunnels` · `mempalace_delete_tunnel` · `mempalace_follow_tunnels`

### Diary & Utilities
`mempalace_diary_write` · `mempalace_diary_read` · `mempalace_get_aaak_spec` · `mempalace_hook_settings` · `mempalace_memories_filed_away` · `mempalace_reconnect`

---

## Manual setup (alternative to installer)

**1. Install mempalace**
```bash
pip install mempalace
mempalace init ~/.mempalace
```

**2. Add to global Kiro MCP config** (`~/.kiro/settings/mcp.json`)
```json
{
  "mcpServers": {
    "mempalace": {
      "command": "uvx",
      "args": ["--from", "mempalace", "python", "-m", "mempalace.mcp_server"],
      "disabled": false,
      "autoApprove": [
        "mempalace_status", "mempalace_list_wings", "mempalace_list_rooms",
        "mempalace_search", "mempalace_add_drawer", "mempalace_get_drawer",
        "mempalace_kg_query", "mempalace_kg_add", "mempalace_kg_timeline",
        "mempalace_diary_write", "mempalace_diary_read"
      ]
    }
  }
}
```

**3. Copy the Power**
```bash
mkdir -p ~/.kiro/powers/mempalace/steering
cp powers/mempalace/POWER.md ~/.kiro/powers/mempalace/
cp powers/mempalace/mcp.json ~/.kiro/powers/mempalace/
cp powers/mempalace/steering/* ~/.kiro/powers/mempalace/steering/
```

---

## Per-project memory isolation (optional)

By default, all projects share one memory palace at `~/.mempalace`. To isolate memory per project, add a workspace-level override in `.kiro/settings/mcp.json`:

```json
{
  "mcpServers": {
    "mempalace": {
      "command": "uvx",
      "args": ["--from", "mempalace", "python", "-m", "mempalace.mcp_server"],
      "env": {
        "MEMPALACE_PALACE_PATH": "/path/to/project/.mempalace/palace"
      }
    }
  }
}
```

---

## Uninstall

### Kiro Power
Remove from the Powers panel in Kiro.

### Manual install
```bash
rm -rf ~/.kiro/powers/mempalace
```
Then remove the `mempalace` entry from `~/.kiro/settings/mcp.json`.

### Remove memory data
```bash
rm -rf ~/.mempalace
```

---

## Project structure

```
POWER.md                          — Root power manifest (required by Kiro install cache)
powers/mempalace/                 — Kiro Power source
  POWER.md                        — Power documentation and metadata
  mcp.json                        — MCP server config with autoApprove list
  steering/
    session-workflow.md            — Session lifecycle guide
    scope-setup.md                — Global vs workspace scope config
    mine-workflow.md               — Project mining guide
.kiro/
  hooks/
    mempalace-auto-context.kiro.hook  — promptSubmit: auto-load + search
    mempalace-autosave.kiro.hook      — agentStop: auto-save decisions
    mempalace-init.kiro.hook          — userTriggered: install + setup
    mempalace-mine.kiro.hook          — userTriggered: mine projects
    mempalace-search.kiro.hook        — userTriggered: semantic search
    mempalace-status.kiro.hook        — userTriggered: palace overview
    mempalace-help.kiro.hook          — userTriggered: help + architecture
  steering/
    mempalace-usage.md             — Always-on agent steering rules
    mempalace-scope.md             — Scope-aware steering (fileMatch)
mcp.json                          — Root MCP server config template
install.sh / install.ps1          — Installers
uninstall.sh / uninstall.ps1      — Uninstallers
.github/workflows/                — CI/CD (release + PR validation)
```

---

## CI/CD

GitHub Actions workflows included:

- **release.yml** — Auto-tags and creates GitHub Releases on push to `main` using conventional commits (`fix:` → patch, `feat:` → minor)
- **validate-pr.yml** — Validates power structure, JSON syntax, POWER.md frontmatter, and checks for broken config references on PRs

---

## Contributing

PRs welcome. Use conventional commits (`feat:`, `fix:`, `docs:`) for automatic versioning.

---

## License

MIT
