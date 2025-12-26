# modules/dev/claude.nix
#
# Claude 命令配置
{
  flake.modules = {
    homeManager.dev = {
      dotfiles,
      config,
      ...
    }: {
      home.file.".claude/commands/spec.md" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/claude/.claude/commands/spec.md";
      };
    };
  };
}
