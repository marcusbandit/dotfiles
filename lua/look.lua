--------------------------------------------------------------------------------
-- LOOK AND FEEL
--
-- Ported from hyprland/general.conf: the general / decoration / animations /
-- scrolling / master / misc blocks. The input, gestures and cursor blocks that
-- shared that file are not here; they live with the rest of the input config.
--
-- No hex lives in this file. Every colour comes from lua/theme.lua, so a stop
-- is still defined exactly once.
--------------------------------------------------------------------------------

local theme = require("lua.theme")

--------------------------------------------------------------------------------
-- Geometry
--------------------------------------------------------------------------------

--- Base gutter. gaps_in is applied to each side of each window, so the seam
--- between two tiled windows is 2 * gap, and the screen edge is gaps_out. Both
--- are derived from this one number so the seam and the edge stay the same
--- visual width; change `gap` and the whole frame rescales.
local gap = 5

hl.config({
    general = {
        gaps_in  = gap,
        gaps_out = gap * 2,

        border_size = 2,

        col = {
            -- Greensteel: five stops so the bright one reads as a specular
            -- highlight sliding along a metal edge, not as a two-colour fade.
            -- Palette lives in lua/theme.lua.
            active_border   = theme.border_active,
            inactive_border = theme.border_inactive,
        },

        resize_on_border = false,
        allow_tearing    = false,

        layout = "scrolling",
    },

    decoration = {
        -- G2 / squircle corners: rounding_power is the superellipse exponent
        -- (|x|^p + |y|^p = r^p). p=2 is a plain circular arc (G1, curvature
        -- jumps 0 -> 1/r at the join). p>2 makes curvature go to 0 at the edge,
        -- so the corner is G2-continuous. Radius is bumped to keep the apparent
        -- corner size, since a superellipse bites less off the diagonal at the
        -- same r.
        rounding       = 15,
        rounding_power = 4.0,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        dim_special = 0.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = theme.shadow,
        },

        blur = {
            enabled  = true,
            size     = 8,
            passes   = 2,
            vibrancy = 0.1696,
            xray     = true,
            popups   = true,
        },
    },

    animations = {
        -- hyprlang spelled this `enabled = yes, please :)`, which is a joke
        -- value that parses as true. Lua wants the boolean.
        enabled = true,
    },

    scrolling = {
        focus_fit_method = 1,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})

--------------------------------------------------------------------------------
-- Curves
--------------------------------------------------------------------------------

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}   } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}   } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}      } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1.0} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}    } })
hl.curve("easeOutExpo",    { type = "bezier", points = { {0.19, 1},    {0.22, 1}   } })

--------------------------------------------------------------------------------
-- Animations
--------------------------------------------------------------------------------

hl.animation({ leaf = "global", enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })

-- Rotates the active gradient so the specular stop travels around the window:
-- metal catching a moving light. The number is the period in deciseconds, so
-- higher is slower: 500 = one rotation per 50s, a drift you notice only if you
-- look. Set `enabled = false` for the static highlight instead.
--
-- PORTING LOSS: this cannot be expressed faithfully in Lua. The old line was
-- `animation = borderangle, 1, 500, linear, loop`, and hyprlang honoured the
-- 500 (the live session is running 500 right now). The Lua binding hard-caps
-- speed at 100 (LuaBindingsConfigRules.cpp:416, CLuaConfigFloat(0, 0, 100)),
-- and anything above the cap is a hard config error, not a clamp. So the
-- highlight now completes a rotation every 10s instead of every 50s: it drifts
-- 5x faster than intended. This is a limitation of the Lua binding, not a
-- mistake in the config. If the faster drift is distracting, `enabled = false`
-- gives the static highlight described above rather than a wrong speed.
local BORDERANGLE_PERIOD  = 500 -- deciseconds per rotation, the intended value
local BORDERANGLE_LUA_MAX = 100 -- hard cap in the Lua binding
hl.animation({
    leaf    = "borderangle",
    enabled = true,
    speed   = math.min(BORDERANGLE_PERIOD, BORDERANGLE_LUA_MAX),
    bezier  = "linear",
    style   = "loop",
})

hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutExpo",  style = "slide" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 4.5,  bezier = "easeOutExpo",  style = "slidevert" })
