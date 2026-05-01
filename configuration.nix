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

  # Networking
  networking.hostName = "ric-nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  networking.nftables = {
    enable = true;
    ruleset = ''
      table inet filter {
        set l4d2_cns {
          type ipv4_addr
          flags interval
          elements = {
            185.187.155.10, 45.67.85.139, 202.186.164.240, 103.131.188.71,
            202.186.47.138, 192.168.19.11, 155.138.194.251, 46.174.52.5,
            157.20.105.71, 190.2.141.8, 178.239.171.97, 2.58.201.55,
            45.11.230.10, 175.140.7.65, 202.186.160.125, 192.168.100.110,
            43.230.163.166, 94.72.141.139, 185.121.26.7, 60.50.29.31,
            188.127.241.206, 202.186.162.161, 45.134.110.25, 45.11.231.30,
            93.190.139.252, 5.189.124.206, 188.127.244.198, 202.186.102.95,
            18.180.172.93, 175.137.203.55, 2.58.200.5, 108.181.54.69,
            212.8.248.124, 85.214.110.16, 175.141.9.200, 219.95.53.226,
            192.168.88.30, 148.251.130.211, 118.100.98.186, 172.93.102.9,
            8.12.16.195, 45.67.86.40, 2.58.201.66, 151.158.198.49, 202.184.101.60,
            43.143.87.158, 104.149.151.170, 202.186.169.46, 110.42.9.24, 103.40.13.58,
            180.188.24.50, 210.16.171.17, 202.189.15.5, 43.249.194.250, 160.202.231.31,
            113.68.24.38, 124.222.49.178, 74.91.124.246, 164.132.201.202, 159.75.77.193,
            58.153.161.130, 46.174.51.126, 202.184.47.51, 202.184.47.139, 120.77.206.2
          }
        }

        chain input {
          type filter hook input priority 0; policy accept;
          ip saddr @l4d2_cns drop
        }

        chain output {
          type filter hook output priority 0; policy accept;
          ip daddr @l4d2_cns drop
        }
      }
    '';
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
    ];
    allowedUDPPortRanges = [
      {
        from = 4000;
        to = 4007;
      }
      {
        from = 8000;
        to = 8010;
      }
      {
        from = 27005;
        to = 27030;
      }
    ];
    trustedInterfaces = [ "virbr0" ];
    extraPackages = with pkgs; [
      ipset
    ];
  };

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
  programs.appimage.package = pkgs.appimage-run.override
  {
    extraPkgs = pkgs:
      [
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
}
