# Namespace & Aspect Composition

> How namespaces work and how aspects are composed in the den framework.

---

## Overview

This project uses the **vic/den** framework's aspect system. Understanding namespace registration and aspect composition is critical for organizing configurations correctly.

---

## Namespace Types

### Built-in den Namespaces

| Namespace | Purpose | Example |
|-----------|---------|---------|
| `den.default` | Global defaults for all hosts | Nix settings, locale |
| `den.aspects.*` | Named aspects (user, host) | `den.aspects.loss`, `den.aspects.nixos-wsl` |
| `den.hosts.*` | Host definitions | `den.hosts.x86_64-linux.nixos-wsl` |

### Custom Namespaces

Registered in `modules/den.nix`:

```nix
{ inputs, den, ... }: {
  _module.args.__findFile = den.lib.__findFile;
  imports = [
    inputs.den.flakeModule
    (inputs.den.namespace "loss" true)
  ];
}
```

This creates:
- `loss.*` namespace for aspects
- `<loss/...>` angle-bracket import capability

---

## Namespace Registry

### Current Namespaces

| Namespace | File | Description |
|-----------|------|-------------|
| `den.default` | `modules/default.nix` | Global defaults |
| `den.aspects.loss` | `modules/loss.nix` | User "loss" definition |
| `den.aspects.nixos-wsl` | `modules/hosts/nixos-wsl/default.nix` | Host aspect |
| `loss.shell` | `modules/shell.nix` | Shell tools |
| `loss.dev` | `modules/dev.nix` | Dev tools |
| `loss.wsl` | `modules/wsl.nix` | WSL platform |
| `loss.dev._.rust` | `modules/dev/rust.nix` | Rust sub-aspect |
| `loss.dev._.javascript` | `modules/dev/javascript.nix` | JavaScript sub-aspect |
| `loss.dev._.go` | `modules/dev/go.nix` | Go sub-aspect |
| `loss.dev._.python` | `modules/dev/python.nix` | Python sub-aspect |
| `loss.dev._.nix` | `modules/dev/nix.nix` | Nix sub-aspect |

---

## Aspect Composition

### The `includes` Pattern

Aspects compose via `includes`, not `imports`:

```nix
den.aspects.loss = {
  includes = [
    <den/primary-user>
    <loss/shell>
    <loss/dev>
  ];
  # ...
};
```

### Angle-Bracket Imports

The `__findFile` function enables `<namespace/path>` syntax:

```nix
# These are equivalent:
<loss/shell>           # Refers to loss.shell aspect
<den/primary-user>     # Refers to den built-in
```

### Sub-Aspect References

```nix
includes = with loss; [
  dev           # loss.dev
  dev._.rust    # loss.dev._.rust (sub-aspect)
];
```

---

## Sub-Aspect Pattern (`._.`)

### What It Means

The `._` is an alias for `provides` in den/flake-aspects. It defines nested aspects:

```nix
# modules/dev/rust.nix
loss.dev._.rust = { ... };  # "loss.dev provides rust"
```

### When to Use

| Situation | Pattern |
|-----------|---------|
| Standalone aspect | `loss.shell` |
| Child of another aspect | `loss.dev._.rust` |
| Deeper nesting (rare) | `loss.dev._.rust._.extra` |

### Composition Order

```nix
# Correct: parent before children
includes = with loss; [
  dev           # Parent first
  dev._.rust    # Then children
  dev._.javascript
];

# Also correct: children can be in any order
includes = with loss; [
  dev
  dev._.javascript
  dev._.rust
];
```

---

## Host Binding Rules

### ❌ Wrong: Binding in User Module

```nix
# modules/loss.nix - DON'T DO THIS
den.aspects.loss = { ... };

# Wrong place!
den.hosts.x86_64-linux.nixos-wsl.users.loss = {};
```

### ✅ Correct: Binding in Host Module

```nix
# modules/hosts/nixos-wsl/default.nix
{ loss, ... }: {
  # Host registration
  den.hosts.x86_64-linux.nixos-wsl = {};

  # Aspect composition
  den.aspects.nixos-wsl = {
    includes = with loss; [ wsl shell dev ];
    # ...
  };
}
```

**Why**: User modules define capabilities. Host modules decide which users belong to which hosts.

---

## Cross-Aspect Dependencies

### Using Flake Inputs

```nix
# modules/dev/rust.nix
{ inputs, ... }: {
  loss.dev._.rust = {
    nixos.nixpkgs.overlays = [
      inputs.rust-overlay.overlays.default
    ];
  };
}
```

### Using `__findFile`

```nix
{ __findFile, ... }: {
  den.aspects.loss = {
    includes = [
      <den/primary-user>
      <loss/shell>
    ];
  };
}
```

---

## Common Mistakes

| Mistake | Why It's Wrong | Correct Approach |
|---------|---------------|-----------------|
| Using `imports` instead of `includes` | Aspects use `includes` for composition | Use `includes = [ ... ]` |
| `loss.dev.rust` instead of `loss.dev._.rust` | Missing `provides` alias | Use `._.` pattern |
| Host binding in user module | Violates separation of concerns | Put in `modules/hosts/*/` |
| Relative imports like `../shell.nix` | Breaks with den's module system | Use `<loss/shell>` |
| Forgetting `__findFile` parameter | Angle-bracket imports won't work | Add to function args |

---

## Adding a New Namespace

1. Register in `modules/den.nix`:
   ```nix
   (inputs.den.namespace "myuser" true)
   ```

2. Create aspect files:
   ```nix
   # modules/myuser/shell.nix
   myuser.shell.homeManager = { ... }: { ... };
   ```

3. Reference in host:
   ```nix
   includes = with myuser; [ shell ];
   ```

4. Update this document's registry table
