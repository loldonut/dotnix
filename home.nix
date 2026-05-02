{
  inputs,
  config,
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
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      telescope-fzf-native-nvim
    ];
  };

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

  # Swaync for Notifications
  services.swaync.enable = true;

  home.packages = with pkgs; [
    tmux
    ripgrep
    nixfmt
    flatpak

    firefox
    mangohud
    discord

    btop

    # Multimedia
    amberol
    vlc
  ];
}
