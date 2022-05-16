-- https://github.com/mpv-player/mpv/issues/3826#issuecomment-1100775084

local function load_and_show_osc()
    if show_osc == nil then
        for key, searcher in pairs(package.searchers) do
            res = searcher('@osc.lua')
            if type(res) == 'function' then
                res('@osc.lua')
                break
            end
        end
    end

    show_osc()
end

if mp.get_property_bool("osc") then
    -- show OSC at start to signify change of file
    mp.register_event("file-loaded", load_and_show_osc)

    -- show OSC at seek to know where we are
    mp.register_event("seek", load_and_show_osc)
end
