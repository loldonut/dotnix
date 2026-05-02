{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Boot Loader
  boot.loader =
    if (config.bootloader.useGrub == true) then
      {
        systemd-boot.enable = false;
        efi.canTouchEfiVariables = true;
        efi.efiSysMountPoint = "/boot";
        grub.enable = true;
        grub.device = "nodev";
        grub.efiSupport = true;
        grub.useOSProber = true;
      }
    else
      {
        systemd-boot.enable = true;
      };
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
