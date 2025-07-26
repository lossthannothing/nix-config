# Project Overview

## Purpose
This is a personal Nix configuration repository for managing NixOS, macOS (via nix-darwin), and other Linux systems using Nix flakes. It provides declarative system and user environment configurations.

## Tech Stack
- **Nix/NixOS**: Declarative package management and system configuration
- **Home Manager**: User environment management
- **Nix Flakes**: Modern Nix configuration format
- **NixOS-WSL**: WSL-specific NixOS integration
- **Nix-Darwin**: macOS system management

## Project Structure
- `flake.nix`: Main flake configuration defining inputs and outputs
- `hosts/`: Host-specific configurations (currently has `wsl/`)
- `home/`: Home Manager user configurations
- `lib/`: Helper functions and common variables
- `os/`: Operating system configurations
- `dotfiles/`: Configuration files and dotfiles
- `scripts/`: Utility scripts

## Current Configurations
- `nixos-wsl`: WSL-based NixOS configuration
- `loss`: Home Manager configuration for user "loss"