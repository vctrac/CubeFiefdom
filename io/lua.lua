
local serpent = require "library.serpent"

local function save_lua( data, filename)
    local save = io.open(filename ..".lua", 'w')
    
    local t = {
        version = CONFIG.version,
        app_name = CONFIG.app_name,
        palette_count = data.palette_count,
        texture_count = data.texture_count,
        cubes = {}
    }

    for _,k in pairs(data.cubes) do
        table.insert(t.cubes,{position = k.position , texture_index = k.texture_index})
    end

    save:write(serpent.dump(t))
    save:close()
end

local function load_lua(filename)
    return assert(dofile(filename))
end

return {load = load_lua, save = save_lua}