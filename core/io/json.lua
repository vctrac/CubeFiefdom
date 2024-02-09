
local json = require "library.json"

local function save_json( data, info, filename)
    local save = io.open(filename ..".json", 'w')
    assert(save, "could not open file")
    local t = {
        version = CONFIG.version,
        app_name = CONFIG.app_name,
        cube_count = data.cube_count,
        object_count = data.object_count,
        info = info,
        cubes = {},
        objects = {}
    }

    for _,k in pairs(data.cubes) do
        -- if data.info[k.texture] and not(t.info[k.texture]) then
        --     t.info[k.texture] = data.info[k.texture]
        -- end
        -- table.insert(t.cubes,{position = k.position , texture = k.texture})
        local coords = {unpack(k.position)}
        table.insert(coords, k.uv[1])
        table.insert(coords, k.uv[2])
        table.insert(t.cubes, coords)
    end
    for _,k in pairs(data.objects) do
        table.insert(t.objects, k)
    end

    save:write(json.encode(t))
    save:close()
end

local function load_json(filename)
    local f = io.open(filename, 'r')
    local string = f:read("*all")
    
    return json.decode(string)
end

return {load = load_json, save = save_json}