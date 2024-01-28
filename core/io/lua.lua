
local serpent = require "library.serpent"

local function save_lua( map, info, filename)
    local save = io.open(filename ..".lua", 'w')
    assert(save, "could not open file")
    local t = {
        version = CONFIG.version,
        app_name = CONFIG.app_name,
        count = map.count,
        info = info,
        cubes = {}
    }

    for _,k in pairs(map.cubes) do
        -- if data.info[k.texture] and not(t.info[k.texture]) then
        --     t.info[k.texture] = data.info[k.texture]
        -- end
        -- table.insert(t.cubes,{position = k.position , texture = k.texture})
        local coords = {unpack(k.position)}
        table.insert(coords, k.uv[1])
        table.insert(coords, k.uv[2])
        table.insert(t.cubes, coords)
    end
    -- t.info= data.info
    save:write(serpent.dump(t))
    -- save:write("return " ..serpent.block(t, {comment = false}))
    save:close()
end

local function load_lua(filename)
    return assert(dofile(filename))
end

return {load = load_lua, save = save_lua}