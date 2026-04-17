#!/usr/bin/env bash
set -euo pipefail

# kiro-mempalace installer — Mac & Linux
# https://github.com/yourusername/kiro-mempalace

POWER_DIR="${HOME}/.kiro/powers/mempalace"
KIRO_MCP_CONFIG="${HOME}/.kiro/settings/mcp.json"
MEMPALACE_HOME="${HOME}/.mempalace"
BACKUP_SUFFIX=".bak.$(date +%Y%m%d_%H%M%S)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[kiro-mempalace]${NC} $1"; }
warn()    { echo -e "${YELLOW}[kiro-mempalace]${NC} $1"; }
error()   { echo -e "${RED}[kiro-mempalace]${NC} $1"; exit 1; }

# Back up a file if it exists; no-op otherwise
backup_file() {
  local f="$1"
  if [[ -f "${f}" ]]; then
    cp "${f}" "${f}${BACKUP_SUFFIX}"
    info "Backed up ${f} → ${f}${BACKUP_SUFFIX}"
  fi
}

# ── 1. Check / install uv ────────────────────────────────────────────────────
if ! command -v uv &>/dev/null; then
  warn "uv not found — installing..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="${HOME}/.local/bin:${PATH}"
fi

if ! command -v uv &>/dev/null; then
  error "uv installation failed. Install it manually: https://docs.astral.sh/uv/getting-started/installation/"
fi
info "uv found: $(uv --version)"

# ── 2. Install mempalace ─────────────────────────────────────────────────────
info "Installing mempalace..."
uv tool install mempalace --upgrade

# Resolve the python used by the uv-managed mempalace env
PYTHON_BIN="$(uv tool run --from mempalace python3 -c 'import sys; print(sys.executable)' 2>/dev/null || true)"

# Fallback: find python3 on PATH
if [[ -z "${PYTHON_BIN}" ]]; then
  PYTHON_BIN="$(command -v python3 || command -v python || true)"
fi

[[ -z "${PYTHON_BIN}" ]] && error "No Python found. Install Python 3.9+ and re-run."
info "Python: ${PYTHON_BIN}"

# ── 3. Initialize mempalace palace ───────────────────────────────────────────
info "Initializing memory palace at ${MEMPALACE_HOME}..."
mkdir -p "${MEMPALACE_HOME}"
"${PYTHON_BIN}" -m mempalace.cli init "${MEMPALACE_HOME}" 2>/dev/null || true

# ── 4. Install Kiro Power ────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info "Installing Kiro Power to ${POWER_DIR}..."
mkdir -p "${POWER_DIR}/steering"

# Back up existing Power files before overwriting
for f in "${POWER_DIR}/POWER.md" "${POWER_DIR}/mcp.json" "${POWER_DIR}/hooks.json" \
         "${POWER_DIR}/steering/on-session-start.md" "${POWER_DIR}/steering/on-session-end.md"; do
  backup_file "${f}"
done

cp "${SCRIPT_DIR}/POWER.md"                      "${POWER_DIR}/POWER.md"
cp "${SCRIPT_DIR}/mcp.json"                      "${POWER_DIR}/mcp.json"
cp "${SCRIPT_DIR}/hooks.json"                    "${POWER_DIR}/hooks.json"
cp "${SCRIPT_DIR}/steering/on-session-start.md"  "${POWER_DIR}/steering/on-session-start.md"
cp "${SCRIPT_DIR}/steering/on-session-end.md"    "${POWER_DIR}/steering/on-session-end.md"

# ── 5. Register in global Kiro MCP config ────────────────────────────────────
mkdir -p "$(dirname "${KIRO_MCP_CONFIG}")"

# Back up existing global MCP config before modifying
backup_file "${KIRO_MCP_CONFIG}"

if [[ ! -f "${KIRO_MCP_CONFIG}" ]]; then
  cat > "${KIRO_MCP_CONFIG}" <<EOF
{
  "mcpServers": {}
}
EOF
fi

# Inject mempalace entry using Python (avoids jq dependency)
# Uses uvx so the config is portable across machines — no hardcoded paths.
"${PYTHON_BIN}" - <<PYEOF
import json, os

config_path = os.path.expanduser("${KIRO_MCP_CONFIG}")

with open(config_path) as f:
    config = json.load(f)

config.setdefault("mcpServers", {})["mempalace"] = {
    "command": "uvx",
    "args": ["--from", "mempalace", "python", "-m", "mempalace.mcp_server"]
}

with open(config_path, "w") as f:
    json.dump(config, f, indent=2)

print("Global MCP config updated:", config_path)
PYEOF

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
info "Installation complete!"
echo ""
echo "  Memory palace : ${MEMPALACE_HOME}"
echo "  Kiro Power    : ${POWER_DIR}"
echo "  Global MCP    : ${KIRO_MCP_CONFIG}"
echo ""
echo "  Restart Kiro to activate. No per-project setup needed."
echo ""
