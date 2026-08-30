-- Hyprland Lua 配置（Hyprland >= 0.55，2026-08-02 由 hyprland.conf 迁移）
-- API 参考：https://wiki.hypr.land/Configuring/Start/

--------------------
---- MONITORS ----
--------------------
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1.5,
})

--------------------
---- ENVIRONMENT ----
--------------------
-- 光标主题与尺寸（GTK 侧由 gtk.nix 的 settings.ini 指定，这里覆盖 XWayland/Qt）
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Numix-Cursor")
-- 仅 Hyprland 会话：不要写进 home.sessionVariables（TTY/SSH 会误带上）
hl.env("GDK_BACKEND", "wayland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")

local lock_cmd = "swaylock -f -S --effect-blur 7x5 --effect-vignette 0.3:0.4"

--------------------
---- AUTOSTART ----
--------------------
-- 关键：同步环境变量到 dbus 和 systemd，解决 GTK 软件启动慢或权限问题
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP GDK_BACKEND XDG_SESSION_TYPE LIBVA_DRIVER_NAME GBM_BACKEND __GLX_VENDOR_LIBRARY_NAME")
    hl.exec_cmd("waybar")
    hl.exec_cmd("dunst")
    hl.exec_cmd("udiskie -t")
    hl.exec_cmd("fcitx5 -d --replace")
    hl.exec_cmd("bash $HOME/scripts/wallpaper-picker.sh")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Auto-lock on idle is intentionally disabled. Display still powers off
    -- after 600s, and the screen is still locked on suspend / lid close.
    -- 注意：0.56 起 hyprctl dispatch 只接受 Lua 表达式，不能用旧的 `dpms off`。
    hl.exec_cmd([[
swayidle -w timeout 600 "hyprctl dispatch 'hl.dsp.dpms({ action = \"off\" })'" resume "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'" before-sleep ']] .. lock_cmd .. [[']])
end)

--------------------
---- LAYER RULES ----
--------------------
-- 玻璃拟态：让 waybar / wofi / dunst 后面的内容模糊
hl.layer_rule({ match = { namespace = "waybar" }, blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "wofi" },   blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "dunst" },  blur = true, ignore_alpha = 0.5 })

----------------------
---- WINDOW RULES ----
----------------------
-- 终端保持清晰可读：透明背景直接透出壁纸，不走 compositor blur。
hl.window_rule({ match = { class = "com.mitchellh.ghostty" }, no_blur = true })

-- 聚焦窗口仅略加粗边框，不再使用渐变高亮。
hl.window_rule({ match = { focus = true }, border_size = 2 })

--------------------
---- LOOK AND FEEL ----
--------------------
hl.config({
    general = {
        gaps_in     = 4,
        gaps_out    = 3,
        border_size = 1,
        col = {
            active_border   = "rgba(7aa2f799)",
            inactive_border = "rgba(565f7388)",
        },
    },

    decoration = {
        rounding         = 0,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 8,
            render_power = 2,
            color        = "rgba(00000055)",
        },

        blur = {
            enabled           = true,
            size              = 6,
            passes            = 3,
            vibrancy          = 0.2,
            new_optimizations = true,
            xray              = true,
            ignore_opacity    = true,
        },

        glow = {
            enabled = false,
        },

        motion_blur = {
            enabled = true,
            samples = 7,
        },
    },

    animations = {
        enabled = true,
    },

    misc = {
        disable_hyprland_logo = true,
    },

    xwayland = {
        force_zero_scaling = true,
    },
})

--------------------
---- ANIMATIONS ----
--------------------
hl.curve("easeOutBack",  { type = "bezier", points = { { 0.34, 1.56 }, { 0.64, 1 } } })
hl.curve("easeOutCubic", { type = "bezier", points = { { 0.33, 1 },    { 0.68, 1 } } })
hl.curve("linear",       { type = "bezier", points = { { 0, 0 },       { 1, 1 } } })

local function set_animation(leaf, speed, bezier, style)
    hl.animation({ leaf = leaf, enabled = true, speed = speed, bezier = bezier, style = style })
end

-- speed 单位 = 0.1s；数值越大动画时间越长
set_animation("global",         8,  "easeOutCubic")
set_animation("windows",        12, "easeOutBack",  "popin 85%")
set_animation("windowsIn",      12, "easeOutBack",  "popin 85%")
set_animation("windowsOut",     8,  "easeOutCubic", "popin 90%")
set_animation("windowsMove",    8,  "easeOutCubic")
set_animation("border",         10, "easeOutCubic")
set_animation("fade",           8,  "easeOutCubic")
set_animation("fadeIn",         8,  "easeOutCubic")
set_animation("fadeOut",        7,  "easeOutCubic")
set_animation("fadeSwitch",     7,  "easeOutCubic")
set_animation("fadeShadow",     7,  "easeOutCubic")
set_animation("fadeGlow",       7,  "easeOutCubic")
set_animation("fadeLayers",     7,  "easeOutCubic")
set_animation("fadeLayersIn",   7,  "easeOutCubic")
set_animation("fadeLayersOut",  7,  "easeOutCubic")
set_animation("fadePopupsIn",   7,  "easeOutCubic")
set_animation("fadePopupsOut",  7,  "easeOutCubic")
set_animation("layers",         8,  "easeOutCubic", "fade")
set_animation("layersIn",       8,  "easeOutCubic", "fade")
set_animation("layersOut",      7,  "easeOutCubic", "fade")
set_animation("workspaces",     12, "easeOutCubic", "slidefade 20%")
set_animation("workspacesIn",   9,  "easeOutCubic", "slidefade 20%")
set_animation("workspacesOut",  8,  "easeOutCubic", "slidefade 20%")
set_animation("specialWorkspace", 9, "easeOutBack", "slidefade")
set_animation("zoomFactor",     8,  "easeOutCubic")

--------------------
---- LOCK / IDLE ----
--------------------
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd(lock_cmd), { locked = true })

--------------------
---- VARIABLES ----
--------------------
local main_mod = "SUPER"
local terminal = "ghostty"
local menu     = "wofi --show drun"

--------------------
---- KEYBINDINGS ----
--------------------
-- For moving focus
hl.bind(main_mod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(main_mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(main_mod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(main_mod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind(main_mod .. " + Tab",   hl.dsp.window.cycle_next())

-- K for kill window, V for floating, F for Fullscreen (and back),
-- T for terminal, X for menu (like emacs), E for Explorer
hl.bind(main_mod .. " + K", hl.dsp.window.close())
hl.bind(main_mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
-- Super+V 仍是浮动；历史剪贴板用 Super+Shift+V，避免抢键。
hl.bind(main_mod .. " + SHIFT + V", hl.dsp.exec_cmd("bash $HOME/scripts/clipboard-hist.sh"))
hl.bind(main_mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind("CTRL + ALT + T",   hl.dsp.exec_cmd(terminal))
hl.bind(main_mod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(main_mod .. " + X", hl.dsp.exec_cmd(menu))
hl.bind(main_mod .. " + E", hl.dsp.exec_cmd("nautilus"))

-- Q for quit.
hl.bind(main_mod .. " + Q", hl.dsp.exec_cmd(
    "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- Swap between windows
hl.bind(main_mod .. " + ALT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(main_mod .. " + ALT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(main_mod .. " + ALT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(main_mod .. " + ALT + down",  hl.dsp.window.move({ direction = "down" }))

-- For resize
hl.bind(main_mod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("right",  hl.dsp.window.resize({ x = 10,  y = 0,  relative = true }), { repeating = true })
    hl.bind("left",   hl.dsp.window.resize({ x = -10, y = 0,  relative = true }), { repeating = true })
    hl.bind("up",     hl.dsp.window.resize({ x = 0,   y = -10, relative = true }), { repeating = true })
    hl.bind("down",   hl.dsp.window.resize({ x = 0,   y = 10,  relative = true }), { repeating = true })

    hl.bind("L", hl.dsp.window.resize({ x = 10,  y = 0,  relative = true }), { repeating = true })
    hl.bind("H", hl.dsp.window.resize({ x = -10, y = 0,  relative = true }), { repeating = true })
    hl.bind("K", hl.dsp.window.resize({ x = 0,   y = -10, relative = true }), { repeating = true })
    hl.bind("J", hl.dsp.window.resize({ x = 0,   y = 10,  relative = true }), { repeating = true })

    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
end)

-- Switching between workspaces (SUPER+0 = workspace 10，与旧 hyprlang 语义一致)
for i = 1, 10 do
    local key = i % 10
    hl.bind(main_mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Super + L (Lock)
hl.bind(main_mod .. " + L", hl.dsp.exec_cmd(lock_cmd))

--------------------
---- AUDIO ----
--------------------
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPause",       hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"))

--------------------
---- SCREENSHOTS ----
--------------------
hl.bind("Print",           hl.dsp.exec_cmd("bash $HOME/scripts/screenshot.sh area"))
hl.bind("XF86Calculator",  hl.dsp.exec_cmd("bash $HOME/scripts/screenshot.sh area"))
hl.bind("CTRL + Print",    hl.dsp.exec_cmd("bash $HOME/scripts/screenshot.sh screen"))
hl.bind("CTRL + XF86Calculator", hl.dsp.exec_cmd("bash $HOME/scripts/screenshot.sh screen"))
