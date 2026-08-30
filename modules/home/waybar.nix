# ======================================================================
# WAYBAR
#
# 1. 提供 Hyprland 顶栏、工作区导航和系统状态组件。
# 2. 调用链：Home Manager → patched Waybar → Hyprland Lua IPC。
# 3. 修改历史：2026-08-30 修复 Lua 工作区点击并开始统一视觉层次。
#
#     Author: Zi Liang <zi1415926.liang@connect.polyu.hk>
#     Copyright © 2026, Zi Liang, all rights reserved.
#     Created: 30 August 2026
# ======================================================================

{ config, pkgs, ... }:

let
  # REVIEW: Waybar 0.15 尚未支持 Hyprland 0.56 的 Lua workspace dispatch。
  waybarWithHyprlandLuaWorkspaceClick = pkgs.waybar.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      ../../patches/waybar-hyprland-lua-workspace-click.patch
    ];
  });
in
{
  programs.waybar = {
    enable = true;
    package = waybarWithHyprlandLuaWorkspaceClick;
    settings = [{
      layer = "top";
      position = "top";
      height = 40;
      margin-top = 6;
      margin-left = 8;
      margin-right = 8;
      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "hyprland/window" ];
      modules-right = [ "network" "group/resources" "pulseaudio" "clock" "tray" ];

      "group/resources" = {
        orientation = "inherit";
        modules = [ "cpu" "memory" ];
      };

      "cpu" = {
        format = "  {usage}%";
        interval = 10;
      };

      "memory" = {
        format = "  {percentage}%";
        interval = 30;
      };

      "network" = {
        format-wifi = "󰤨  {signalStrength}%";
        format-ethernet = "󰈀  wired";
        format-disconnected = "󰤭  offline";
        tooltip-format = "{ifname}\n{ipaddr}/{cidr}";
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
        interval = 60;
        format = "  {:%H:%M}";
        format-alt = "󰃭  {:%a · %d %b}";
        tooltip-format = "<span size='large'><b>{:%A, %d %B %Y}</b></span>\n<tt>{calendar}</tt>";
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
        sort-by = "number";
        format = "{id}";
        persistent-workspaces = {
          "*" = 10;
        };
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
          color: #c0caf5;
      }

      /* REVIEW: 所有胶囊共用同一玻璃材质；区别只由强调色表达。 */
      #workspaces,
      #window,
      #network,
      #resources,
      #pulseaudio,
      #clock,
      #tray {
          margin: 3px 3px;
          background-image: linear-gradient(
              135deg,
              rgba(36, 40, 59, 0.82),
              rgba(26, 27, 38, 0.68)
          );
          border: 1px solid rgba(192, 202, 245, 0.18);
          border-radius: 14px;
          box-shadow:
              inset 0 1px rgba(255, 255, 255, 0.08),
              0 4px 12px rgba(0, 0, 0, 0.28);
      }

      #workspaces {
          padding: 3px 4px;
      }

      #workspaces button {
          margin: 1px 2px;
          padding: 0 9px;
          color: rgba(192, 202, 245, 0.72);
          background: transparent;
          border-radius: 10px;
          transition: all 0.2s ease;
      }

      #workspaces button.active {
          background-image: linear-gradient(135deg, #7dcfff, #7aa2f7 48%, #bb9af7);
          color: #1a1b26;
          box-shadow:
              inset 0 1px rgba(255, 255, 255, 0.35),
              0 0 10px rgba(122, 162, 247, 0.55);
      }

      #workspaces button:hover {
          color: #ffffff;
          background-image: linear-gradient(
              135deg,
              rgba(122, 162, 247, 0.38),
              rgba(187, 154, 247, 0.28)
          );
          box-shadow: inset 0 1px rgba(255, 255, 255, 0.16);
      }

      #workspaces button.empty:not(.active) {
          color: rgba(86, 95, 137, 0.78);
      }

      #window {
          padding: 0 16px;
          color: #c0caf5;
      }

      #network,
      #pulseaudio,
      #clock {
          padding: 0 13px;
      }

      #resources {
          padding: 0 5px;
      }

      #cpu,
      #memory {
          padding: 0 8px;
          background: transparent;
      }

      #cpu { color: #7dcfff; }
      #memory { color: #bb9af7; }
      #network { color: #7dcfff; }
      #pulseaudio { color: #9ece6a; }
      #clock { color: #c0caf5; }
      #tray { padding: 0 10px; }

      #network:hover,
      #resources:hover,
      #pulseaudio:hover,
      #clock:hover {
          border-color: rgba(125, 207, 255, 0.55);
          box-shadow:
              inset 0 1px rgba(255, 255, 255, 0.12),
              0 0 12px rgba(122, 162, 247, 0.30);
      }

      tooltip {
          padding: 10px;
          background-image: linear-gradient(135deg, #24283b, #1a1b26);
          border: 1px solid rgba(122, 162, 247, 0.55);
          border-radius: 12px;
          box-shadow: 0 8px 24px rgba(0, 0, 0, 0.45);
      }

      tooltip label {
          color: #c0caf5;
      }
     '';
  };
}
