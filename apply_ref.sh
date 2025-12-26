#!/usr/bin/env bash

# Function to display menu and get user choice
function display_menu() {
  local prompt="$1"
  shift
  local options=("$@")

  echo "$prompt" >&2 # Print prompt to stderr

  PS3="Please enter the number of your choice: "
  select opt in "${options[@]}"; do
    if [[ -n $opt ]]; then
      echo "$opt" # Print selection to stdout
      break
    else
      echo "Invalid option. Please try again." >&2 # Print error to stderr
    fi
  done
}

# Detect OS
os=$(uname -s)

if [[ $os == "Darwin" ]]; then
  options=(
    "Apply All"
    "Home Manager for macOS"
    "Nix Darwin"
    "Quit"
  )
  choice=$(display_menu "Detected macOS. Choose an option:" "${options[@]}")

  case "$choice" in
  "Apply All")
    echo "Applying all configurations for macOS..."
    echo "Applying Home Manager for macOS..."
    NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .#darwin
    echo "Removing old zsh configs..."
    sudo rm -rf /etc/zshrc /etc/zprofile
    echo "Applying Nix Darwin..."
    sudo NIX_CONFIG="experimental-features = nix-command flakes" nix run nix-darwin/nix-darwin-25.05#darwin-rebuild -- switch --flake .
    ;;
  "Home Manager for macOS")
    echo "Applying Home Manager for macOS..."
    NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .#darwin
    ;;
  "Nix Darwin")
    echo "Applying Nix Darwin..."
    sudo NIX_CONFIG="experimental-features = nix-command flakes" nix run nix-darwin/nix-darwin-25.05#darwin-rebuild -- switch --flake .
    ;;
  "Quit")
    exit 0
    ;;
  esac
elif [[ $os == "Linux" ]]; then
  arch=$(uname -m)
  options=()

  if [[ $arch == "aarch64" || $arch == "arm64" ]]; then
    options+=("Home Manager for ARM Linux")
  elif [[ $arch == "x86_64" ]]; then
    options+=("Home Manager for x86_64 Linux (WSL)")
  fi

  options+=("Home Manager for Linux GUI")

  if [[ -f /etc/os-release ]] && grep -q "ID=nixos" /etc/os-release; then
    options+=("NixOS")
  fi

  options+=("Quit")

  choice=$(display_menu "Detected Linux ($arch). Choose an option:" "${options[@]}")

  case "$choice" in
  "Home Manager for ARM Linux")
    echo "Applying Home Manager for ARM Linux..."
    NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .#linux
    ;;
  "Home Manager for x86_64 Linux (WSL)")
    echo "Applying Home Manager for x86_64 Linux..."
    NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .#x86_64-linux
    ;;
  "Home Manager for Linux GUI")
    echo "Applying Home Manager for Linux GUI..."
    NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .#linux-gui
    ;;
  "NixOS")
    echo "Applying NixOS..."
    sudo NIXPKGS_ALLOW_INSECURE=1 nixos-rebuild switch --flake .#nixos --impure
    ;;
  "Quit")
    exit 0
    ;;
  esac
else
  echo "Unsupported OS: $os"
  exit 1
fi
