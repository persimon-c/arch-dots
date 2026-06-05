-- modules/colors.lua
-- Border gradient colors from matugen output.
-- matugen writes ~/.config/hypr/modules/hypr-colors.lua on wallpaper change.
-- Fallback values are used until first matugen run.
 
local colors_file = os.getenv("HOME") .. "/.config/hypr/modules/hypr-colors.lua"
local f = io.open(colors_file, "r")
 
if f then
    f:close()
    dofile(colors_file)
else
    -- Fallback: Lavender + Pink (Catppuccin Mocha) until matugen runs
    hl.config({
        general = {
            ["col.active_border"] = { colors = { "rgba(b4befeff)", "rgba(f5c2e7ff)" }, angle = 45 },
            ["col.inactive_border"] = "rgba(45475aaa)",
        },
    })
end
 