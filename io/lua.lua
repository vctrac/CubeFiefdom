
local serpent = require "library.serpent"

local function save_lua( data, filename)
    local save = io.open(filename ..".lua", 'w')
    assert(save, "could not load file")
    local t = {
        version = CONFIG.version,
        app_name = CONFIG.app_name,
        count = data.count,
        info = {},
        cubes = {}
    }

    for _,k in pairs(data.cubes) do
        -- if data.info[k.texture] and not(t.info[k.texture]) then
        --     t.info[k.texture] = data.info[k.texture]
        -- end
        table.insert(t.cubes,{position = k.position , texture = k.texture})
    end
    t.info= data.info
    -- save:write(serpent.dump(t))
    save:write("return " ..serpent.block(t, {comment = false}))
    save:close()
end

local function load_lua(filename)
    return assert(dofile(filename))
end

return {load = load_lua, save = save_lua}