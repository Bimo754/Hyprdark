-- ==============================================================================
-- Hyprdark - Modular Lua Configuration for Hyprland
-- Minimal, engineering-grade setup tailored for daily productivity.
-- ==============================================================================

------------------
---- MONITORS ----
------------------
hl.monitor({
    output   = "eDP-1",
    mode     = "2560x1600@165",
    position = "auto",
    scale    = 1.6,
})

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

---------------------
---- MY PROGRAMS ----
---------------------
local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "rofi -show drun -theme ~/.config/rofi/theme.rasi"
local browser     = "brave"
local editor      = "subl"

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function ()
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
    hl.exec_cmd("~/.config/hypr/scripts/quickshell-launcher.sh")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprpaper")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        gaps_in  = 6,
        gaps_out = 12,
        border_size = 2,

        col = {
            active_border   = "rgba(ffffffee)",
            inactive_border = "rgba(255, 255, 255, 0.12)",
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding = 12,

        active_opacity   = 0.98,
        inactive_opacity = 0.92,

        shadow = {
            enabled      = true,
            range        = 28,
            render_power = 4,
            color        = 0x55000000,
        },

        blur = {
            enabled    = true,
            size       = 6,
            passes     = 3,
            vibrancy   = 0.1696,
            contrast   = 0.95,
            brightness = 0.85,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Industrial Easing Curves
hl.curve("cyberSnap",  { type = "bezier", points = { {0.05, 0.95}, {0.1, 1.0} } })
hl.curve("appleFluid", { type = "bezier", points = { {0.16, 1.0},  {0.3, 1.0} } })
hl.curve("linear",     { type = "bezier", points = { {0, 0},       {1, 1}     } })

hl.animation({ leaf = "global",        enabled = true, speed = 8,   bezier = "cyberSnap" })
hl.animation({ leaf = "border",        enabled = true, speed = 4,   bezier = "linear" })
hl.animation({ leaf = "windows",       enabled = true, speed = 3.5, bezier = "cyberSnap",  style = "popin 85%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 2.0, bezier = "cyberSnap",  style = "popin 85%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 2.0, bezier = "cyberSnap" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.8, bezier = "cyberSnap" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 3.5, bezier = "appleFluid", style = "slidefade 20%" })

----------------
----  MISC  ----
----------------
hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        background_color        = 0x0d0e15,
        focus_on_activate       = true,
    },
    dwindle = {
        preserve_split = true,
    },
})

---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout  = "us",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
            tap_to_click   = true,
            disable_while_typing = true,
        },
    },
})

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

-- Core Launchers
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SPACE",  hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + S",      hl.dsp.exec_cmd(editor))

-- Window Controls
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Focus Navigation (Vim + Arrows)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + H",     hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L",     hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K",     hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J",     hl.dsp.focus({ direction = "down" }))

-- Window Movement in Tiling (Vim + Arrows)
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + H",     hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L",     hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K",     hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J",     hl.dsp.window.move({ direction = "down" }))

-- Workspaces 1-5
for i = 1, 5 do
    hl.bind(mainMod .. " + " .. i,             hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i,     hl.dsp.window.move({ workspace = i }))
end

-- Relative Workspace Navigation (CTRL + ALT + Left/Right)
hl.bind("CTRL + ALT + left", function()
    local ws = hl.get_active_workspace()
    if ws and ws.id and ws.id > 1 then
        hl.dispatch(hl.dsp.focus({ workspace = ws.id - 1 }))
    end
end)

hl.bind("CTRL + ALT + right", function()
    local ws = hl.get_active_workspace()
    if ws and ws.id and ws.id < 5 then
        hl.dispatch(hl.dsp.focus({ workspace = ws.id + 1 }))
    end
end)

-- Move Focused Window to Relative Workspace (CTRL + ALT + SHIFT + Left/Right)
hl.bind("CTRL + ALT + SHIFT + left", function()
    local ws = hl.get_active_workspace()
    if ws and ws.id and ws.id > 1 then
        hl.dispatch(hl.dsp.window.move({ workspace = ws.id - 1 }))
    end
end)

hl.bind("CTRL + ALT + SHIFT + right", function()
    local ws = hl.get_active_workspace()
    if ws and ws.id and ws.id < 5 then
        hl.dispatch(hl.dsp.window.move({ workspace = ws.id + 1 }))
    end
end)

-- Screenshots (Grim + Slurp + Swappy)
hl.bind("PRINT", hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | swappy -f -"))

-- Hardware Audio & Backlight
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl set +5%"),                         { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl set 5%-"),                         { locked = true, repeating = true })

-- Session & Security
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("hyprctl dispatch exit"))

-- Mouse interactions
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
hl.window_rule({
    name  = "dialogs-float",
    match = { class = "^(pavucontrol|nm-connection-editor|blueman-manager|swappy|hyprpolkitagent)$" },
    float = true,
})

