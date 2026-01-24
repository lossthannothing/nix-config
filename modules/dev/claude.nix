# modules/dev/claude.nix
#
# Claude 命令和 skills 配置
{
  flake.modules = {
    homeManager.dev = {
      dotfiles,
      config,
      ...
    }: {
      # Deploy Claude commands
      home.file.".claude/commands/spec.md" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/claude/.claude/commands/spec.md";
      };

      # Deploy NixOS awareness skill
      home.file.".claude/skills/nixos-awareness.md" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/claude/.claude/skills/nixos-awareness.md";
      };
    };
  };
}
