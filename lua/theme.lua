--------------------------------------------------------------------------------
-- GREENSTEEL - cool anodised-green metal
--
-- The idea: brushed steel that has been anodised green, not "green paint".
-- Metal reads as metal because of a *luminance ramp with a specular spike*,
-- not because of hue. So the ramp below is one hue family (~158deg, green
-- leaning cyan = cool, never olive) climbing from near-black to a silvery
-- white, and the borders spend most of their length dark so the bright stop
-- reads as a highlight catching an edge.
--
-- Monocraft note: it is a pixel font, so glyph stems are 1 device pixel and
-- anti-aliasing has almost nothing to work with. Mid-tones make it mush.
-- Anything that renders Monocraft should use phosphor or silver on
-- abyss / void: high luminance distance, low chroma on the dark side.
-- Never put pixel text on body / brushed.
--
-- Only raw hex lives here. Every colour Hyprland actually consumes is derived
-- through rgb()/rgba() below, so a stop is defined exactly once: change
-- `verdigris` and the active border gradient follows.
--------------------------------------------------------------------------------

local M = {}

--- The metal ramp: near-black -> silvery white, single hue family.
--- Raw hex, no prefix, no alpha.
M.hex = {
    void    = "070C0A",
    abyss   = "0D1512",
    dark    = "16211C",
    -- Chassis face: what a large panel is made of. One clear step off the abyss
    -- so a full-height surface reads as a plate with light on it rather than a
    -- hole, while staying well under `body` so Monocraft on it is still crisp.
    plate   = "1B2A23",
    body    = "22322B",
    brushed = "33493F",
    edge    = "4C6B5C",
    lit     = "6E9384",
    pale    = "9DBDAF",
    silver  = "C9E2D7",
    chrome  = "EAF6F0",
    white   = "F7FDFA",

    -- Accents: the "lush" end, where the green actually saturates.
    verdigris = "3FBF8F",
    lush      = "5FD99A",
    phosphor  = "8CFFC0",

    -- Secondary metals, for windows that must not be mistaken for a normal one.
    mint      = "5FF2C4",
    mint_dim  = "1E6B57",
    brass     = "D8C48C",
    brass_dim = "6B5C36",

    -- Off-ramp stops. `border_lit` is the one lit stop of the unfocused border:
    -- between brushed and edge, dimmer than either so an inactive window never
    -- competes with an active one. `shadow` sits below void, so the cast reads
    -- as darker than the darkest metal rather than as a neutral grey.
    border_lit = "3A4F46",
    shadow     = "040907",
}

--- Alpha as a 2-digit hex string. Kept as hex rather than 0..1 floats so the
--- ported values are byte-identical to the ones they replace.
local function alpha_hex(a)
    if type(a) == "string" then return a end
    return string.format("%02x", math.floor(a * 255 + 0.5))
end

--- "rgb(RRGGBB)" for a named stop.
---@param name string key in M.hex
function M.rgb(name)
    local hex = M.hex[name] or error("unknown greensteel stop: " .. tostring(name), 2)
    return "rgb(" .. hex .. ")"
end

--- "rgba(RRGGBBAA)" for a named stop.
---@param name string key in M.hex
---@param a string|number 2-digit hex string ("aa") or a 0..1 fraction
function M.rgba(name, a)
    local hex = M.hex[name] or error("unknown greensteel stop: " .. tostring(name), 2)
    return "rgba(" .. hex .. alpha_hex(a) .. ")"
end

--------------------------------------------------------------------------------
-- Derived gradients
--------------------------------------------------------------------------------

--- Active: a specular sweep. dark body -> verdigris -> white spike -> lush ->
--- back to dark. Full alpha keeps the highlight crisp against the blur.
--- Five stops so the bright one reads as a highlight sliding along a metal
--- edge, not as a two-colour fade.
M.border_active = {
    colors = {
        M.rgba("dark", "ff"),
        M.rgba("verdigris", "ff"),
        M.rgba("white", "ff"),
        M.rgba("lush", "ff"),
        M.rgba("body", "ff"),
    },
    angle = 45,
}

--- Inactive: the same metal with no light on it. Low chroma, translucent.
M.border_inactive = {
    colors = {
        M.rgba("abyss", "aa"),
        M.rgba("border_lit", "aa"),
    },
    angle = 45,
}

--- Shadow: green-black rather than neutral black, so the cast light matches.
M.shadow = M.rgba("shadow", "ee")

--------------------------------------------------------------------------------
-- Window-state borders
--
-- Different metals rather than different hues, so floating and pinned still
-- read as part of the greensteel set: mint for floating, brass for pinned.
--------------------------------------------------------------------------------

M.floating = { active = M.rgb("mint"), inactive = M.rgb("mint_dim") }
M.pinned   = { active = M.rgb("brass"), inactive = M.rgb("brass_dim") }

return M
