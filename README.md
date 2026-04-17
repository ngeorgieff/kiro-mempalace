# kiro-mempalace

Persistent AI memory for [Kiro IDE and CLI](https://kiro.dev), powered by [MemPalace](https://github.com/MemPalace/mempalace).

Gives Kiro agents memory that persists across sessions — decisions, context, and knowledge stored locally via semantic search and a knowledge graph.

---

## What it does

- Remembers context, decisions, and knowledge across sessions
- Loads relevant memory at session start via `mempalace_status` + `mempalace_list_wings`
- Semantic search across all past sessions
- Knowledge graph for entity relationships
- Agent diary in compressed AAAK format
- Single shared memory palace at `~/.mempalace` (all projects)

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

## How memory works

### Session start
The agent calls `mempalace_status` and `mempalace_list_wings` to load palace context (total drawers, wings, rooms).

### During sessions
When you reference past work ("we decided", "last time"), the agent calls `mempalace_search` before answering. After significant decisions, it proposes saving via `mempalace_add_drawer`.

### Session end
The agent writes a diary entry via `mempalace_diary_write` summarizing what was accomplished.

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
      "env": {
        "MEMPALACE_PALACE_PATH": "~/.mempalace"
      }
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
        "MEMPALACE_PALACE_PATH": "/path/to/project/.mempalace"
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

## CI/CD

The repo includes GitHub Actions workflows:

- **release.yml** — Auto-tags and creates GitHub Releases on push to `main` using conventional commits (`fix:` → patch, `feat:` → minor)
- **validate-pr.yml** — Validates power structure, JSON syntax, POWER.md frontmatter, and checks for broken config references on PRs

---

## Project structure

```
powers/mempalace/         — Kiro Power (POWER.md, mcp.json, steering/)
mcp.json                  — Root MCP server config template
install.sh                — Mac/Linux installer
install.ps1               — Windows installer
uninstall.sh              — Mac/Linux uninstaller
uninstall.ps1             — Windows uninstaller
steering/                 — Legacy steering files (session start/end)
hooks.json                — Legacy hook definitions
.github/workflows/        — CI/CD (release + PR validation)
.gitignore                — Excludes ChromaDB artifacts, OS files, local settings
```

---

## Contributing

PRs welcome. Use conventional commits (`feat:`, `fix:`, `docs:`) for automatic versioning.

---

## License

MIT
