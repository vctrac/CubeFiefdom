
local aabb_model = g3d.newModel(RES.model.cube)
---@diagnostic disable-next-line: undefined-field
aabb_model:generateAABB()

local tile_row_size = 8
local tile_column_size = 8

local Ramps = {
    list = {},
    model = nil,
    count = 0,
}

-- Directions: 0 = North (z-), 1 = East (x+), 2 = South (z+), 3 = West (x-)
-- Ramps go from base height to base height + 1
local function remesh()
    local index = 1
    local verts = {}
    
    local function addRampFace(x, y, z, dir, u, v)
        -- A ramp is a triangular prism (wedge)
        -- dir 0: slopes from z-1 to z, faces north
        -- dir 1: slopes from x to x+1, faces east
        -- dir 2: slopes from z to z+1, faces south
        -- dir 3: slopes from x-1 to x, faces west
        
        if dir == 0 then
            -- North-facing ramp: front face slopes up in +z direction
            -- Bottom triangle
            local vertices = {
                {x,     y,     z-1,  u, v, 0, 0, 1, 255, 255, 255, 155},
                {x+1,   y,     z-1,  u+1/tile_row_size, v, 0, 0, 1, 255, 255, 255, 155},
                {x,     y+1,   z,    u, v+1/tile_column_size, 0, 0, 1, 255, 255, 255, 155},
                
                {x+1,   y,     z-1,  u+1/tile_row_size, v, 0, 0, 1, 255, 255, 255, 155},
                {x+1,   y+1,   z,    u+1/tile_row_size, v+1/tile_column_size, 0, 0, 1, 255, 255, 255, 155},
                {x,     y+1,   z,    u, v+1/tile_column_size, 0, 0, 1, 255, 255, 255, 155},
            }
            for _, vert in ipairs(vertices) do
                verts[index] = vert
                index = index + 1
            end
            
        elseif dir == 1 then
            -- East-facing ramp: slopes up in +x direction
            local vertices = {
                {x,     y,     z,    u, v, 0, 0, 1, 255, 255, 255, 155},
                {x,     y,     z+1,  u+1/tile_row_size, v, 0, 0, 1, 255, 255, 255, 155},
                {x+1,   y+1,   z,    u, v+1/tile_column_size, 0, 0, 1, 255, 255, 255, 155},
                
                {x,     y,     z+1,  u+1/tile_row_size, v, 0, 0, 1, 255, 255, 255, 155},
                {x+1,   y+1,   z+1,  u+1/tile_row_size, v+1/tile_column_size, 0, 0, 1, 255, 255, 255, 155},
                {x+1,   y+1,   z,    u, v+1/tile_column_size, 0, 0, 1, 255, 255, 255, 155},
            }
            for _, vert in ipairs(vertices) do
                verts[index] = vert
                index = index + 1
            end
            
        elseif dir == 2 then
            -- South-facing ramp: slopes up in -z direction
            local vertices = {
                {x,     y,     z,    u, v, 0, 0, 1, 255, 255, 255, 155},
                {x,     y+1,   z-1,  u, v+1/tile_column_size, 0, 0, 1, 255, 255, 255, 155},
                {x+1,   y,     z,    u+1/tile_row_size, v, 0, 0, 1, 255, 255, 255, 155},
                
                {x+1,   y,     z,    u+1/tile_row_size, v, 0, 0, 1, 255, 255, 255, 155},
                {x,     y+1,   z-1,  u, v+1/tile_column_size, 0, 0, 1, 255, 255, 255, 155},
                {x+1,   y+1,   z-1,  u+1/tile_row_size, v+1/tile_column_size, 0, 0, 1, 255, 255, 255, 155},
            }
            for _, vert in ipairs(vertices) do
                verts[index] = vert
                index = index + 1
            end
            
        elseif dir == 3 then
            -- West-facing ramp: slopes up in -x direction
            local vertices = {
                {x,     y+1,   z,    u, v+1/tile_column_size, 0, 0, 1, 255, 255, 255, 155},
                {x,     y,     z,    u, v, 0, 0, 1, 255, 255, 255, 155},
                {x,     y+1,   z+1,  u+1/tile_row_size, v+1/tile_column_size, 0, 0, 1, 255, 255, 255, 155},
                
                {x,     y,     z,    u, v, 0, 0, 1, 255, 255, 255, 155},
                {x,     y,     z+1,  u+1/tile_row_size, v, 0, 0, 1, 255, 255, 255, 155},
                {x,     y+1,   z+1,  u+1/tile_row_size, v+1/tile_column_size, 0, 0, 1, 255, 255, 255, 155},
            }
            for _, vert in ipairs(vertices) do
                verts[index] = vert
                index = index + 1
            end
        end
    end
    
    for _, ramp in pairs(Ramps.list) do
        local x, y, z = ramp.position[1], ramp.position[2], ramp.position[3]
        local u, v = unpack(ramp.uv)
        u = u / tile_row_size
        v = v / tile_column_size
        addRampFace(x, y, z, ramp.direction, u, v)
    end
    
    if #verts > 0 then
        Ramps.model = g3d.newModel(verts, APP.atlas, {-0.5,-0.5,-0.5})
        Ramps.model:makeNormals()
    else
        Ramps.model = nil
    end
end

-- Add a new ramp to the ramps table
---@param index string
---@param texture_id string
---@param position table
---@param direction integer
local add = function(index, texture_id, position, direction)
    local ipos = From_id(texture_id)
    Ramps.count = Ramps.count + 1
    Ramps.list[index] = {uv = ipos, texture = texture_id, position = position, direction = direction}
    remesh()
    return true
end

-- Remove a ramp from the ramps table
local remove = function(index)
    Ramps.count = Ramps.count - 1
    Ramps.list[index] = nil
    remesh()
    return true
end

local function paint(index, texture_id)
    local ipos = From_id(texture_id)
    local old_tex = Ramps.list[index].texture

    if old_tex == texture_id then
        return false
    end
    Ramps.list[index].texture = texture_id
    Ramps.list[index].uv = ipos
    remesh()
    return true
end

Ramps.clear = function(self)
    for id in pairs(self.list) do
        self.list[id] = nil
    end
    self.count = 0
end

Ramps.load_data = function(self, data)
    self:clear()
    self.count = data.ramp_count or 0
    
    if data.ramps then
        -- Handle if ramps is an array (from file loading)
        local ramps_data = data.ramps
        if ramps_data[1] then
            -- It's an array-like structure
            for _, k in ipairs(ramps_data) do
                local kpos = {k[1], k[2], k[3]}
                local ipos = {k[4], k[5]}
                local direction = k[6] or 0

                local id = To_id(kpos) .. ":" .. direction
                local ktex = To_id(ipos)
                
                self.list[id] = {uv = ipos, texture = ktex, position = kpos, direction = direction}
            end
        else
            -- It's a table with string keys (from memory)
            for id, ramp in pairs(ramps_data) do
                self.list[id] = ramp
            end
        end
    end
    remesh()
end

Ramps.refresh = function(self)
    remesh()
end

Ramps.draw = function(self)
    if self.model then
        self.model:draw()
    end
end

-- Add a new ramp
---@param texture_id string
---@param x integer
---@param y integer
---@param z integer
---@param direction integer
---@return boolean
Ramps.add_ramp = function(self, texture_id, x, y, z, direction)
    local pos = {x, y, z}
    direction = direction or 0
    local index = To_id(pos) .. ":" .. direction
    if self.list[index] then return false end

    APP.add_change({"ramp", "add", index, texture_id, tostring(direction)})

    return add(index, texture_id, pos, direction)
end

-- Remove a ramp
---@param id string
---@return boolean
Ramps.remove_ramp = function(self, id)
    if not self.list[id] then return false end

    local texture_id = tostring(self.list[id].texture)
    local direction = tostring(self.list[id].direction)
    APP.add_change({"ramp", "remove", id, texture_id, direction})

    return remove(id)
end

Ramps.get_ramp = function(self, id)
    local index
    if type(id) == "string" then
        index = id
    elseif type(id) == "table" then
        index = To_id(id)
    else
        return false
    end
    return self.list[index]
end

Ramps.paint_ramp = function(self, id, texture)
    local index
    if type(id) == "string" then
        index = id
    elseif type(id) == "table" then
        index = To_id(id)
    else
        return false
    end
    if not self.list[index] then return false end

    if texture and texture ~= self.list[index].texture then
        APP.add_change({"ramp", "paint", index, texture, self.list[index].texture})
        return paint(index, texture)
    end
    return false
end

Ramps.undo = function(self, op)
    if op[1] == "add" then
        remove(op[2])
    elseif op[1] == "remove" then
        local id = op[2]
        local ramp = self.list[id]
        if ramp then
            add(id, op[3], ramp.position, ramp.direction)
        end
    elseif op[1] == "paint" then
        paint(op[2], op[4])
    end
end

Ramps.redo = function(self, op)
    if op[1] == "add" then
        local id = op[2]
        local texture_id = op[3]
        local direction = tonumber(op[4])
        -- Extract position from id by removing the direction part
        local pos_str = id:match("(.+):%d+$")
        if pos_str then
            local position = From_id(pos_str)
            add(id, texture_id, position, direction)
        end
    elseif op[1] == "remove" then
        remove(op[2])
    elseif op[1] == "paint" then
        paint(op[2], op[3])
    end
end

return Ramps
