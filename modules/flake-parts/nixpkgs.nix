{
  inputs,
  withSystem,
  ...
}: {
  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfreePredicate = _pkg: true;
      };
      # perSystem 的 overlays 只影响 perSystem 功能
      # NixOS/Home Manager 使用 flake.overlays
    };
  };

  # 定义 flake-level overlay 供 NixOS/Home Manager 使用
  flake.overlays = {
    rust = inputs.rust-overlay.overlays.default;

    default = _final: prev: {
      local = withSystem prev.stdenv.hostPlatform.system ({config, ...}: config.packages);
    };
  };
}
