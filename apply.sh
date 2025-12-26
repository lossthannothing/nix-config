#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper function to print colored messages
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to display menu and get user choice
select_option() {
    local prompt="$1"
    shift
    local options=("$@")

    echo "$prompt" >&2
    PS3="Please enter the number of your choice: "
    select opt in "${options[@]}"; do
        if [[ -n $opt ]]; then
            echo "$opt"
            break
        else
            error "Invalid option. Please try again." >&2
        fi
    done
}

# Detect OS and architecture
OS=$(uname -s)
ARCH=$(uname -m)

info "Detected OS: $OS, Architecture: $ARCH"

# Determine available hosts from flake
info "Checking available configurations..."
AVAILABLE_HOSTS=$(nix flake show --json 2>/dev/null | nix run nixpkgs#jq -- -r '.nixosConfigurations | keys[]' 2>/dev/null || echo "")

if [[ -z "$AVAILABLE_HOSTS" ]]; then
    warn "Could not auto-detect hosts. Using default: nixos-wsl"
    AVAILABLE_HOSTS="nixos-wsl"
fi

info "Available hosts: $AVAILABLE_HOSTS"

# Main deployment logic
case "$OS" in
    Darwin)
        info "macOS detected"
        options=(
            "Home Manager Only"
            "Nix Darwin (if configured)"
            "Quit"
        )
        choice=$(select_option "Choose deployment option:" "${options[@]}")

        case "$choice" in
            "Home Manager Only")
                info "Deploying Home Manager for macOS..."
                NIX_CONFIG="experimental-features = nix-command flakes" \
                    nix run home-manager/master -- switch --flake .
                ;;
            "Nix Darwin (if configured)")
                error "Nix Darwin not yet configured in this repository"
                exit 1
                ;;
            "Quit")
                exit 0
                ;;
        esac
        ;;

    Linux)
        # Check if running on WSL
        if grep -qEi "(Microsoft|WSL)" /proc/version &>/dev/null; then
            info "WSL detected"

            # Check if NixOS-WSL
            if [[ -f /etc/os-release ]] && grep -q "ID=nixos" /etc/os-release; then
                info "Running NixOS-WSL"

                # Auto-detect hostname
                HOSTNAME=$(hostname)
                if echo "$AVAILABLE_HOSTS" | grep -q "$HOSTNAME"; then
                    DEFAULT_HOST="$HOSTNAME"
                else
                    DEFAULT_HOST="nixos-wsl"
                fi

                options=(
                    "NixOS-WSL System ($DEFAULT_HOST)"
                    "Home Manager Only"
                    "Quit"
                )
                choice=$(select_option "Choose deployment option:" "${options[@]}")

                case "$choice" in
                    "NixOS-WSL System ($DEFAULT_HOST)")
                        info "Deploying NixOS-WSL configuration..."
                        sudo nixos-rebuild switch --flake ".#$DEFAULT_HOST"
                        info "Note: Home Manager is integrated in NixOS config"
                        ;;
                    "Home Manager Only")
                        info "Deploying Home Manager only..."
                        NIX_CONFIG="experimental-features = nix-command flakes" \
                            nix run home-manager/master -- switch --flake .
                        ;;
                    "Quit")
                        exit 0
                        ;;
                esac
            else
                info "Non-NixOS WSL detected"
                options=(
                    "Home Manager for WSL"
                    "Quit"
                )
                choice=$(select_option "Choose deployment option:" "${options[@]}")

                case "$choice" in
                    "Home Manager for WSL")
                        info "Deploying Home Manager for WSL..."
                        NIX_CONFIG="experimental-features = nix-command flakes" \
                            nix run home-manager/master -- switch --flake .
                        ;;
                    "Quit")
                        exit 0
                        ;;
                esac
            fi
        # Check if running on regular NixOS
        elif [[ -f /etc/os-release ]] && grep -q "ID=nixos" /etc/os-release; then
            info "NixOS detected (non-WSL)"

            # Auto-detect hostname or let user choose
            HOSTNAME=$(hostname)
            if echo "$AVAILABLE_HOSTS" | grep -q "$HOSTNAME"; then
                DEFAULT_HOST="$HOSTNAME"
            else
                # Use first available host as default
                DEFAULT_HOST=$(echo "$AVAILABLE_HOSTS" | head -n1)
            fi

            options=(
                "NixOS System ($DEFAULT_HOST)"
                "Home Manager Only"
                "Quit"
            )
            choice=$(select_option "Choose deployment option:" "${options[@]}")

            case "$choice" in
                "NixOS System ($DEFAULT_HOST)")
                    info "Deploying NixOS configuration..."
                    sudo nixos-rebuild switch --flake ".#$DEFAULT_HOST"
                    ;;
                "Home Manager Only")
                    info "Deploying Home Manager..."
                    NIX_CONFIG="experimental-features = nix-command flakes" \
                        nix run home-manager/master -- switch --flake .
                    ;;
                "Quit")
                    exit 0
                    ;;
            esac
        else
            info "Non-NixOS Linux detected"
            options=(
                "Home Manager Only"
                "Quit"
            )
            choice=$(select_option "Choose deployment option:" "${options[@]}")

            case "$choice" in
                "Home Manager Only")
                    info "Deploying Home Manager for Linux..."
                    NIX_CONFIG="experimental-features = nix-command flakes" \
                        nix run home-manager/master -- switch --flake .
                    ;;
                "Quit")
                    exit 0
                    ;;
            esac
        fi
        ;;

    *)
        error "Unsupported OS: $OS"
        exit 1
        ;;
esac

info "Deployment completed successfully!"
