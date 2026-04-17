# kiro-mempalace uninstaller — Windows (PowerShell)
# Run as: powershell -ExecutionPolicy Bypass -File uninstall.ps1

$ErrorActionPreference = "Stop"

$POWER_DIR       = "$env:USERPROFILE\.kiro\powers\mempalace"
$KIRO_MCP_CONFIG = "$env:USERPROFILE\.kiro\settings\mcp.json"
$MEMPALACE_HOME  = "$env:USERPROFILE\.mempalace"
$BACKUP_SUFFIX   = ".bak.$(Get-Date -Format 'yyyyMMdd_HHmmss')"

function Info { param($msg) Write-Host "[kiro-mempalace] $msg" -ForegroundColor Green }
function Warn { param($msg) Write-Host "[kiro-mempalace] $msg" -ForegroundColor Yellow }

function Backup-File {
    param($Path)
    if (Test-Path $Path) {
        $dest = "$Path$BACKUP_SUFFIX"
        Copy-Item $Path $dest -Force
        Info "Backed up $Path → $dest"
    }
}

Write-Host ""
Write-Host "kiro-mempalace uninstaller"
Write-Host "========================="
Write-Host ""
Write-Host "What would you like to remove?"
Write-Host ""
Write-Host "  1) Kiro integration only  (Power dir + MCP config entry)"
Write-Host "  2) Everything             (integration + mempalace CLI package)"
Write-Host "  3) Cancel"
Write-Host ""
$choice = Read-Host "Choice [1/2/3]"

switch ($choice) {
    "1" { $RemovePackage = $false }
    "2" { $RemovePackage = $true  }
    default { Write-Host "Aborted."; exit 0 }
}

Write-Host ""
Write-Host "Your memory palace data at $MEMPALACE_HOME will NOT be deleted."
Write-Host ""

# ── 1. Remove mempalace entry from global Kiro MCP config ────────────────────
if (Test-Path $KIRO_MCP_CONFIG) {
    Backup-File $KIRO_MCP_CONFIG

    $config = Get-Content $KIRO_MCP_CONFIG | ConvertFrom-Json
    if ($config.mcpServers.PSObject.Properties.Name -contains "mempalace") {
        $config.mcpServers.PSObject.Properties.Remove("mempalace")
        $config | ConvertTo-Json -Depth 10 | Set-Content $KIRO_MCP_CONFIG
        Info "Removed mempalace from $KIRO_MCP_CONFIG"
    } else {
        Info "mempalace not found in $KIRO_MCP_CONFIG — skipping"
    }
} else {
    Info "No MCP config found at $KIRO_MCP_CONFIG — skipping"
}

# ── 2. Remove Kiro Power directory ───────────────────────────────────────────
if (Test-Path $POWER_DIR) {
    Remove-Item -Recurse -Force $POWER_DIR
    Info "Removed $POWER_DIR"
} else {
    Info "Power dir not found — skipping"
}

# ── 3. Optionally uninstall mempalace uv tool ───────────────────────────────
if ($RemovePackage) {
    if (Get-Command uv -ErrorAction SilentlyContinue) {
        try {
            uv tool uninstall mempalace 2>$null
            Info "Uninstalled mempalace CLI package"
        } catch {
            Info "mempalace uv tool not installed — skipping"
        }
    } else {
        Info "uv not found — skipping tool uninstall"
    }
} else {
    Info "Keeping mempalace CLI package (standalone use)"
}

# ── Done ─────────────────────────────────────────────────────────────────────
Write-Host ""
Info "Uninstall complete!"
Write-Host ""
Write-Host "  Your palace data is still at $MEMPALACE_HOME"
Write-Host "  To delete it permanently:  Remove-Item -Recurse -Force $MEMPALACE_HOME"
Write-Host ""
Write-Host "  Restart Kiro to apply changes."
Write-Host ""
