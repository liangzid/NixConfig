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
          font-family: "FiraCode Nerd Font", "Sarasa UI SC";
          font-size: 13px;
          border: none;
          border-radius: 0;
          min-height: 0;
      }
      window#waybar {
          background: transparent;
          border: none;
          color: #c0caf5;
      }
      #workspaces {
          margin: 6px 4px;
          padding: 2px 4px;
          background: rgba(26, 27, 38, 0.55);
          border: 1px solid rgba(122, 162, 247, 0.35);
          border-radius: 10px;
      }
      #workspaces button {
          padding: 0 8px;
          color: #7aa2f7;
          border-radius: 8px;
          transition: all 0.2s ease;
      }
      #workspaces button.active {
          background: linear-gradient(135deg, #7aa2f7, #bb9af7);
          color: #1a1b26;
      }
      #workspaces button:hover {
          color: #7dcfff;
          background: rgba(122, 162, 247, 0.2);
      }
      #window {
          margin: 6px 4px;
          padding: 0 12px;
          background: rgba(26, 27, 38, 0.55);
          border: 1px solid rgba(122, 162, 247, 0.35);
          border-radius: 10px;
          color: #c0caf5;
      }

      #cpu, #memory, #network, #battery, #clock, #tray {
          margin: 6px 2px;
          padding: 0 12px;
          background: rgba(26, 27, 38, 0.55);
          border: 1px solid rgba(122, 162, 247, 0.35);
          border-radius: 10px;
      }
      #cpu { color: #7aa2f7; }
      #memory { color: #bb9af7; }
      #network { color: #7dcfff; }
      #battery { color: #9ece6a; }
      #battery.warning { color: #e0af68; }
      #battery.critical { color: #f7768e; }
      #clock { color: #c0caf5; }
      #tray { padding: 0 8px; }
      tooltip {
          background-color: #1a1b26;
          border: 1px solid #3b4261;
          border-radius: 8px;
      }
      tooltip label {
          color: #c0caf5;
      }
     '';
  };
}
