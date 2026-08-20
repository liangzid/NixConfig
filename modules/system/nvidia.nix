{ config, pkgs, ... }: {
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    # RTX 4080（Ada）：560+ 驱动应使用开源内核模块。
    open = true;

    # Stable version
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # For Hyprland
    modesetting.enable = true;
    powerManagement.enable = true;
  };
}
