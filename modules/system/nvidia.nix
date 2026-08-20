{ config, pkgs, ... }: {
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    # Keep proprietary module until open=true is validated on a non-critical rebuild.
    # (open=true was tried earlier; boot emergency on 2026-08-20 was disk UUID, not this,
    # but do not flip open again without a known-good generation ready.)
    open = false;

    # Stable version
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # For Hyprland
    modesetting.enable = true;
    powerManagement.enable = true;
  };
}
