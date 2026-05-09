{ config, pkgs, ... }: {
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    # Close source
    open = false;

    # Stable version
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # For Hyprland
    modesetting.enable = true;
    powerManagement.enable = true;
  };
}
