# Changelog

## [Unreleased] — 2026-04-17

### Added

#### MemPalace Kiro Power (`powers/mempalace/`)
- `POWER.md` — Full power documentation: onboarding, tool reference, AAAK format guide, troubleshooting, and best practices
- `mcp.json` — MCP server registration with read-only tools auto-approved, write tools requiring user confirmation
- `steering/session-workflow.md` — Session start/mid/end workflow guide for agent memory usage
- `steering/scope-setup.md` — Global vs workspace scope configuration guide

#### Integration Spec (`.kiro/specs/mempalace-integration/`)
- `requirements.md` — EARS-format requirements covering MCP wiring, steering behavior, scope model, and hook triggers
- `design.md` — Architecture document: MCP wiring diagram, scope model, hook flow, setup script flow
- `tasks.md` — Ordered task checklist for deploying the integration to other workspaces

#### Steering Rules (`.kiro/steering/`)
- `mempalace-usage.md` — Always-on steering: session-start context loading, memory-dependent search, decision capture, AAAK awareness, wing+room filtering
- `mempalace-scope.md` — FileMatch steering on `mcp.json`: documents global vs workspace scope model and toggle mechanism

#### Agent Hook (`.kiro/hooks/`)
- `mempalace-autosave.kiro.hook` — Manual "Save to MemPalace" button that triggers agent to summarize session decisions and call `mempalace_add_drawer`
