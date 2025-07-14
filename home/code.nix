{ pkgs, dotfiles, ... }:

{
  home.packages = with pkgs; [
    neovim
    lunarvim
    uv
    fnm
    rustup
    ansible
  ];

  programs = {
    git = {
      enable = true;
      userName = "Lossilklauralin";
      userEmail = "lossilklauralin@gmail.com";
      lfs.enable = true;
      # Home Manager programs.git 模块直接支持的顶层选项到此为止。
      # 其他所有Git配置，即使在Git自身中是顶层，也必须放入 extraConfig。

      extraConfig = {
        init = {
          defaultBranch = "main";
        };
        pull = {
          rebase = true;
        };
        rerere = {
          enabled = true; # 将 rerere.enabled 移动到这里
          autoupdate = true;
        };
        core = {
          autocrlf = false;
          eol = "lf";
          excludesfile = "~/.global.gitignore";
        };
        column = {
          ui = "auto";
        };
        branch = {
          sort = "-committerdate";
        };
        tag = {
          sort = "version:refname";
        };
        diff = {
          renames = true;
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
        };
        push = {
          followTags = true;
          default = "simple";
          autoSetupRemote = true;
        };
        fetch = {
          prune = true;
          pruneTags = true;
        };
        rebase = {
          autoSquash = true;
          autoStash = true;
          updateRefs = true;
        };
        merge = {
          conflictstyle = "zdiff3";
        };
        help = {
          autocorrect = "prompt";
        };
      };
    };
    gh.enable = true;
    go.enable = true;
    bun.enable = true;
    lazygit.enable = true;
  };

  home.file = {
    "./.config/lvim/config.lua".source = "${dotfiles}/config/.config/lvim/config.lua";
    ".global.gitignore".source = "${dotfiles}/git/.global.gitignore";
  };
}
