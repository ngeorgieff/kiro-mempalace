# Changelog

All notable changes to this project will be documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/). Versioning follows [Conventional Commits](https://www.conventionalcommits.org/) via GitHub Actions.

## [Unreleased]

### Security
- Removed write tools from `autoApprove` (security fix): `mempalace_add_drawer`, `mempalace_update_drawer`, `mempalace_delete_drawer`, `mempalace_kg_add`, `mempalace_kg_invalidate`, `mempalace_create_tunnel`, `mempalace_delete_tunnel`, `mempalace_diary_write` now always require user approval.
- Added CI check in `validate-pr.yml` that fails the build if any write tool appears in the `mempalace` `autoApprove` list.

### Changed
- Aligned MCP config with official MemPalace docs: 29 total tools documented, 21 read/safe tools auto-approved, 8 write tools require user approval.
- Updated `install.sh` to register the full MCP entry (`disabled: false`, `env: {}`, full `autoApprove` array of 21 tools) instead of a minimal `command`/`args` stub.
- Rewrote `install.ps1` to copy power files from the correct source paths (`powers/mempalace/POWER.md`, `powers/mempalace/mcp.json`, `powers/mempalace/steering/*.md`) and to register the full MCP entry including `autoApprove`.
- Fixed backup file lists in both installers to reference the actual steering files (`scope-setup.md`, `session-workflow.md`, `mine-workflow.md`).
- README "Manual setup" MCP snippet and "MCP Tools" section now reflect the 29-tool / 21-auto-approved split.
- README "Claude Plugin Parity" table updated: `MCP server (29 tools, 21 auto-approved)`.
- Steering files (`.kiro/steering/mempalace-scope.md`, `powers/mempalace/steering/scope-setup.md`) now use the canonical `uvx --from mempalace python -m mempalace.mcp_server` command and the full 21-tool `autoApprove` list.

### Added
- Memory Protocol section in both `POWER.md` files and `.kiro/steering/mempalace-usage.md`, documenting that `mempalace_status` returns a behavior guide the AI internalizes (search before claiming memory, say "let me check" when unsure, write diary entries, invalidate facts when they change).
- Documented `--palace <path>` CLI flag as an alternative to the `MEMPALACE_PALACE_PATH` env var.
- Framing in `mempalace-autosave.kiro.hook` noting that this single `agentStop` hook is Kiro's equivalent of both the official Save Hook (Stop event) and PreCompact Hook.
- `mempalace-init.kiro.hook` now recommends `uv tool install mempalace` (matching the install scripts and the upstream Claude plugin), mentions the `mempalace-mcp` binary, and keeps `pip install --user mempalace` as a fallback.

### Removed
- References to the non-existent `scripts/mempalace-scope.sh` in `.kiro/steering/mempalace-scope.md` and `powers/mempalace/steering/scope-setup.md`. Replaced with manual instructions for moving the `mempalace` entry between global and workspace `mcp.json` files.

## [v0.0.3] — 2026-04-20

### Added
- `mempalace-autosave` hook changed from `userTriggered` to `agentStop` — auto-saves session context when agent stops (mirrors Claude plugin's Stop hook)
- `mempalace-init` hook (`userTriggered`) — install package, create palace, verify MCP server (mirrors `/mempalace:init`)
- `mempalace-mine` hook (`userTriggered`) — index projects/conversations into palace with dynamic CLI instructions (mirrors `/mempalace:mine`)
- `mempalace-status` hook (`userTriggered`) — palace overview with wing/room counts (mirrors `/mempalace:status`)
- `mempalace-help` hook (`userTriggered`) — full architecture and tool reference (mirrors `/mempalace:help`)
- `mine-workflow.md` steering file — guide for mining projects and conversations
- Root `POWER.md` — required by Kiro's cached install path resolution at `~/.kiro/powers/installed/<name>/`

### Changed
- `POWER.md` rewritten with full 25+ tool reference, all hooks (automatic + user-triggered), dynamic instructions pattern, and mine workflow
- `mempalace-usage.md` steering updated with session-end auto-save section, mining section, and dynamic instructions via `mempalace instructions <cmd>`
- `mempalace-search` hook updated to use dynamic CLI instructions at runtime
- `mempalace-auto-context` hook cleaned up with improved description

### Fixed
- POWER.md not found by `kiroPowers activate` — root cause: Kiro caches power files at install time into `~/.kiro/powers/installed/<name>/`, original install only had POWER.md nested under `powers/mempalace/`
- MCP server entry in user config missing `disabled: false` and `autoApprove` list

### Removed
- Stale root-level files: `hooks.json`, `entities.json`, `mempalace.yaml`, `steering/`, old `CHANGELOG.md`
- `update-readme` agent hook (replaced by comprehensive hook set)

## [v0.0.2] — 2026-04-17

### Added
- GitHub Actions CI/CD: `release.yml` (auto-tag + release on push to main) and `validate-pr.yml` (structure/JSON/frontmatter validation)
- `.gitignore` for ChromaDB artifacts, OS files, `.claude/`, local Kiro settings
- `mempalace-autosave` Kiro hook — manual "Save to MemPalace" button

### Fixed
- Replaced all `${PALACE_PATH}` references with `~/.mempalace` across configs, docs, and steering
- Auto-approved all 29 mempalace MCP tools in power config
- Removed `.claude/worktrees/loving-elion` git worktree causing CI and IDE errors
- Pinned `actions/checkout@v4.2.2` with `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24` to avoid Node.js 20 deprecation and Post Run cleanup bugs
- Updated `POWER.md` default palace path from `~/.palace/` to `~/.mempalace/`
- Fixed `install.sh` to include `MEMPALACE_PALACE_PATH` env var in global MCP config

## [v0.0.1] — 2026-04-16

### Added
- Kiro Power: `powers/mempalace/` with `POWER.md`, `mcp.json`, and steering files (`scope-setup.md`, `session-workflow.md`)
- Integration spec: `.kiro/specs/mempalace-integration/` (requirements, design, tasks)
- Workspace steering: `mempalace-usage.md` (always-on) and `mempalace-scope.md` (fileMatch on mcp.json)
- Config backup support in `install.sh` and `install.ps1`
- `uninstall.sh` and `uninstall.ps1` scripts

### Changed
- Switched MCP server command from `python3` to `uvx` for portability
- Removed `MEMPALACE_HOME` env var, replaced with `MEMPALACE_PALACE_PATH`
- Removed sed-based mcp.json patching from installers

## [v0.0.0] — 2026-04-15

### Added
- Initial project: `install.sh`, `install.ps1`, root `POWER.md`, `mcp.json`, `hooks.json`, `steering/`
