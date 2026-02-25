#!/usr/bin/env bash
# scripts/deploy.sh — NixOS deployment script (disko + nixos-anywhere)
#
# Usage:
#   Local install (Live USB):
#     ./scripts/deploy.sh --local <host-name>
#
#   Remote deploy (nixos-anywhere):
#     ./scripts/deploy.sh <host-name> <target-ip> [extra-args...]
#
# Examples:
#   ./scripts/deploy.sh --local nixos-desktop
#   ./scripts/deploy.sh nixos-vm 192.168.122.100
#   ./scripts/deploy.sh nixos-desktop 10.0.0.5
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_DIR="$(dirname "$SCRIPT_DIR")"

# Hosts that require nixos-facter hardware detection
FACTER_HOSTS=("nixos-desktop")

needs_facter() {
  local host="$1"
  for fh in "${FACTER_HOSTS[@]}"; do
    [[ "$host" == "$fh" ]] && return 0
  done
  return 1
}

# === Local install (Live USB) ===
if [[ "${1:-}" == "--local" ]]; then
  HOST="${2:?Usage: $0 --local <host-name>}"
  [[ -d "$FLAKE_DIR/hosts/$HOST" ]] || { echo "Error: hosts/$HOST does not exist"; exit 1; }

  echo "=== Local Install ==="
  echo "Host: $HOST"
  echo ""
  echo "WARNING: This will format disks per disko config and install NixOS!"
  read -rp "Continue? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || exit 1

  sudo nix run github:nix-community/disko/latest -- \
    --mode destroy,format,mount \
    --flake "$FLAKE_DIR#$HOST"
  sudo nixos-install --flake "$FLAKE_DIR#$HOST" --no-root-passwd

  echo "Done! Reboot: reboot"
  exit 0
fi

# === Remote deploy (nixos-anywhere) ===
HOST="${1:?Usage: $0 <host-name> <target-ip> | $0 --local <host-name>}"
TARGET="${2:?Usage: $0 <host-name> <target-ip>}"
shift 2
[[ -d "$FLAKE_DIR/hosts/$HOST" ]] || { echo "Error: hosts/$HOST does not exist"; exit 1; }

echo "=== Remote Deploy (nixos-anywhere) ==="
echo "Host: $HOST → root@$TARGET"

EXTRA_ARGS=()
if needs_facter "$HOST"; then
  FACTER_PATH="$FLAKE_DIR/hosts/$HOST/facter.json"
  echo "[INFO] Physical host — will auto-detect hardware via nixos-facter"
  EXTRA_ARGS+=("--generate-hardware-config" "nixos-facter" "$FACTER_PATH")
fi

echo ""
echo "WARNING: This will format target disk and install NixOS!"
read -rp "Continue? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || exit 1

nix run github:nix-community/nixos-anywhere -- \
  --flake "$FLAKE_DIR#$HOST" \
  --target-host "root@$TARGET" \
  "${EXTRA_ARGS[@]}" \
  "$@"

echo ""
echo "Deploy complete!"
[[ ${#EXTRA_ARGS[@]} -gt 0 ]] && echo "[POST] Commit facter.json: git add hosts/$HOST/facter.json"
