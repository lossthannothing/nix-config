{ pkgs, dotfiles, ... }:

{
  home.packages = with pkgs; [
    neovim
    lunarvim
    uv
    ansible
    git-lfs
  ];

  # git
  programs.git = {
      enable = true;
      
      # 对应 [user] 部分
      userName = "Lossilklauralin";
      userEmail = "lossilklauralin@gmail.com";

      # 对应 [init] 部分
      init.defaultBranch = "main";
      
      # Git LFS 支持
      lfs.enable = true;

      # 对应 [pull], [fetch], [push], [rebase], [rerere], [help], [diff] 中的部分
      pull.rebase = true;
      fetch.prune = true;
      push.followTags = true;
      rebase.autoSquash = true;
      rerere.enabled = true;
      help.autocorrect = "prompt";
      diff.renames = true;

      # 对于没有专属选项的配置，统一使用 extraConfig
      extraConfig = {
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
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
        };
        push = {
          default = "simple";
          autoSetupRemote = true;
        };
        fetch = {
          # 注意: fetch.all 不是一个标准的 git config 选项，因此未包含
          pruneTags = true;
        };
        rebase = {
          autoStash = true;
          updateRefs = true;
        };
        rerere = {
          autoupdate = true;
        };
        merge = {
          conflictstyle = "zdiff3";
        };
      };
    };
  # language tools
  programs = {
    gh.enable = true;
    go.enable = true;
    bun.enable = true;

    lazygit.enable = true;
    
    rustup.enable = true;
    fnm.enable = true;
  };
  
  home.file = {
    "./.config/lvim/config.lua".source = "${dotfiles}/config/.config/lvim/config.lua";
    ".global.gitignore".source = "${dotfiles}/git/.global.gitignore";
  };
}
