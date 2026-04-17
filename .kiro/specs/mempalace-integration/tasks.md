# MemPalace Integration — Tasks

## Ordered Task Checklist

### Phase 1: Discovery
- [x] Task 1: Detect MemPalace installation (`mempalace --version`)
- [x] Task 2: Check Python version (≥ 3.9)
- [x] Task 3: Inspect existing `.kiro/` folder structure
- [x] Task 4: Check for existing `~/.kiro/settings/mcp.json` (presence only)

### Phase 2: Scope Decision
- [x] Task 5: Prompt user for scope choice (G = global, W = workspace)
- [x] Task 6: Record scope decision: **Global**

### Phase 3: Spec + Steering + Hook Files
- [x] Task 7: Create `.kiro/specs/mempalace-integration/requirements.md`
- [x] Task 8: Create `.kiro/specs/mempalace-integration/design.md`
- [x] Task 9: Create `.kiro/specs/mempalace-integration/tasks.md` (this file)
- [ ] Task 10: Create `.kiro/steering/mempalace-usage.md` (inclusion: always)
- [ ] Task 11: Create `.kiro/steering/mempalace-scope.md` (inclusion: fileMatch)
- [ ] Task 12: Create `.kiro/hooks/mempalace-autosave.kiro.hook`

### Phase 4: MCP Registration
- [ ] Task 13: Prepare MCP JSON for global scope
- [ ] Task 14: Show user exact path + JSON, get confirmation before writing to `~`
- [ ] Task 15: Merge `mempalace` entry into `~/.kiro/settings/mcp.json`

### Phase 5: Setup Scripts
- [ ] Task 16: Create `scripts/setup-mempalace.sh` (idempotent installer)
- [ ] Task 17: Create `scripts/mempalace-scope.sh` (scope toggle)
- [ ] Task 18: `chmod +x` both scripts
- [ ] Task 19: Run `scripts/setup-mempalace.sh --dry-run` and verify exit 0

### Phase 6: Verification
- [ ] Task 20: Print MCP reload command for user
- [ ] Task 21: Print test query for user
