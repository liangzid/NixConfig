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
      sansSerif = [ "FiraCode Nerd Font" "Sarasa Gothic SC" "Noto Sans CJK SC" ];
      serif = [ "FiraCode Nerd Font" "Sarasa Gothic SC" "Noto Serif CJK SC" ];
    };
  };
}
