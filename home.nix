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

  imports = [ ./hyprland.nix ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "John Heinrich";
      user.email = "loldonutph@gmail.com";
      init.defaultBranch = "main";
    };
  };

  programs.bash.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      vim = "nvim";
    };

    initContent = ''
      export NIX_LD=$(nix eval --impure --raw --expr 'let pkgs = import <nixpkgs> {}; NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker"; in NIX_LD')

      eval "$(zoxide init --cmd cd zsh)"
      eval "$(fzf --zsh)"

      fpath=(~/ $fpath)

      autoload -Uz compinit
      compinit

      if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
        exec ~/.sessionize
      fi
    '';

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "emoji"
        "gpg-agent"
        "tmux"
      ];
    };
  };
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";

    extraConfig = ''
      unbind r
      bind r source-file ~/.tmux.conf

      bind C-k send-keys 'clear && tmux clear-history'\; send-keys 'Enter'
      bind C-j send-keys 'killall zsh; zsh'\; send-keys 'Enter'

      set -g prefix C-s

      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ",xterm-256color*:Tc"

      unbind %
      bind | split-window -h -c "#{pane_current_path}"
      unbind '"'
      bind - split-window -v -c "#{pane_current_path}"

      bind c new-window -c "#{pane_current_path}"

      # Undercurl
      set -g default-terminal "''${TERM}"
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'  # undercurl support
      set -as terminal-overrides ',*:Setulc=\E[58::2::::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d
      ::%p1%{255}%&%d%;m'  # underscore colours - needs tmux-3.0

      # vim-like keybinds
      setw -g mode-keys vi
      bind-key h resize-pane -L 5
      bind-key j resize-pane -D 5
      bind-key k resize-pane -U 5
      bind-key l resize-pane -R 5
      bind-key m resize-pane -Z 5

      bind-key H resize-pane -L 15
      bind-key J resize-pane -D 15
      bind-key K resize-pane -U 15
      bind-key L resize-pane -R 15

      unbind -T copy-mode-vi MouseDragEnd1Pane

      # Plugins
      set -g @plugin 'tmux-plugins/tpm'
      set -g @plugin 'christoomey/vim-tmux-navigator'
      set -g @plugin 'tmux-plugins/tmux-sensible'
      set -g @plugin 'janoamaral/tokyo-night-tmux'

      set -g status-position top

      run '~/.tmux/plugins/tpm/tpm
    '';
  };
  programs.alacritty.enable = true;
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
