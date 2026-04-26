# Library Reference

## Parametric dispatch

### `den.lib.parametric`

Wraps an aspect with a `__functor` that filters `includes` by argument compatibility. Default uses `atLeast` matching.

```nix
den.lib.parametric { nixos.x = 1; includes = [ ... ]; }
```

### `den.lib.parametric.atLeast`

Same as `parametric`. Functions match if all required params are present.

### `den.lib.parametric.exactly`

Functions match only if required params exactly equal provided params.

```nix
den.lib.parametric.exactly { includes = [ ({ host }: ...) ]; }
```

### `den.lib.parametric.fixedTo`

Calls the aspect with a fixed context, ignoring the actual context:

```nix
den.lib.parametric.fixedTo { host = myHost; } someAspect
```

### `den.lib.parametric.expands`

Extends the received context with additional attributes before dispatch:

```nix
den.lib.parametric.expands { extra = true; } someAspect
```

### `den.lib.parametric.withOwn`

Low-level constructor. Takes a `functor: self -> ctx -> aspect` and wraps an aspect so that owned configs and statics are included at the static stage, and the functor runs at the parametric stage.

## Function introspection

### `den.lib.canTake params fn`

Returns `true` if `fn`'s required arguments are satisfied by `params` (atLeast).

### `den.lib.canTake.atLeast params fn`

Same as `canTake`.

### `den.lib.canTake.exactly params fn`

Returns `true` only if `fn`'s required arguments exactly match `params`.

## Conditional application

### `den.lib.take.atLeast fn ctx`

Calls `fn ctx` if `canTake.atLeast ctx fn`, otherwise returns `{}`.

### `den.lib.take.exactly fn ctx`

Calls `fn ctx` if `canTake.exactly ctx fn`, otherwise returns `{}`.

### `den.lib.take.unused`

`_unused: used: used` — ignores first argument, returns second. Used for discarding `aspect-chain` in `import-tree`.

## Context shortcuts

Built with `den.lib.take.exactly` and `den.lib.parametric.fixedTo`:

### `den.lib.perHost aspect`

Run `aspect` only in `{ host }` contexts.

### `den.lib.perUser aspect`

Run `aspect` only in `{ host, user }` contexts.

### `den.lib.perHome aspect`

Run `aspect` only in `{ home }` contexts.

## Aspect utilities

### `den.lib.statics aspect`

Extracts only static includes from an aspect (non-function includes):

```nix
den.lib.statics someAspect { class = "nixos"; aspect-chain = []; }
```

### `den.lib.owned aspect`

Extracts owned configs from an aspect (removes `includes`, `__functor`):

```nix
den.lib.owned someAspect
```

### `den.lib.isFn value`

Returns `true` if the value is a function or has `__functor`.

### `den.lib.isStatic fn`

Returns `true` if the function can take `{ class, aspect-chain }`.

## `den.lib.__findFile`

The angle bracket resolver:

```nix
_module.args.__findFile = den.lib.__findFile;
```

## Aspect resolution API

### `den.lib.aspects.resolve class aspect`

Resolves an aspect for a given class (e.g. `"nixos"`), returning a module with `imports`. Uses `adapters.default` which honors `meta.adapter` on aspects.

### `den.lib.aspects.resolve.withAdapter adapter class aspect`

Resolves with a custom adapter instead of the default.

### `den.lib.aspects.adapters`

Composable adapters for `resolve.withAdapter`. Each adapter receives `{ aspect, class, classModule, recurse, aspect-chain, resolveChild }` and returns the resolved result.

| Adapter | Description |
|---------|-------------|
| `module` | Collects class modules and recurses on includes |
| `default` | `filterIncludes module` — the default pipeline |
| `filter pred adapter` | Returns `{}` if `pred aspect` is false |
| `map f adapter` | Transforms the adapter's result with `f` |
| `mapAspect f adapter` | Transforms the aspect before passing to adapter |
| `mapIncludes f adapter` | Transforms each include before recursion |
| `filterIncludes adapter` | Honors `meta.adapter`, filters empty includes, tags survivors for propagation |
