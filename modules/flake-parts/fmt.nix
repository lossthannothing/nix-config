# modules/flake-parts/fmt.nix
#
# Formatter 配置 - 使用 treefmt-nix

{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";

      programs = {
        # Nix
        nixfmt.enable = true;  # 使用 nixfmt-rfc-style
        alejandra.enable = true;
        deadnix.enable = true;
        statix.enable = true;

        # Shell
        shfmt.enable = true;
        shellcheck.enable = true;

        # Rust
        rustfmt.enable = true;

        # Python
        black.enable = true;
        ruff-format.enable = true;
        ruff-check.enable = true;

        # Go
        gofmt.enable = true;
        gofumpt.enable = true;

        # JavaScript/TypeScript - 使用 biome
        biome.enable = true;

        # Just
        just.enable = true;

        # 通用
        typos.enable = true;
        yamlfmt.enable = true;
        jsonfmt.enable = true;
      };

      settings = {
        on-unmatched = "warn";
      };
    };
  };
}
