{
  home,
  config,
  pkgs,
  ...
}:
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "gsettings set org.gnome.desktop.interface cursor-theme '${config.home.pointerCursor.name}'"
      "gsettings set org.gnome.desktop.interface cursor-size ${toString home.pointerCursor.size}"
    ];
  };

  xdg.portal = {
    config = {
      hyprland.preferred = [
        "hyprland"
        "gtk"
      ];
    };
  };
}
