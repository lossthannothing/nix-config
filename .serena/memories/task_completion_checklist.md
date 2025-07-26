# Task Completion Checklist

## After Making Changes

### 1. Format Code
```bash
nixfmt-rfc-style **/*.nix
```

### 2. Validate Configuration
```bash
# Check flake syntax and evaluation
nix flake check

# Test build without switching
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

### 3. Test Changes
```bash
# For NixOS systems
sudo nixos-rebuild test --flake .#<hostname>

# For Home Manager
home-manager switch --flake .#<config>
```

### 4. Commit Changes
```bash
git add .
git commit -m "descriptive commit message"
```

### 5. Apply to System
```bash
# For NixOS
sudo nixos-rebuild switch --flake .#<hostname>

# For Home Manager standalone
home-manager switch --flake .
```

## Quality Checks
- Ensure all imports are valid
- Check that new configurations follow existing patterns
- Verify user permissions and groups are correct
- Test that services start properly