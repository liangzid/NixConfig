{ config, pkgs, ... }: {
  programs.waybar = {
    enable = true;
    settings = [{
      layer = "top";
      position = "top";
      height = 30;
      modules-left = [ "hyprland/workspaces" "hyprland/mode" ];
      modules-center = [ "hyprland/window" ];
      modules-right = [ "network" "cpu" "memory" "battery" "clock" "tray" ];

      "cpu" = {
        format = "  {usage}%";
        interval = 10;
      };

      "memory" = {
        format = "  {used:0.1f}G";
        interval = 30;
      };

      "network" = {
        format-wifi = "  {essid}";
        format-ethernet = "󰈀  {ifname}";
        format-disconnected = "󰖪  Disconnected";
        tooltip-format = "{ipaddr}/{cidr}";
      };

      "battery" = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = "  {capacity}%";
        format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
      };

      "clock" = {
        format = "  {:%H:%M}";
        format-alt = "󰃭  {:%Y-%m-%d}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };

      "tray" = {
        icon-size = 18;
        spacing = 10;
      };

      "hyprland/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
      };
    }];
    style = ''
      * {
          font-family: "FiraCode Nerd Font", "Sarasa Gothic SC";
          font-size: 13px;
          border: none;
          border-radius: 0;
      }
      window#waybar {
          background: rgba(26,27,38,0.85);
          border-bottom: 2px solid rgba(255, 255, 255, 0.1);
          transition-property: background-color;
          transition-duration: .5s;
          color: #c0caf5;
     }
      #workspaces button {
          padding: 0 5px;
          color: #7aa2f7;
      }
      # workspaces button.active {
          color: #bb9af7;
      }

      #cpu, #memory, #network, #battery, #clock, #tray {
          padding: 0 10px;
          margin: 4px 2px;
          background-color: rgba(255, 255, 255, 0.1);
          border-radius: 8px;
      }
      #cpu { color: #7aa2f7; }
      #memory { color: #bb9af7; }
      #network { color: #7dcfff; }
      #battery { color: #9ece6a; }
      #battery.warning { color: #e0af68; }
      #battery.critical { color: #f7768e; }
      #clock {
          color: #c0caf5;
          background-color: transparent;
      }
     '';
  };
}
