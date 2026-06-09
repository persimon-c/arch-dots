-- modules/colors.lua
-- Single solid border color from matugen output.
-- matugen writes ~/.config/hypr/modules/hypr-colors.lua on wallpaper change.

-- We intercept hl.config so we can strip gradients down to a single color
-- before passing to Hyprland, saving constant GPU rerendering.
local _real_config = hl.config
local function apply_solid_border(cfg)
    if cfg.general then
        local ab = cfg.general["col.active_border"]
        -- If matugen gave us a gradient table, grab just the first color.
        -- Strip alpha and replace with 18 (whisper) so matugen colors
        -- don't overpower the glass aesthetic.
        if type(ab) == "table" and ab.colors then
            local base = ab.colors[1]:gsub("rgba%((%x%x%x%x%x%x)%x%x%)", "rgba(%118)")
            cfg.general["col.active_border"]   = base
            cfg.general["col.inactive_border"] = base:gsub("18%)", "08)")
        end
    end
    _real_config(cfg)
end

local colors_file = os.getenv("HOME") .. "/.config/hypr/modules/hypr-colors.lua"
local f = io.open(colors_file, "r")

if f then
    f:close()
    -- Temporarily swap hl.config so dofile() hits our wrapper
    hl.config = apply_solid_border
    dofile(colors_file)
    hl.config = _real_config
else
    -- Fallback: single solid lavender until matugen runs
    hl.config({
        general = {
            ["col.active_border"]   = "rgba(ffffff18)",
            ["col.inactive_border"] = "rgba(ffffff08)",
        },
    })
end