# kiro-mempalace installer — Windows (PowerShell)
# https://github.com/yourusername/kiro-mempalace
# Run as: powershell -ExecutionPolicy Bypass -File install.ps1

$ErrorActionPreference = "Stop"

$POWER_DIR     = "$env:USERPROFILE\.kiro\powers\mempalace"
$KIRO_MCP_CONFIG = "$env:USERPROFILE\.kiro\settings\mcp.json"
$MEMPALACE_HOME  = "$env:USERPROFILE\.mempalace"
$SCRIPT_DIR    = $PSScriptRoot

function Info  { param($msg) Write-Host "[kiro-mempalace] $msg" -ForegroundColor Green }
function Warn  { param($msg) Write-Host "[kiro-mempalace] $msg" -ForegroundColor Yellow }
function Fail  { param($msg) Write-Host "[kiro-mempalace] ERROR: $msg" -ForegroundColor Red; exit 1 }

# ── 1. Check / install uv ────────────────────────────────────────────────────
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Warn "uv not found — installing..."
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    $env:PATH = "$env:USERPROFILE\.local\bin;$env:PATH"
}

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Fail "uv installation failed. Install manually: https://docs.astral.sh/uv/getting-started/installation/"
}
Info "uv found: $(uv --version)"

# ── 2. Install mempalace ─────────────────────────────────────────────────────
Info "Installing mempalace..."
uv tool install mempalace --upgrade

# Resolve python used by the uv-managed environment
try {
    $PYTHON_BIN = (uv tool run --from mempalace python -c "import sys; print(sys.executable)").Trim()
} catch {
    $PYTHON_BIN = ""
}

if (-not $PYTHON_BIN) {
    $PYTHON_BIN = (Get-Command python -ErrorAction SilentlyContinue)?.Source
}
if (-not $PYTHON_BIN) {
    $PYTHON_BIN = (Get-Command python3 -ErrorAction SilentlyContinue)?.Source
}
if (-not $PYTHON_BIN) {
    Fail "No Python found. Install Python 3.9+ from https://python.org and re-run."
}
Info "Python: $PYTHON_BIN"

# ── 3. Initialize mempalace palace ───────────────────────────────────────────
Info "Initializing memory palace at $MEMPALACE_HOME..."
New-Item -ItemType Directory -Force -Path $MEMPALACE_HOME | Out-Null
try { & $PYTHON_BIN -m mempalace.cli init $MEMPALACE_HOME 2>$null } catch {}

# ── 4. Install Kiro Power ────────────────────────────────────────────────────
Info "Installing Kiro Power to $POWER_DIR..."
New-Item -ItemType Directory -Force -Path "$POWER_DIR\steering" | Out-Null

Copy-Item "$SCRIPT_DIR\POWER.md"                     "$POWER_DIR\POWER.md"         -Force
Copy-Item "$SCRIPT_DIR\mcp.json"                     "$POWER_DIR\mcp.json"         -Force
Copy-Item "$SCRIPT_DIR\hooks.json"                   "$POWER_DIR\hooks.json"       -Force
Copy-Item "$SCRIPT_DIR\steering\on-session-start.md" "$POWER_DIR\steering\on-session-start.md" -Force
Copy-Item "$SCRIPT_DIR\steering\on-session-end.md"   "$POWER_DIR\steering\on-session-end.md"   -Force

# Patch python path into Power mcp.json
$powerMcp = Get-Content "$POWER_DIR\mcp.json" | ConvertFrom-Json
$powerMcp.mcpServers.mempalace.command = $PYTHON_BIN
$powerMcp | ConvertTo-Json -Depth 10 | Set-Content "$POWER_DIR\mcp.json"

# ── 5. Register in global Kiro MCP config ────────────────────────────────────
$kiroSettingsDir = Split-Path $KIRO_MCP_CONFIG
New-Item -ItemType Directory -Force -Path $kiroSettingsDir | Out-Null

if (-not (Test-Path $KIRO_MCP_CONFIG)) {
    '{"mcpServers":{}}' | Set-Content $KIRO_MCP_CONFIG
}

$config = Get-Content $KIRO_MCP_CONFIG | ConvertFrom-Json
if (-not $config.mcpServers) { $config | Add-Member -NotePropertyName mcpServers -NotePropertyValue @{} }

$config.mcpServers | Add-Member -NotePropertyName mempalace -NotePropertyValue @{
    command = $PYTHON_BIN
    args    = @("-m", "mempalace.mcp_server")
    env     = @{ MEMPALACE_HOME = $MEMPALACE_HOME }
} -Force

$config | ConvertTo-Json -Depth 10 | Set-Content $KIRO_MCP_CONFIG
Info "Global MCP config updated: $KIRO_MCP_CONFIG"

# ── Done ─────────────────────────────────────────────────────────────────────
Write-Host ""
Info "Installation complete!"
Write-Host ""
Write-Host "  Memory palace : $MEMPALACE_HOME"
Write-Host "  Kiro Power    : $POWER_DIR"
Write-Host "  Global MCP    : $KIRO_MCP_CONFIG"
Write-Host ""
Write-Host "  Restart Kiro to activate. No per-project setup needed."
Write-Host ""
