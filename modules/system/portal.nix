{ config, pkgs, ... }: {
  xdg.portal = {
    enable = true;
    # 注意：programs.hyprland.enable（nixpkgs 模块）会自动添加
    # xdg-desktop-portal-hyprland（portalPackage）和 xdg-desktop-portal-gtk，
    # 这里不要再重复添加，否则两个不同构建的 portal 包会提供同名
    # xdg-desktop-portal-hyprland.service，导致 user-units 构建失败。
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };
}
