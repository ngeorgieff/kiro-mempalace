# Changelog

All notable changes to this project will be documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/). Versioning follows [Conventional Commits](https://www.conventionalcommits.org/) via GitHub Actions.

## [Unreleased]

### Changed
- Removed stale root-level files: `POWER.md`, `hooks.json`, `entities.json`, `mempalace.yaml`, `steering/`, `CHANGELOG.md`
- Updated `install.sh` to copy from `powers/mempalace/` instead of deleted root files
- Rewrote `README.md` to match current project state
- Renamed power MCP server key from `mempalace` to `server` (avoids `power-mempalace-mempalace` naming)

### Added
- `update-readme` agent hook — auto-checks README freshness on agent stop

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
