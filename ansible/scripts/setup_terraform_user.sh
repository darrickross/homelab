#!/usr/bin/env bash
# ==============================================================================
# setup_terraform_user.sh
#
# Wrapper script for running the Terraform PVE user setup playbook.
# Handles Bitwarden session management and passes BW_SESSION safely via
# the environment (never via --extra-vars to avoid process list exposure).
#
# Usage:
#   ./scripts/setup_terraform_user.sh [ansible-playbook options]
#
# Examples:
#   # Basic run against all hosts:
#   ./scripts/setup_terraform_user.sh
#
#   # Single-node run (recommended for Proxmox clusters):
#   ./scripts/setup_terraform_user.sh -l hv00-pve.sol.mw
#
#   # Dry run:
#   ./scripts/setup_terraform_user.sh --check --diff
#
#   # Force-regenerate the API token (secret rotation):
#   ./scripts/setup_terraform_user.sh -e terraform_user_force_recreate_token=true
#
#   # Use a pre-existing BW_SESSION (skips unlock prompt):
#   export BW_SESSION=$(bw unlock --raw)
#   ./scripts/setup_terraform_user.sh -l hv00-pve.sol.mw
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PLAYBOOK="${ANSIBLE_DIR}/site_terraform_user.yml"

# ==============================================================================
# Pre-flight checks
# ==============================================================================

echo "[setup_terraform_user] Running pre-flight checks..."

if ! command -v bw &>/dev/null; then
  echo "[ERROR] Bitwarden CLI (bw) not found in PATH."
  echo "        Install from: https://bitwarden.com/help/cli/"
  exit 1
fi

if ! command -v ansible-playbook &>/dev/null; then
  echo "[ERROR] ansible-playbook not found in PATH."
  exit 1
fi

if [[ ! -f "${PLAYBOOK}" ]]; then
  echo "[ERROR] Playbook not found at: ${PLAYBOOK}"
  exit 1
fi

echo "[setup_terraform_user] Pre-flight checks passed."

# ==============================================================================
# Bitwarden session setup
# ==============================================================================

echo "[setup_terraform_user] Setting up Bitwarden session..."

# If BW_SESSION is already exported and valid, reuse it.
if [[ -n "${BW_SESSION:-}" ]]; then
  echo "[setup_terraform_user] BW_SESSION is already set — validating..."
  BW_VALIDATE_STATUS=$(bw status --session "${BW_SESSION}" 2>/dev/null \
    | python3 -c "import sys,json; print(json.load(sys.stdin).get('status','unknown'))" 2>/dev/null \
    || echo "unknown")

  if [[ "${BW_VALIDATE_STATUS}" == "unlocked" ]]; then
    echo "[setup_terraform_user] Existing BW_SESSION is valid and vault is unlocked."
  else
    echo "[setup_terraform_user] Existing BW_SESSION is invalid or expired (status: ${BW_VALIDATE_STATUS})."
    echo "[setup_terraform_user] Re-unlocking vault..."
    BW_SESSION=""
  fi
fi

if [[ -z "${BW_SESSION:-}" ]]; then
  # Determine current vault state.
  BW_STATUS=$(bw status 2>/dev/null \
    | python3 -c "import sys,json; print(json.load(sys.stdin).get('status','unauthenticated'))" 2>/dev/null \
    || echo "unauthenticated")

  echo "[setup_terraform_user] Vault status: ${BW_STATUS}"

  case "${BW_STATUS}" in
    unauthenticated)
      echo "[setup_terraform_user] Not logged in. Running 'bw login'..."
      BW_SESSION=$(bw login --raw)
      ;;
    locked)
      echo "[setup_terraform_user] Vault is locked. Running 'bw unlock'..."
      BW_SESSION=$(bw unlock --raw)
      ;;
    unlocked)
      echo "[setup_terraform_user] Vault is unlocked. Exporting session key..."
      BW_SESSION=$(bw unlock --raw)
      ;;
    *)
      echo "[ERROR] Unknown Bitwarden status: ${BW_STATUS}"
      echo "        Try running 'bw status' manually to diagnose."
      exit 1
      ;;
  esac
fi

export BW_SESSION
echo "[setup_terraform_user] Bitwarden session established."

# ==============================================================================
# Run the playbook
# ==============================================================================

echo ""
echo "[setup_terraform_user] Playbook : ${PLAYBOOK}"
echo "[setup_terraform_user] Directory: ${ANSIBLE_DIR}"
echo "[setup_terraform_user] Args     : $*"
echo ""

cd "${ANSIBLE_DIR}"

# BW_SESSION is passed via the environment.
# Ansible's lookup('env', 'BW_SESSION') in the role reads it automatically.
ansible-playbook "${PLAYBOOK}" "$@"

EXIT_CODE=$?

# ==============================================================================
# Post-run summary
# ==============================================================================

echo ""
if [[ ${EXIT_CODE} -eq 0 ]]; then
  echo "[setup_terraform_user] Playbook completed successfully."
  echo ""
  echo "  Retrieve your API token from Bitwarden:"
  echo "    bw get item 'Proxmox Terraform API Token'"
  echo ""
  echo "  Use in your Terraform provider block (bpg/proxmox):"
  echo "    api_token = \"<login.username>=<login.password>\""
else
  echo "[setup_terraform_user] Playbook FAILED with exit code ${EXIT_CODE}."
  echo "  Review the Ansible output above for details."
fi

exit ${EXIT_CODE}
