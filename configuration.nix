{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./networking.nix
    ./bootloader.nix
  ];

  options = {
    bootloader.useGrub = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = {
    bootloader.useGrub = true;

    # Set your time zone.
    time.timeZone = "Asia/Manila";
    i18n.defaultLocale = "en_US.UTF-8";

    # intel stuff
    services.thermald.enable = true;

    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;
    services.blueman.enable = true;

    services.openssh.enable = true;
    services.flatpak.enable = true;
    services.libinput.enable = true;
    services.printing.enable = true;

    # Display and Desktop
    services.desktopManager.gnome.enable = true;
    services.displayManager.gdm.enable = true;
    ## Hyprland
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      xwayland.enable = true;
    };

    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];

    # Sound
    security.rtkit.enable = true;
    security.polkit.enable = true;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
    };

    users.users.ric = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "libvirtd"
      ]; # Enable ‘sudo’ for the user.
      packages = with pkgs; [
        tree
      ];
      shell = pkgs.zsh;
    };

    services.xserver.videoDrivers = [ "modesetting" ];
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      package = pkgs-unstable.mesa;
      package32 = pkgs-unstable.pkgsi686Linux.mesa;
      extraPackages = with pkgs; [
        intel-vaapi-driver
        intel-media-driver
      ];
    };

    hardware = {
      bluetooth.enable = true;
    };

    environment.sessionVariables = {
      LIBRA_DRIVER_NAME = "iHD";
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
    };
    environment.variables = {
      EDITOR = "nvim";
    };

    # Steam
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    programs.gamemode.enable = true;

    # Virt-Manager
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    # List packages installed in system profile.
    # You can use https://search.nixos.org/ to find more packages (and options).
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs; [
      # Editor
      vim

      # Compiling / Programming Languages
      gcc
      gnumake
      nodejs_25

      # Audio
      pavucontrol
      ffmpeg

      # Networking
      networkmanagerapplet
      ipset
      nmap
      dnsmasq

      ## Hyprland related packages
      hyprpolkitagent
      hyprpaper
      hyprshot
      hyprcursor
      rofi
      wl-clipboard

      # Wallpaper
      waypaper
      swaybg

      # Terminal
      alacritty
      kitty

      # Authentication Agent
      polkit

      # XDG and Theming
      xdg-desktop-portal
      xdg-desktop-portal-gnome
      nwg-look
      adwaita-icon-theme
      capitaine-cursors

      # Notification
      swaynotificationcenter
      libnotify
      kdePackages.dolphin

      # misc
      stow
      wget
      git
      zoxide
      fzf
      playerctl
      htop
      ncdu

      # Game Tinkerers/Launchers
      lutris
      mangohud

      # Formatting
      gparted
      exfatprogs
      ntfs3g

      # Compression Programs
      zip
      unzip
    ];

    # AppImages
    programs.appimage.enable = true;
    programs.appimage.binfmt = true;
    programs.appimage.package = pkgs.appimage-run.override {
      extraPkgs = pkgs: [
        pkgs.icu
        pkgs.libxcrypt-legacy
        pkgs.python312
        pkgs.python312Packages.torch
        pkgs.webkitgtk_4_1
      ];
    };

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.adwaita-mono
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    programs.zsh.enable = true;

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    system.stateVersion = "25.11";
  };
}
