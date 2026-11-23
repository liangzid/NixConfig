# ======================================================================
# WAYBAR
#
# 1. 提供 Hyprland 顶栏、工作区导航和系统状态组件。
# 2. 调用链：Home Manager → Waybar 0.16 IPC::dispatch → Hyprland Lua IPC。
# 3. 修改历史：2026-08-30 修复 Lua 工作区点击；工作区按钮改为直角风格。
#              2026-09-27 新增显示器组件（tooltip 详情 + nwg-displays 入口）
#              与电池组件。
#              2026-11-18 删除过期 0.15 overlay，改用上游 PR #5013。
#              2026-11-23 merge：保留电池/显示器组件，不保留 overlay。
#
#     Author: Zi Liang <zi1415926.liang@connect.polyu.hk>
#     Copyright © 2026, Zi Liang, all rights reserved.
#     Created: 30 August 2026
# ======================================================================

{ config, pkgs, ... }:

let
  # 显示器组件的信息脚本：从 hyprctl 取所有显示器的分辨率/位置/缩放，
  # 输出 waybar custom 模块约定的 JSON（text 显示各屏分辨率，tooltip
  # 显示完整细节）。hyprctl 用 PATH 上的（仅在 Hyprland 会话内有意义），
  # jq 用 store 全路径（系统 PATH 不保证有）。
  displaysInfo = pkgs.writeShellScript "waybar-displays-info.sh" ''
    MONITORS=$(hyprctl -j monitors 2>/dev/null) || {
      echo '{"text": "󰍺 ?", "tooltip": "hyprctl 不可用"}'
      exit 0
    }
    echo "$MONITORS" | ${pkgs.jq}/bin/jq -c '
      {
        text: ("󰍺 " + ([.[] | "\(.width)×\(.height)"] | join(" + "))),
        tooltip: (
          ([.[] |
            "\(.name)  \(.width)×\(.height)@\(.refreshRate * 10 | round / 10)Hz  位置 \(.x),\(.y)  缩放 \(.scale)" +
            (if .focused then "  ● 焦点" else "" end) +
            (if .dpmsStatus == false then "  [休眠]" else "" end)
          ] | join("\n")) + "\n\n左键打开 nwg-displays 细调配置"
        )
      }'
    # 注：不使用 hyprctl 的 disabled 字段——0.56 的 JSON 里它对点亮中的
    # 屏幕也误报 true（疑似 Lua 迁移期序列化问题），语义不可靠。
  '';
in
{
  home.packages = [ pkgs.nwg-displays ];

  programs.waybar = {
    enable = true;
    settings = [{
      layer = "top";
      position = "top";
      height = 40;
      margin-top = 6;
      margin-left = 8;
      margin-right = 8;
      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "hyprland/window" ];
      modules-right = [ "network" "group/resources" "pulseaudio" "battery" "custom/displays" "clock" "tray" ];

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
        format-muted = "  muted";
        format-icons.default = [ "" "" "" ];
        on-click = "pavucontrol";
        on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        scroll-step = 5;
        tooltip = true;
      };

      # REVIEW: 电量组件阈值（warning 30% / critical 15%）可按习惯调整。
      # 无电池的机器上 waybar 自动隐藏本模块，配置可跨机器复用。
      "battery" = {
        interval = 30;
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = "󰚥 {capacity}%";
        format-icons = [ "󰁺" "󰁼" "󰁾" "󰁿" "󰂀" "󰂂" ];
        tooltip-format = "{timeTo}";
      };

      # 显示器组件：text 显示各屏分辨率，tooltip 显示名称/分辨率@刷新率/
      # 位置坐标/缩放/焦点状态；左键打开 nwg-displays 做持久化细调。
      "custom/displays" = {
        format = "{}";
        return-type = "json";
        interval = 10;
        exec = "${displaysInfo}";
        on-click = "${pkgs.nwg-displays}/bin/nwg-displays";
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
      #battery,
      #custom-displays,
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
          border-radius: 0;
          transition: all 0.2s ease;
      }

      #workspaces button.active {
          background: rgba(122, 162, 247, 0.88);
          color: #1a1b26;
          box-shadow: none;
      }

      #workspaces button:hover {
          color: #ffffff;
          background: rgba(122, 162, 247, 0.28);
          box-shadow: none;
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
      #battery,
      #custom-displays,
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
      #battery { color: #9ece6a; }
      /* REVIEW: 电量状态色（正常绿/警告橙/危急红），充电时保持绿色。 */
      #battery.warning:not(.charging) { color: #e0af68; }
      #battery.critical:not(.charging) { color: #f7768e; }
      #custom-displays { color: #e0af68; }
      #clock { color: #c0caf5; }
      #tray { padding: 0 10px; }

      #network:hover,
      #resources:hover,
      #pulseaudio:hover,
      #battery:hover,
      #custom-displays:hover,
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
