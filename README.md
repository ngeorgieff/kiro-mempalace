# kiro-mempalace


Persistent AI memory for [Kiro IDE and CLI](https://kiro.dev), powered by [MemPalace](https://github.com/MemPalace/mempalace).

Installs globally — works in every project without per-project setup.

---

## What it does

- Kiro remembers context, decisions, and knowledge across sessions
- Automatically loads relevant memory at session start
- Automatically saves session summaries when the agent stops
- Semantic search across all past sessions
- Single shared memory palace across all your projects

---

## Install

### Mac / Linux

```bash
git clone https://github.com/yourusername/kiro-mempalace
cd kiro-mempalace
chmod +x install.sh
./install.sh
```

Then **restart Kiro**.

### Windows (PowerShell)

```powershell
git clone https://github.com/yourusername/kiro-mempalace
cd kiro-mempalace
powershell -ExecutionPolicy Bypass -File install.ps1
```

Then **restart Kiro**.

---

## What the installer does

1. Installs [`uv`](https://docs.astral.sh/uv/) if not present (fast Python package manager)
2. Installs `mempalace` via `uv tool install mempalace`
3. Initializes your memory palace at `~/.mempalace`
4. Copies the Kiro Power to `~/.kiro/powers/mempalace/`
5. Registers the MCP server in `~/.kiro/settings/mcp.json` (global — no per-project setup)

---

## Requirements

- [Kiro IDE or CLI](https://kiro.dev)
- Python 3.9+ (3.11+ recommended)
- Internet connection (for install only)

---

## How memory works

### Session start
When you continue past work, Kiro calls `mempalace_wake_up` and silently loads your memory context.

### During sessions
Kiro searches memory when past context would help, and writes to memory when it discovers something worth keeping.

### Session end
When the agent stops, Kiro writes a diary entry summarizing what was accomplished.

---

## Manual setup (alternative to installer)

If you prefer to configure manually:

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
      "command": "python3",
      "args": ["-m", "mempalace.mcp_server"],
      "env": {
        "MEMPALACE_HOME": "/Users/yourname/.mempalace"
      }
    }
  }
}
```

> Windows: use `"python"` instead of `"python3"`, and use a full path like `C:\Users\yourname\.mempalace`

**3. Copy the Power**
```bash
mkdir -p ~/.kiro/powers/mempalace/steering
cp POWER.md ~/.kiro/powers/mempalace/
cp hooks.json ~/.kiro/powers/mempalace/
cp steering/* ~/.kiro/powers/mempalace/steering/
```

---

## Per-project memory isolation (optional)

By default, all projects share one memory palace at `~/.mempalace`. To isolate memory per project, add a workspace-level override in your project's `.kiro/settings/mcp.json`:

```json
{
  "mcpServers": {
    "mempalace": {
      "command": "python3",
      "args": ["-m", "mempalace.mcp_server"],
      "env": {
        "MEMPALACE_HOME": "/path/to/project/.mempalace"
      }
    }
  }
}
```

---

## Uninstall

```bash
rm -rf ~/.kiro/powers/mempalace
```

Then remove the `mempalace` entry from `~/.kiro/settings/mcp.json`.

To also remove your memory data:
```bash
rm -rf ~/.mempalace
```

---

## Contributing

PRs welcome. The project has no runtime dependencies beyond `mempalace` itself.

```
POWER.md          — Kiro Power definition and steering instructions
mcp.json          — MCP server configuration template
steering/         — Per-trigger workflow guidance for the AI
hooks.json        — Kiro hook definitions (auto-save, wake-up)
install.sh        — Mac/Linux installer
install.ps1       — Windows installer
```

---

## License

MIT
