{ config, pkgs, ... }: {
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    maple-mono.truetype
    sarasa-gothic
    corefonts
    vista-fonts
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "FiraCode Nerd Font Mono" "Sarasa Mono SC" "Noto Color Emoji" ];
      # 此前把 FiraCode（等宽代码字体）放在 sans/serif 第一位，导致整个桌面
      # UI 都拿代码字体渲染（fc-match 实测确认）。Sarasa UI SC 的拉丁部分基于
      # Inter、CJK 部分基于思源黑体，中英混排风格统一，适合做界面字体。
      sansSerif = [ "Sarasa UI SC" "Noto Sans CJK SC" ];
      serif = [ "Noto Serif" "Noto Serif CJK SC" ];
    };
  };
}
