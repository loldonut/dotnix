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
    programs.dconf.enable = true;
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

    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        # List by default
        zlib
        zstd
        stdenv.cc.cc
        curl
        openssl
        attr
        libssh
        bzip2
        libxml2
        acl
        libsodium
        util-linux
        xz
        systemd

        # My own additions

        libGL
        libva
        pipewire

        libelf

        # Required
        glib
        gtk2

        # Inspired by steam
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/st/steam/package.nix#L36-L85
        networkmanager
        vulkan-loader
        libgbm
        libdrm
        libxcrypt
        coreutils
        pciutils
        zenity
        # glibc_multi.bin # Seems to cause issue in ARM

        # # Without these it silently fails

        gnome2.GConf
        nspr
        nss
        cups
        libcap
        SDL2
        libusb1
        dbus-glib
        ffmpeg
        # Only libraries are needed from those two
        libudev0-shim

        # needed to run unity
        gtk3
        icu
        libnotify
        gsettings-desktop-schemas
        # https://github.com/NixOS/nixpkgs/issues/72282
        # https://github.com/NixOS/nixpkgs/blob/2e87260fafdd3d18aa1719246fd704b35e55b0f2/pkgs/applications/misc/joplin-desktop/default.nix#L16
        # log in /home/leo/.config/unity3d/Editor.log
        # it will segfault when opening files if you don’t do:
        # export XDG_DATA_DIRS=/nix/store/0nfsywbk0qml4faa7sk3sdfmbd85b7ra-gsettings-desktop-schemas-43.0/share/gsettings-schemas/gsettings-desktop-schemas-43.0:/nix/store/rkscn1raa3x850zq7jp9q3j5ghcf6zi2-gtk+3-3.24.35/share/gsettings-schemas/gtk+3-3.24.35/:$XDG_DATA_DIRS
        # other issue: (Unity:377230): GLib-GIO-CRITICAL **: 21:09:04.706: g_dbus_proxy_call_sync_internal: assertion 'G_IS_DBUS_PROXY (proxy)' failed

        # Verified games requirements

        libogg
        libvorbis
        SDL
        SDL2_image
        glew110
        libidn
        tbb

        # Other things from runtime
        flac
        freeglut
        libjpeg
        libpng
        libpng12
        libsamplerate
        libmikmod
        libtheora
        libtiff
        pixman
        speex
        SDL_image
        SDL_ttf
        SDL_mixer
        SDL2_ttf
        SDL2_mixer
        libappindicator-gtk2
        libdbusmenu-gtk2
        libindicator-gtk2
        libcaca
        libcanberra
        libgcrypt
        libvpx
        librsvg

        libvdpau
        # ...
        # Some more libraries that I needed to run programs
        pango
        cairo
        atk
        gdk-pixbuf
        fontconfig
        freetype
        dbus
        alsa-lib
        expat
        # for blender
        libxkbcommon

        libxcrypt-legacy # For natron
        libGLU # For natron

        # Appimages need fuse, e.g. https://musescore.org/fr/download/musescore-x86_64.AppImage
        fuse
        e2fsprogs
      ];
    };

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
      hyprshutdown
      rofi
      wl-clipboard
      wayle

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
