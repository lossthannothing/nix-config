---
name: den-reference
description: >
  Reference documentation for the vic/den NixOS framework (v0.10.0). Consult this skill
  whenever working with den aspects, hosts, homes, contexts, batteries, or any den.* API.
  Trigger when the user asks about den configuration, aspect architecture, context pipeline,
  or writes Nix modules using den.hosts, den.aspects, den.ctx, den.lib, den._ (provides),
  includes, provides, den.schema, or any den-related Nix code. Also use when the user asks
  how to add a new host, user, aspect, battery, or context type in a den-based NixOS config.
---

# den Framework Reference

The den framework is an aspect-oriented NixOS/Darwin/home-manager configuration system built on flake-parts. It decomposes system configs into composable *aspects* that are resolved through a context pipeline.

## Architecture overview

```
den.hosts.<arch>.<name>  →  den.ctx.host  →  resolved aspect  →  flake output
den.homes.<arch>.<name>  →  den.ctx.home  →  resolved aspect  →  flake output
```

Aspects declare per-class config (`nixos`, `darwin`, `homeManager`) and `includes` (lists of sub-aspects or functions dispatched by context). The context pipeline (`den.ctx`) wires aspects to hosts/users/homes through providers and transitions.

## Reference files

Read the relevant reference file for the topic you're working on:

| Topic | File | When to read |
|-------|------|--------------|
| Host/home/user schema, options, `den.schema` | `references/schema.md` | Defining hosts, homes, users, or schema base modules |
| Aspect structure, includes, adapters, resolution | `references/aspects.md` | Writing or composing aspects, understanding includes/providers |
| Built-in batteries (`den._.*`) | `references/batteries.md` | Using define-user, primary-user, shell, forward, import-tree, HM/hjem |
| Context pipeline (`den.ctx`) | `references/ctx.md` | Understanding or customizing how aspects map to hosts/users/homes |
| Library helpers (`den.lib.*`) | `references/lib.md` | Using parametric, perHost/perUser, take, aspects.resolve |
| Output pipeline, instantiation | `references/output.md` | Custom outputs, packages/checks, instantiate overrides |

## Key concepts

- **Aspects** are the core unit — attribute sets with class-keyed config and `includes`.
- **Context pipeline** (`den.ctx`) resolves which aspects apply to each host/user/home.
- **Batteries** (`den._`) are reusable aspect providers shipped with den.
- **`includes`** can be static (module paths) or parametric (functions dispatched by context arguments).
- **`provides`** lets one aspect supply sub-aspects to others (`den.aspects.foo.provides.bar`).
