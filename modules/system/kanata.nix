{ config, pkgs, ... }: {
  services.kanata = {
    enable = true;
    keyboards = {
      internalKeyboard = {
        config = ''
          (defsrc caps)
          (deflayer default lctl)
        '';
      };
    };
  };
}
