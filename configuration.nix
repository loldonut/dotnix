{ inputs, config, lib, pkgs, ... }: let
  pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Boot Loader
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "ric-nixos"; # Define your hostname.

  # Networking
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Manila";
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "ter-powerline-v16b";
  #   keyMap = "us";
  #   useXkbConfig = true;
  # };

  services.printing.enable = true;

  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
  };

  services.libinput.enable = true;

  users.users.ric = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    shell = pkgs.zsh;
  };

  # Desktop
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };
  environment.variables = {
    EDITOR = "nvim";
  };

  hardware = {
    graphics.enable = true;
    bluetooth.enable = true;
  };

  hardware.graphics = {
   package = pkgs-unstable.mesa;
   enable32Bit = true;
   package32 = pkgs-unstable.pkgsi686Linux.mesa;
  };

  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.blueman.enable = true;

  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
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

    # Formatting
    gparted
    exfatprogs
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.zsh.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.adwaita-mono
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.openssh.enable = true;
  services.flatpak.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPortRanges = [
      { from = 4000; to = 4007; }
      { from = 8000; to = 8010; }
      { from = 27005; to = 27030; }
    ];
  };

  system.stateVersion = "25.11";
}

