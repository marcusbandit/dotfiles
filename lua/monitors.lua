--------------------------------------------------------------------------------
-- MONITORS AND WORKSPACE ASSIGNMENT
--
-- Ported from the MONITOR CONFIGURATION block at the bottom of hyprland.conf
-- and the "WORKSPACE ASSIGNMENT TO MONITORS" block at the top of
-- hyprland/rules.conf. Those two lived in separate files but describe one
-- thing (which physical output owns what), so they are kept together here.
--
-- The output names are locals rather than repeated string literals: rules.conf
-- carried its own duplicate `$ultrawide` / `$vertical_side` pair with a comment
-- telling the reader to keep it in sync with hyprland.conf by hand. Defining
-- them once removes that chore.
--------------------------------------------------------------------------------

local ultrawide     = "HDMI-A-1"
local vertical_side = "DP-1"

--------------------------------------------------------------------------------
-- Outputs
--------------------------------------------------------------------------------

-- Fallback monitor config: anything not named below comes up at its preferred
-- mode, auto-placed, unscaled. This is the only live monitor line.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Home monitor setup:
--           Monitor,        Resulution@Hz,  Pos,        Scale,  Rotation, 1-3,  Bitdepth,   n,  VVR,    Color mode
--
-- hyprlang took those positionally (with `transform` / `bitdepth` / `vrr` / `cm`
-- as inline keywords); the Lua form names every field, so the header above is
-- kept as the map from the old columns to the new keys.
--
-- hl.monitor({ output = vertical_side, mode = "1920x1200@60", position = "0x0",
--              scale = 1, transform = 1 })
--
-- Default mode
-- hl.monitor({ output = ultrawide, mode = "5120x1440@144", position = "1200x240",
--              scale = 0.8, transform = 0, bitdepth = 8, vrr = 1 })
--
-- HDR mode
-- hl.monitor({ output = ultrawide, mode = "5120x1440@144", position = "1200x240",
--              scale = 1, transform = 0, bitdepth = 10, vrr = 1,
--              cm = "hdr", sdrbrightness = 1.2, sdrsaturation = 0.98 })

--------------------------------------------------------------------------------
-- Workspace assignment to monitors
--
-- rules.conf spelled out ten near-identical `workspace = N, monitor:...` lines.
-- The actual rule is much smaller than that: contiguous bands of workspaces,
-- one band per output. Declaring the bands and generating the rules means
-- moving the split (or adding an eleventh workspace) is a one-number edit
-- instead of a rewrite, and the two bands can never silently overlap.
--------------------------------------------------------------------------------

local bands = {
    { monitor = ultrawide,     first = 1, last = 5 },
    { monitor = vertical_side, first = 6, last = 10 },
}

-- Per-workspace extras merged on top of the generated rule. Workspace 6 is the
-- vertical panel's landing spot, so it runs the scrolling layout stacked
-- downwards rather than sideways; that is the only workspace that deviates,
-- and keeping it here keeps the common case above readable.
local overrides = {
    [6] = { layout = "scrolling", layout_opts = { direction = "down" } },
}

for _, band in ipairs(bands) do
    for ws = band.first, band.last do
        local rule = { workspace = tostring(ws), monitor = band.monitor }
        for key, value in pairs(overrides[ws] or {}) do
            rule[key] = value
        end
        hl.workspace_rule(rule)
    end
end

-- Special workspaces
hl.workspace_rule({ workspace = "special:music", monitor = vertical_side })
