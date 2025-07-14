# nix config

## home manager

```bash
# linux arm
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .#linux

# linux x86_64 (wsl)
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .#x86_64-linux

# macos
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .#darwin
```

## nix darwin

```bash
cd nix-config
sudo NIX_CONFIG="experimental-features = nix-command flakes" nix run nix-darwin/nix-darwin-25.05#darwin-rebuild -- switch --flake .
```
## nix nixos_wsl

```bash
cd nix-config
sudo NIX_CONFIG="experimental-features = nix-command flakes" nix run github:NixOS/nixpkgs/nixos-25.05#nixos-rebuild -- switch --flake .#LossNixOS-WSL
```
