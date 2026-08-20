{ config, pkgs, ... }: {
  xdg.portal = {
    enable = true;
    # programs.hyprland.enable 会带上 xdg-desktop-portal-hyprland。
    # 这里只补 gtk（文件选择）。不要再把 hyprland portal 加进 extraPortals，
    # 否则两个同名 user unit 会撞车。
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common.default = [ "hyprland" "gtk" ];
      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
      };
    };
  };
}
