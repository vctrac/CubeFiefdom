
json = require "library.json"

local function save_json( data, filename)
    local save = io.open(filename ..".json", 'w')
    
    local t = {
        version = CONFIG.version,
        app_name = CONFIG.app_name,
        palette_count = data.palette_count,
        texture_count = data.texture_count,
        cubes = {}
    }

    for i,k in pairs(data.cubes) do
        table.insert(t.cubes,{position = k.position , texture_index = k.texture_index})
    end

    save:write(json.encode(t))
    save:close()
end

local function parse_json(filename)
    local f = io.open(filename, 'r')
    local string = f:read("*all")
    
    return json.decode(string)
end

return {load = parse_json, save = save_json}