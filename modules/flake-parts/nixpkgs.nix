{
  inputs,
  withSystem,
  ...
}: {
  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        # 为非 NixOS 用户（standalone Home Manager）注入 rust-overlay
        inputs.rust-overlay.overlays.default
      ];
      config = {
        allowUnfreePredicate = _pkg: true;
      };
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
