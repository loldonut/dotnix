{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  home.username = "ric";
  home.homeDirectory = "/home/ric";
  home.stateVersion = "25.11";

  imports = [
    ./hyprland.nix
    ./sh.nix
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "John Heinrich";
      user.email = "loldonutph@gmail.com";
      init.defaultBranch = "main";
    };
  };

  programs.neovim = {
    enable = true;
    withPython3 = false;
    withRuby = false;
    withNodeJs = false;
    withPerl = false;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      telescope-fzf-native-nvim
    ];
  };

  # Force home manager to not clobber with the 'init.lua' file
  xdg.configFile."nvim/init.lua".enable = lib.mkForce false;

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.capitaine-cursors;
    name = "capitaine-cursors";
    size = 32;
  };

  gtk = {
    gtk4.theme = null;
    enable = true;
    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Cyan-Dark";
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Adwaita Sans Regular";
      size = 11;
    };
  };

  home.sessionPath = [ "$HOME/bin" ];

  # Swaync for Notifications
  services.swaync.enable = true;

  home.packages = with pkgs; [
    tmux

    # CLI Apps
    nixfmt
    flatpak
    ripgrep
    btop

    firefox
    mangohud
    discord

    # Multimedia
    amberol
    vlc
  ];
}
