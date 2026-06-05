-- modules/layout.lua
-- Layout, general window settings, and binds config.
 
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        layout = "dwindle",
 
        -- NOTE: active/inactive border colors are set by colors.lua (matugen output or fallback).
 
        resize_on_border = true,
        extend_border_grab_area = 10,
    },
 
    dwindle = {
        preserve_split = true,
        smart_split = false,
        smart_resizing = true,
    },
 
    binds = {
        allow_workspace_cycles = true,
        workspace_back_and_forth = true,
    },
})
 