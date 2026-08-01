{ config, pkgs, ... }: {
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      # Hyprland 支持 zwp_input_method_v2：Wayland 原生 GTK 应用走
      # text-input-v3（fcitx5 官方推荐的单一链路），X11/XWayland 的 GTK
      # 应用由 gtk-3.0/gtk-4.0 settings.ini 的 gtk-im-module=fcitx 兜底
      # （见 modules/home/gtk.nix）。Qt 仍需 QT_IM_MODULE=fcitx。
      waylandFrontend = true;
      addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons
        fcitx5-rime
        fcitx5-material-color
        fcitx5-gtk
        qt6Packages.fcitx5-qt
      ];
      settings = {
        # 输入法 profile（声明式基线；注意 ~/.config/fcitx5/profile
        # 优先于 /etc/xdg/fcitx5/profile，首次迁移需删除旧用户 profile，
        # 见 records/nixos-input-method-review.org）。
        inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "pinyin";
          };
          "Groups/0/Items/0" = {
            Name = "keyboard-us";
            Layout = "";
          };
          "Groups/0/Items/1" = {
            Name = "pinyin";
            Layout = "";
          };
          "Groups/0/Items/2" = {
            Name = "rime";
            Layout = "";
          };
          GroupOrder."0" = "Default";
        };
        # addon conf（从 dotfiles/fcitx5/*.conf 迁移而来）。
        # rime-data 无需显式添加：fcitx5-rime 已内置（rimeDataPkgs 默认）。
        addons = {
          classicui.globalSection.Theme = "Material-Color-deepPurple";
          pinyin.globalSection = {
            ShuangpinProfile = "Ziranma";
            ShowShuangpinMode = "True";
            PageSize = "10";
            SpellEnabled = "True";
            SymbolsEnabled = "True";
            ChaiziEnabled = "True";
            ExtBEnabled = "True";
            StrokeCandidateEnabled = "True";
            CloudPinyinEnabled = "True";
            CloudPinyinIndex = "2";
            CloudPinyinAnimation = "True";
            KeepCloudPinyinPlaceHolder = "False";
            PreeditMode = "Composing pinyin";
            PreeditCursorPositionAtBeginning = "True";
            PinyinInPreedit = "False";
          };
        };
      };
    };
  };
}
