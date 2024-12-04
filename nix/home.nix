{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "smparkin";
  home.homeDirectory = "/Users/smparkin";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home dir
  home.file = {
    ".zshrc".source = ../zsh/zshrc;
    ".zsh.d/aliases".source = ../zsh/aliases;
    ".zsh.d/functions".source = ../zsh/functions;
    ".zsh.d/theme".source = ../zsh/theme;
    ".gitconfig".source = ../git/gitconfig;
    ".gitignore_global".source = ../git/gitignore_global;
    ".tmux.conf".source = ../tmux/tmux.conf;
    ".vimrc".source = ../vim/vimrc;
  };
}
