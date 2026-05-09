{ config, pkgs, ... }: {
  programs.foot = {
    enable = true;
    settings = {
      main = {
        dpi-aware = "yes";
        pad = "12x12";
      };
      colors-dark = {
        alpha = "0.9";
        background = "1a1b26";
        foreground = "c0caf5";
      };
    };
  };
}
