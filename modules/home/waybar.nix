{ config, pkgs, ... }: {
  programs.waybar = {
    enable = true;
    settings = [{
      layer = "top";
      position = "top";
      height = 30;
      modules-left = [ "hyprland/workspaces" "hyprland/mode" ];
      modules-center = [ "hyprland/window" ];
      modules-right = [ "network" "cpu" "memory" "pulseaudio" "clock" "clock#date" "tray" ];

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

      "pulseaudio" = {
        format = "{icon} {volume}%";
        format-muted = "  muted";
        format-icons.default = [ "" "" "" ];
        on-click = "pavucontrol";
        on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        scroll-step = 5;
        tooltip = true;
      };

      "clock" = {
        interval = 1;
        format = "  {:%H:%M:%S}";
        tooltip-format = "{:%Y-%m-%d %A}";
      };

      # 与 clock 拆开：悬停月历，滚轮翻月，左键打开 gnome-calendar，右键切年/月视图。
      "clock#date" = {
        interval = 60;
        format = "󰃭  {:%Y-%m-%d %a}";
        tooltip-format = "<tt>{calendar}</tt>";
        calendar = {
          mode = "month";
          weeks-pos = "right";
          on-scroll = 1;
          format = {
            months = "<span color='#7aa2f7'><b>{}</b></span>";
            days = "<span color='#c0caf5'>{}</span>";
            weeks = "<span color='#3b4261'><b>W{}</b></span>";
            weekdays = "<span color='#7dcfff'><b>{}</b></span>";
            today = "<span color='#bb9af7'><b><u>{}</u></b></span>";
          };
        };
        actions = {
          on-click-right = "mode";
          on-scroll-up = "shift_up";
          on-scroll-down = "shift_down";
        };
        on-click = "${pkgs.gnome-calendar}/bin/gnome-calendar";
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

      #cpu, #memory, #network, #pulseaudio, #clock, #tray {
          margin: 6px 2px;
          padding: 0 12px;
          background: rgba(26, 27, 38, 0.55);
          border: 1px solid rgba(122, 162, 247, 0.35);
          border-radius: 10px;
      }
      #cpu { color: #7aa2f7; }
      #memory { color: #bb9af7; }
      #network { color: #7dcfff; }
      #pulseaudio { color: #9ece6a; }
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
