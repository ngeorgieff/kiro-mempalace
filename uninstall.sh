#!/usr/bin/env bash
set -euo pipefail

# kiro-mempalace uninstaller — Mac & Linux

POWER_DIR="${HOME}/.kiro/powers/mempalace"
KIRO_MCP_CONFIG="${HOME}/.kiro/settings/mcp.json"
MEMPALACE_HOME="${HOME}/.mempalace"
BACKUP_SUFFIX=".bak.$(date +%Y%m%d_%H%M%S)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo -e "${GREEN}[kiro-mempalace]${NC} $1"; }
warn()    { echo -e "${YELLOW}[kiro-mempalace]${NC} $1"; }

backup_file() {
  local f="$1"
  if [[ -f "${f}" ]]; then
    cp "${f}" "${f}${BACKUP_SUFFIX}"
    info "Backed up ${f} → ${f}${BACKUP_SUFFIX}"
  fi
}

echo ""
echo "kiro-mempalace uninstaller"
echo "========================="
echo ""
echo "What would you like to remove?"
echo ""
echo "  1) Kiro integration only  (Power dir + MCP config entry)"
echo "  2) Everything             (integration + mempalace CLI package)"
echo "  3) Cancel"
echo ""
read -rp "Choice [1/2/3]: " choice

case "${choice}" in
  1) REMOVE_PACKAGE=false ;;
  2) REMOVE_PACKAGE=true  ;;
  *) echo "Aborted."; exit 0 ;;
esac

echo ""
echo "Your memory palace data at ${MEMPALACE_HOME} will NOT be deleted."
echo ""

# ── 1. Remove mempalace entry from global Kiro MCP config ────────────────────
if [[ -f "${KIRO_MCP_CONFIG}" ]]; then
  backup_file "${KIRO_MCP_CONFIG}"

  PYTHON_BIN="$(command -v python3 || command -v python || true)"
  if [[ -n "${PYTHON_BIN}" ]]; then
    "${PYTHON_BIN}" - <<PYEOF
import json, os

config_path = os.path.expanduser("${KIRO_MCP_CONFIG}")
with open(config_path) as f:
    config = json.load(f)

if "mempalace" in config.get("mcpServers", {}):
    del config["mcpServers"]["mempalace"]
    with open(config_path, "w") as f:
        json.dump(config, f, indent=2)
    print("Removed mempalace from", config_path)
else:
    print("mempalace not found in", config_path, "— skipping")
PYEOF
  else
    warn "No Python found — could not clean ${KIRO_MCP_CONFIG}. Remove the \"mempalace\" key manually."
  fi
else
  info "No MCP config found at ${KIRO_MCP_CONFIG} — skipping"
fi

# ── 2. Remove Kiro Power directory ───────────────────────────────────────────
if [[ -d "${POWER_DIR}" ]]; then
  rm -rf "${POWER_DIR}"
  info "Removed ${POWER_DIR}"
else
  info "Power dir not found — skipping"
fi

# ── 3. Optionally uninstall mempalace uv tool ───────────────────────────────
if [[ "${REMOVE_PACKAGE}" == "true" ]]; then
  if command -v uv &>/dev/null; then
    uv tool uninstall mempalace 2>/dev/null && info "Uninstalled mempalace CLI package" \
      || info "mempalace uv tool not installed — skipping"
  else
    info "uv not found — skipping tool uninstall"
  fi
else
  info "Keeping mempalace CLI package (standalone use)"
fi

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
info "Uninstall complete!"
echo ""
echo "  Your palace data is still at ${MEMPALACE_HOME}"
echo "  To delete it permanently:  rm -rf ${MEMPALACE_HOME}"
echo ""
echo "  Restart Kiro to apply changes."
echo ""
