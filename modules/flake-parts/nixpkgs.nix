{
  inputs,
  withSystem,
  ...
}: {
  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [];
      config = {
        allowUnfreePredicate = _pkg: true;
      };
    };
  };

  # 定义 flake-level overlay 供 NixOS/Home Manager 使用
  flake.overlays = {
    default = _final: prev: {
      local = withSystem prev.stdenv.hostPlatform.system ({config, ...}: config.packages);
    };
  };
}
