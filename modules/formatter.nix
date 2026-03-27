# modules/formatter.nix
#
# Formatter configuration using treefmt-nix
# Migrated from: flake-parts/fmt.nix
{inputs, ...}: {
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";

      programs = {
        # Nix
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

        # JavaScript/TypeScript
        biome.enable = true;

        # Just
        just.enable = true;

        # General
        yamlfmt.enable = true;
        jsonfmt.enable = true;
      };

      settings = {
        on-unmatched = "warn";
        excludes = [
          "*.md"
          ".trellis/**"
          "*.task.json"
          "LICENSE"
        ];
      };
    };
  };
}
