{ config, pkgs, ... }: {
  services.kanata = {
    enable = true;
    keyboards = {
      internalKeyboard = {
        # Pin the i8042 AT keyboard. After resume the event node can
        # change; this by-path symlink is what the rebind script restores.
        # --nodelay: the default 2s startup sleep would eat lock-screen
        # keypresses right after lid-open. --wait-device-ms: the atkbd
        # bind may not be ready the instant kanata restarts.
        devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ];
        extraArgs = [ "--nodelay" "--wait-device-ms" "500" ];
        extraDefCfg = ''
          process-unmapped-keys yes
        '';
        config = ''
          (defsrc caps)
          (deflayer default lctl)
        '';
      };
    };
  };
}
