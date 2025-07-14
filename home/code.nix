{ pkgs, dotfiles, ... }:

{
  home.packages = with pkgs; [
    neovim
    lunarvim
    uv
    fnm
    ansible
    git-lfs
  ];

  programs = {
    git = {
      enable = true;
      userName = "Lossilklauralin";
      userEmail = "lossilklauralin@gmail.com";

      init.defaultBranch = "main";
      lfs.enable = true;
      pull.rebase = true;
      rerere.enabled = true;

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
        rerere = {
          autoupdate = true;
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
    rustup.enable = true;
  };

  home.file = {
    "./.config/lvim/config.lua".source = "${dotfiles}/config/.config/lvim/config.lua";
    ".global.gitignore".source = "${dotfiles}/git/.global.gitignore";
  };
}
