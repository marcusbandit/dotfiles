--------------------------------------------------------------------------------
-- WINDOW AND LAYER RULES
--
-- Ported from hyprland/rules.conf, from the GLOBAL RULES section onward. The
-- workspace-to-monitor assignments that opened that file are not here; they
-- live with the outputs in lua/monitors.lua.
--
-- Reference: https://wiki.hypr.land/Configuring/Window-Rules/
--
-- No hex lives in this file. The floating and pinned border colours come from
-- lua/theme.lua, so a stop is still defined exactly once.
--------------------------------------------------------------------------------

local theme = require("lua.theme")

--------------------------------------------------------------------------------
-- Common sizes
--
-- The point of these is that rules share one number rather than each carrying
-- its own: change the popup size once and every popup follows. That is why they
-- stay named constants even where only one rule currently uses them; inlining
-- the numbers would throw the shared definition away.
--------------------------------------------------------------------------------

local popup_width           = 880
local popup_height          = 652
local dialog_width          = 800
local dialog_height         = 600

-- No rule uses these, and none did in the old config either. Kept so a terminal
-- float rule can come back without re-picking the numbers.
local terminal_float_width  = 1350
local terminal_float_height = 900

--------------------------------------------------------------------------------
-- GLOBAL RULES
--------------------------------------------------------------------------------

-- Suppress maximize events for all windows (prevents apps from forcing maximize).
-- NOTE: suppress_event values are validated at runtime, not at config-parse
-- time, so --verify-config will happily accept a typo here. "maximize" is the
-- correct spelling; the full set is fullscreen | maximize | activate |
-- activatefocus | fullscreenoutput | x11configurerequest.
hl.window_rule({
    name           = "global-suppress-maximize",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Give every ordinary window the ordinary corner radius.
--
-- This rule exists because decoration.rounding in lua/look.lua is NOT the
-- window radius: it is the Android Emulator's bezel, because Hyprland caps the
-- per-window rounding rule at 20 and only the global is uncapped. So the big
-- number is the global and this rule demotes everything else back down. Full
-- reasoning sits next to the numbers in lua/theme.lua.
--
-- "negative:" is Hyprland's own inversion prefix on a match value (RE2 has no
-- lookahead, so `^(?!Emulator)` would NOT work here). It also matches a window
-- with no class at all, since an empty string fails ^(Emulator)$ and the
-- inversion then passes, which is what we want: an unclassed window is an
-- ordinary window.
--
-- Later rules override earlier ones for the same effect, so this sits at the
-- top and the per-app rounding rules further down (mpv, Sober) still win.
hl.window_rule({
    name     = "global-rounding",
    match    = { class = "negative:^(Emulator)$" },
    rounding = theme.rounding.window,
})

--------------------------------------------------------------------------------
-- VISUAL / BORDER RULES
--
-- Border colors. Different metals rather than different hues, so floating and
-- pinned still read as part of the greensteel set: mint for floating, brass
-- for pinned. Palette in lua/theme.lua.
--
-- WHY THE STRING CONCATENATION, it is not a mistake: the old rules set an
-- ACTIVE and an INACTIVE border colour in one go
-- (`border_color <active> <inactive>`). In Lua that two-colour form is
-- expressible ONLY as a single space-separated string. The table form
-- `{ colors = { active, inactive } }` looks tidier but means something else
-- entirely: it stringifies with a trailing angle, so Hyprland reads it as a
-- two-stop GRADIENT painted on the ACTIVE border, and the inactive border is
-- left unset. There is no separate inactive_border_color window-rule field.
-- So: string, with a space, always.
--------------------------------------------------------------------------------

-- Floating (not pinned) - mint border
hl.window_rule({
    name         = "floating-border",
    match        = { float = true, pin = false },
    border_color = theme.floating.active .. " " .. theme.floating.inactive,
})

-- Pinned - brass border
hl.window_rule({
    name         = "pinned-border",
    match        = { pin = true },
    border_color = theme.pinned.active .. " " .. theme.pinned.inactive,
})

--------------------------------------------------------------------------------
-- TERMINAL & UTILITY WINDOWS
--------------------------------------------------------------------------------

-- Clipse clipboard manager - floating popup
hl.window_rule({
    name         = "clipse-popup",
    match        = { class = "clipse" },
    float        = true,
    size         = { popup_width, popup_height },
    stay_focused = true,
})

-- System update terminal - floating centered
hl.window_rule({
    name   = "auto-update-terminal",
    match  = { class = "auto-update" },
    float  = true,
    size   = { dialog_width, dialog_height },
    center = true,
})

-- Android Emulator (Jet Lag dev) - phone-shaped, always floating and centred.
--
-- The emulator draws a phone, so it wants a phone's bezel corner, not a
-- window's. Deliberately a FIXED number, NOT derived from decoration.rounding
-- in lua/look.lua: a bezel radius is a property of the phone, so it must not
-- drift when the global window rounding is retuned.
--
-- The phone body carries NO rounding rule on purpose. It is the one window in
-- the system that falls through to the global decoration.rounding, which is set
-- to theme.rounding.bezel; a rule here would be capped at 20 and could only
-- make the corner smaller. To retune the bezel, change theme.rounding.bezel.
--
-- rounding_power is left alone, so the corner inherits the global 4.0
-- superellipse exponent and stays G2 rather than a circular arc.

-- Class only: covers the phone body AND the thin side-toolbar the emulator
-- spawns under the same class, both of which want to float and centre.
hl.window_rule({
    name   = "android-emulator",
    match  = { class = "^(Emulator)$" },
    float  = true,
    center = true,
})

-- The emulator's side-toolbar is ~61px wide, so the bezel radius would render
-- it as a lozenge rather than a panel. It shares the class with the phone body,
-- so the global-rounding rule above cannot reach it and it needs demoting here.
--
-- Matched by inverting the BODY's title rather than by matching the toolbar's
-- own, so anything else the emulator ever spawns under this class is demoted by
-- default and only the phone body is special. The body's title carries the AVD
-- name, e.g. "Android Emulator - jetlag_pixel:5554"; the toolbar's is the bare
-- "Emulator".
hl.window_rule({
    name     = "android-emulator-toolbar",
    match    = { class = "^(Emulator)$", title = "negative:^(Android Emulator).*" },
    rounding = theme.rounding.window,
})

--------------------------------------------------------------------------------
-- BROWSER RULES
--------------------------------------------------------------------------------

-- Zen Browser - workspace assignment
hl.window_rule({
    name      = "zen-browser-workspace",
    match     = { class = "^(zen)$" },
    workspace = "1",
})

--------------------------------------------------------------------------------
-- DEVELOPMENT TOOLS
--------------------------------------------------------------------------------

-- Cursor IDE - workspace assignment
hl.window_rule({
    name      = "cursor-ide-workspace",
    match     = { class = "^(cursor)$" },
    workspace = "2",
})

--------------------------------------------------------------------------------
-- MEDIA & ENTERTAINMENT
--------------------------------------------------------------------------------

-- mpv - borderless, no rounding, pure video
hl.window_rule({
    name        = "mpv-borderless",
    match       = { class = "^(mpv)$" },
    border_size = 0,
    rounding    = 0,
})

-- Spotify - transparency and special workspace
hl.window_rule({
    name    = "spotify-opacity",
    match   = { class = "^(spotify)$" },
    opacity = "0.9 override",
})

hl.window_rule({
    name      = "spotify-workspace",
    match     = { class = "^(spotify)$" },
    workspace = "special:music",
})

-- Vesktop (Discord) - special workspace
hl.window_rule({
    name      = "vesktop-workspace",
    match     = { class = "^(vesktop)$" },
    workspace = "special:communication",
})

--------------------------------------------------------------------------------
-- ANDROID (WAYDROID)
--------------------------------------------------------------------------------

-- Waydroid full UI - floating, phone-like size
hl.window_rule({
    name   = "waydroid-float",
    match  = { class = "^(Waydroid)$" },
    float  = true,
    size   = { 675, 1350 },
    center = true,
})

--------------------------------------------------------------------------------
-- GAMING
--------------------------------------------------------------------------------

-- Hytale Launcher - workspace 2, centered
hl.window_rule({
    name      = "hytale-launcher",
    match     = { class = "^(Hytale-launcher)$" },
    workspace = "2",
    center    = true,
})

-- Steam games - workspace 3
hl.window_rule({
    name      = "steam-games-workspace",
    match     = { class = "^(steam_app.*)$" },
    workspace = "3",
})

-- Sober (Roblox) - disable compositor blur and rounding to avoid artifacts
hl.window_rule({
    name     = "sober-no-blur",
    match    = { class = "^(sober)$" },
    no_blur  = true,
    rounding = 0,
})

-- Minecraft - pseudo-tiled at ultrawide resolution
hl.window_rule({
    name   = "minecraft-layout",
    match  = { class = "^Minecraft.*" },
    tile   = true,
    pseudo = true,
    size   = { 3440, 1440 },
})

--------------------------------------------------------------------------------
-- AUDIO PRODUCTION
--------------------------------------------------------------------------------

-- FL Studio - force tiled (Wine app)
hl.window_rule({
    name  = "fl-studio-tile",
    match = { class = "^(fl64.exe)$" },
    tile  = true,
})

--------------------------------------------------------------------------------
-- SYSTEM UTILITIES
--------------------------------------------------------------------------------

-- xwaylandvideobridge - hide completely for screensharing
hl.window_rule({
    name             = "xwayland-videobridge-hide",
    match            = { class = "^(xwaylandvideobridge)$" },
    opacity          = "0.0 override",
    no_anim          = true,
    no_initial_focus = true,
    max_size         = { 1, 1 },
    no_blur          = true,
})

-- gvoice dictation host - hide completely.
--
-- This is a real Chrome window, because Google's speech engine is only reachable
-- from a browser. It must stay MAPPED rather than minimised or parked on a
-- hidden special workspace: Chrome throttles renderers it believes are not
-- visible, and a throttled renderer stops transcribing mid-sentence. So it is
-- hidden the xwaylandvideobridge way instead, fully transparent and 1x1, which
-- keeps the compositor treating it as on-screen.
--
-- Matched on CLASS, and only class. Chrome ignores --class under Wayland and
-- builds the app_id from the app URL instead, giving "chrome-<host>_<path>-<profile>".
-- That is also why the daemon serves on the invented hostname gvoice.localhost:
-- pointed at a bare 127.0.0.1 the class came out "chrome-127.0.0.1__-Default",
-- which every other localhost web app would share.
--
-- Title is NOT a usable match here. The rules below (size, float, focus) are
-- applied when the window maps, and at map time Chrome's title is still the raw
-- URL; it only becomes "gvoice" once the page has loaded, far too late to stop
-- the window appearing. Class is correct from the first frame.
--
-- The 127.0.0.1 form is kept as a fallback for a box where *.localhost fails to
-- resolve and the daemon falls back to the IP.
-- Bottom-right corner of the whole output layout, minus a sliver.
--
-- This is computed rather than written down because the Lua binding's `move`
-- takes plain numbers: hyprlang's percentage form ("100%-2") is parsed by the
-- config-string reader, which this API does not go through, and a percentage
-- string here is accepted and then quietly lands the window at 0,0. So the
-- percentage has to happen in Lua, off the real outputs.
local function layout_corner(margin)
    local x, y = 1920 - margin, 1080 - margin -- fallback: monitors not up yet
    local ok, monitors = pcall(hl.get_monitors)
    if ok and type(monitors) == "table" and #monitors > 0 then
        x, y = 0, 0
        for _, mon in ipairs(monitors) do
            x = math.max(x, mon.x + mon.width - margin)
            y = math.max(y, mon.y + mon.height - margin)
        end
    end
    return x .. " " .. y
end

for _, m in ipairs({
    { name = "gvoice-hide",    match = { class = "^chrome-gvoice\\.localhost.*$" } },
    { name = "gvoice-hide-ip", match = { class = "^chrome-127\\.0\\.0\\.1__.*-Default$" } },
}) do
    hl.window_rule({
        name             = m.name,
        match            = m.match,
        opacity          = "0.0 override",
        no_anim          = true,
        no_initial_focus = true,
        no_focus         = true,
        -- Chrome refuses to shrink past its own ~61x57 minimum, so max_size
        -- cannot get this to a true 1x1. A fully transparent 61x57 window
        -- parked mid-screen is an invisible click-trap, hence the reposition:
        -- it sits in the bottom-right corner with a couple of pixels on screen.
        -- Not fully offscreen, deliberately, so the compositor keeps sending
        -- frame callbacks and Chrome has no excuse to suspend the renderer.
        --
        max_size         = { 1, 1 },
        move             = layout_corner(2),
        no_blur          = true,
        float            = true,
    })
end

--------------------------------------------------------------------------------
-- CUSTOM APPLICATIONS
--------------------------------------------------------------------------------

-- Ollama Dmenu App - dmenu-style launcher
hl.window_rule({
    name         = "ollama-dmenu-float",
    match        = { class = "^(com.bandit.OllamaDmenuApp)$" },
    float        = true,
    center       = true,
    border_size  = 0,
    stay_focused = true,
    idle_inhibit = "fullscreen",
})

-- Note: noinitialfocus removed - conflicts with stay_focused behavior

--------------------------------------------------------------------------------
-- DIALOG WINDOWS
--------------------------------------------------------------------------------

-- Generic "Open File" dialogs - always float
hl.window_rule({
    name  = "open-file-dialog",
    match = { title = "^(Open File)$" },
    float = true,
})

-- Generic "Save File" dialogs - always float
hl.window_rule({
    name  = "save-file-dialog",
    match = { title = "^(Save File)$" },
    float = true,
})

-- Generic file chooser dialogs
hl.window_rule({
    name  = "file-chooser-dialog",
    match = { title = "^(.*[Ff]ile [Cc]hooser.*)$" },
    float = true,
})

--------------------------------------------------------------------------------
-- LAYER RULES (for Waybar, etc.)
--------------------------------------------------------------------------------

-- Uncomment these if you want blur on layers:
-- hl.layer_rule({ name = "waybar-blur",  match = { namespace = "waybar"  }, blur = true })
-- hl.layer_rule({ name = "wlogout-blur", match = { namespace = "wlogout" },
--                 blur = true, blur_popups = true, ignore_alpha = 0.3 })
--
-- The old list had five separate lines for the same two namespaces; in Lua the
-- effects for one namespace collapse into a single rule table, which is why
-- wlogout is one call above instead of four. The one that does not survive the
-- move is `layerrule = ignorezero, wlogout`: 0.56.1 has no ignorezero /
-- ignore_zero field at all, and ignoring fully transparent pixels is what
-- `ignore_alpha = 0` now means, so that behaviour is folded into the
-- ignore_alpha above rather than dropped.

-- (The face-scan eye now rides on the shared caelestia shell surface like the
--  dashboard, so no per-layer blur is needed here. If you re-enable shell
--  transparency and want frosted panels, the Lua form is:
--  hl.layer_rule({ name = "caelestia-drawers-blur",
--                  match = { namespace = "caelestia-drawers" },
--                  blur = true, ignore_alpha = 0.15 }) )

-- banditshell: the chassis is a translucent material, not a painted panel. Blur what
-- is behind it so it reads as frosted glass rather than a flat wash.
-- xray off so it frosts the actual window content, not just the wallpaper.
--
-- NOTE: namespace is the ONLY match key a layer rule actually honours. Any
-- other key parses without complaint and then silently never matches.
hl.layer_rule({
    name         = "banditshell-frosted-chassis",
    match        = { namespace = "banditshell" },
    blur         = true,
    xray         = false,
    ignore_alpha = 0.05,
})
