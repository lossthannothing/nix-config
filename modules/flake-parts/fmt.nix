# modules/flake-parts/fmt.nix
#
# Formatter 配置 - 使用 treefmt-nix
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

        # JavaScript/TypeScript - 使用 biome
        biome.enable = true;

        # Just
        just.enable = true;

        # 通用
        # typos.enable = true;  # 拼写检查，不应该作为 formatter
        yamlfmt.enable = true;
        jsonfmt.enable = true;
      };

      settings = {
        on-unmatched = "warn";
        excludes = [
          "*.md"        # 排除 markdown 文件
          ".trellis/**" # 排除 trellis 脚本目录及其所有内容
          "*.task.json" # 如果有这种特定格式的 JSON，建议也排除
          "LICENSE"     # 通常 LICENSE 也不需要格式化
        ];
      };
    };
  };
}
