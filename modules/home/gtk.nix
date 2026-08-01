{ config, pkgs, ... }: {
  gtk = {
    enable = true;
    # waylandFrontend=true 后 GTK_IM_MODULE 不再全局设置；X11/XWayland
    # 的 GTK 应用通过 settings.ini 指定 fcitx 模块，Wayland 原生 GTK
    # 应用则走 text-input-v3。
    gtk3.extraConfig = {
      "gtk-im-module" = "fcitx";
    };
    gtk4.extraConfig = {
      "gtk-im-module" = "fcitx";
    };
    theme = {
      name = "Juno";
      package = pkgs.juno-theme;
    };

    iconTheme = {
      name = "BeautyLine";
      package = pkgs.beauty-line-icon-theme;
    };

    cursorTheme = {
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
