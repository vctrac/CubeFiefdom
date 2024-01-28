
local aabb_model = g3d.newModel(DATA.model.cube)
---@diagnostic disable-next-line: undefined-field
aabb_model:generateAABB()

local tile_row_size = 8
local tile_column_size = 8

local Scene = {
    cubes = {},
    -- info = {},
    model = nil,
    light_shader = love.graphics.newShader(g3d.shaderpath, DATA.shader.lighting),
    count = 0,
}

--This function was taken from the g3d_voxel demo and franksteined here
--[https://github.com/groverburger/g3d_voxel/blob/master/lib/chunkremesh.lua]
local function remesh()
    local index = 1
    local verts = {}
    local function addFace(x,y,z, mx,my,mz, u,v, flip)
        for i=1, 6 do
            local df = 0.001 --this variable here prevents texture bleeding
            local pu = 1/tile_row_size - df
            -- local pv = 1/tile_column_size - df
            local primary = i%2 == (flip and 0 or 1)
            local secondary = i > 2 and i < 6
            verts[index] = {}
            verts[index][1]  = x + (mx == 1 and primary and 1 or 0) + (mx == 2 and secondary and 1 or 0)
            verts[index][2]  = y + (my == 1 and primary and 1 or 0) + (my == 2 and secondary and 1 or 0)
            verts[index][3]  = z + (mz == 1 and primary and 1 or 0) + (mz == 2 and secondary and 1 or 0)
            verts[index][4]  = u + (primary   and pu or df)
            verts[index][5]  = v + (secondary and df or pu)
            verts[index][6]  = 0
            verts[index][7]  = 0
            verts[index][8]  = 1
            verts[index][9]  = 255
            verts[index][10] = 255
            verts[index][11] = 255
            verts[index][12] = 155
            index = index+1
        end
    end

    for _,cube in pairs(Scene.cubes) do
        local x,y,z = cube.position[1], cube.position[2], cube.position[3]
        local u,v = unpack(cube.uv)
        u = u/tile_row_size
        v = v/tile_column_size
        local nc = Scene:get_cube( {x-1,y,z})
        if not nc or nc.dynamic then addFace(x,y,z,   0,1,2, u,v) end --front
        nc = Scene:get_cube( {x,y+1,z})
        if not nc or nc.dynamic then addFace(x,y+1,z, 1,0,2, u,v) end --left
        nc = Scene:get_cube( {x,y,z-1})
        if not nc or nc.dynamic then addFace(x,y,z,   1,2,0, u,v) end --botton
        
        nc = Scene:get_cube( {x+1,y,z})
        if not nc or nc.dynamic then addFace(x+1,y,z, 0,1,2, u,v, true) end --back
        nc = Scene:get_cube( {x,y-1,z})
        if not nc or nc.dynamic then addFace(x,y,z,   1,0,2, u,v, true) end --right
        nc = Scene:get_cube( {x,y,z+1})
        if not nc or nc.dynamic then addFace(x,y,z+1, 1,2,0, u,v, true) end --top

    end
    Scene.model = g3d.newModel(verts, APP.atlas, {-0.5,-0.5,-0.5})
    Scene.model:makeNormals()

end
-- Add a new cube to the cubes table array
---@function add
---@param index string
---@param texture_id string
---@param position table
local add = function(index, texture_id, position)
    local ipos = From_id(texture_id)
    Scene.count = Scene.count+1
    Scene.cubes[index] = {uv = ipos, texture = texture_id, position = position}
    remesh()
    return true
end
-- Remove a cube from the cubes table array    
---@function remove
---@param index string
local remove = function(index)-- there may be bugs here!
    Scene.count = Scene.count-1
    Scene.cubes[index] = nil
    remesh()
    return true
end
local function paint(index, texture_id)
    local ipos = From_id(texture_id)
    local old_tex = Scene.cubes[index].texture

    if old_tex==texture_id then
        return false
    end
    Scene.cubes[index].texture = texture_id
    Scene.cubes[index].uv = ipos
    remesh()
    return true
end

Scene.clear=function(self)
    --reset all
    for id in pairs(self.cubes) do
        self.cubes[id] = nil
    end
    self.count = 0
end

Scene.new=function(self)
    self:clear()
    local id = "0:0:0"
    local texture_id = "0:0"

    add(id, texture_id, {0,0,0})
    remesh()
    self.count = 1
end
Scene.load_data=function(self, data)
    self:clear()
    self.count = data.count
    -- self.info = data.info

    for _,k in ipairs(data.cubes) do
        local kpos = {k[1],k[2],k[3]}
        local ipos = {k[4], k[5]}

        local id = To_id(kpos)
        local ktex = To_id(ipos)
        
        self.cubes[id] = {uv = ipos, texture = ktex, position = kpos, dynamic = k[6]}
    end
    remesh()
end
Scene.refresh = function(self)
    remesh()
end

-- Add a new cube to the cubes table array
---@function add_cube
---@param texture_id string
---@param x integer
---@param y integer
---@param z integer
---@return boolean 
Scene.add_cube = function(self, texture_id, x, y, z)
    local pos = {x,y,z}
    local index = To_id(pos)
    if self.cubes[index] then return false end

    APP.add_change({"add",index,texture_id})

    return add(index, texture_id, pos)
end

-- Remove a cube from the cubes table array
---@function add_cube
---@param id string
---@return boolean
Scene.remove_cube = function(self, id)
    if self.count==1 then return false end
    local index
    if type(id)=="string" then
        index = id
    elseif type(id)=="table" then
        index = To_id(id)
    else
        return false
    end
    if not self.cubes[index] then return false end

    local texture_id = tostring(self.cubes[index].texture)
    APP.add_change({"remove",index,texture_id})

    return remove(index)
end
Scene.get_cube = function(self,id)
    local index
    if type(id)=="string" then
        index = id
    elseif type(id)=="table" then
        index = To_id(id)
    else
        return false
    end
    return self.cubes[index]
end
Scene.paint_cube = function(self, id, texture)
    local index
    if type(id)=="string" then
        index = id
    elseif type(id)=="table" then
        index = To_id(id)
    else
        return false
    end
    if not self.cubes[index] then return false end

    if texture and texture~=self.cubes[index].texture then
        APP.add_change({"paint",index, texture, self.cubes[index].texture})
        return paint(index, texture)
    end
    return false
end

Scene.redo = function(op)
    if op[1] == "remove" then--remove
        remove(op[2])
    elseif op[1] == "add" then--add
        local ipos = From_id(op[2])
        add(op[2], op[3], ipos)
    elseif op[1] == "paint" then--paint
        paint(op[2], op[3])
    end
end
Scene.undo = function(op)
    if op[1] == "add" then--remove
        remove(op[2])
    elseif op[1] == "remove" then--add
        local ipos = From_id(op[2])
        add(op[2], op[3], ipos)
    elseif op[1] == "paint" then--paint
        paint(op[2], op[4])
    end
end
Scene.cast_ray = function(self, ox, oy, oz, tx, ty, tz)
    -- return false
    local m = math.huge
    local n, p
    for i,k in pairs(self.cubes) do
        aabb_model:setTranslation(unpack(k.position))
        ---@diagnostic disable-next-line: undefined-field
        local d,x,y,z = aabb_model:rayIntersectionAABB(ox, oy, oz, tx, ty, tz )
        if d and d<m then
            m = d
            p = {x,y,z}
            n = i
        end
    end
    return n, p
end

-- local string2bool = {["true"]=true, ["false"]=false}

-- ---@param id string
-- ---@param key string
-- ---@param value any
-- Scene.add_info = function(self, id, key, value)
--     if not self.info[id] then
--         self.info[id] = {}
--     end

--     local v = value
--     local isBool = string2bool[string.lower(value)]
--     if tonumber(v) then
--         v = tonumber(v)
--     elseif isBool ~=nil then
--         v = isBool
--     end
--     self.info[id][key] = v
-- end

-- ---@param id string
-- ---@param key string
-- Scene.remove_info = function(self, id, key)
--     if not(self.info[id] and self.info[id][key]~=nil) then
--         return false
--     end
--     self.info[id][key]=nil
--     return true
-- end

-- ---@param id string
-- ---@param old string
-- ---@param new string
-- ---@param value? any
-- Scene.set_info_key = function(self, id, old, new, value)
--     local old_key = tostring(old)
--     local new_key = tostring(new)
--     if not self.info[id] then
--         self:add_info(id, new_key, value or "...")
--     elseif self.info[id][new_key] then
--         return
--     else
--         if self.info[id][old_key] then
--             if new_key~="" then--if new_key key is empty than delete it
--                 self:add_info(id, new_key, value or self.info[id][old_key])
--             end
--             self.info[id][old_key] = nil
            
--             --check if there's no info for this tile
--             local c = 0
--             for _ in pairs(self.info[id]) do
--                 c = c +1
--             end
--             if c==0 then self.info[id] = nil end
--         else
--             self:add_info(id, new_key, value or "...")
--         end
--     end
-- end

-- --Returns a <b>table</b> with one or multiple pars of <i>[ keys ]</i> and <i>[ values ]</i>,</br>
-- -- or <b>empty table</b> if there is no info for this ID</br>
-- -- { [key1]=value, [key2]=value, ... }
-- ---@param id string
-- ---@return table info
-- Scene.get_info = function(self, id)
--     if self.info[id] then
--         return self.info[id]
--     end
--     return {}
-- end

-- ---@param id string
-- ---@param key string
-- ---@return any value
-- Scene.get_info_key = function(self, id, key)
--     if key~=nil and self.info[id] then
--         if self.info[id][key] then
--             return self.info[id][key]
--         end
--     end
--     return false
-- end

Scene.draw = function(self)
    local s = APP.toggle.light and self.light_shader
    local t = APP.toggle.texture
    local g = APP.toggle.grid
    
    -- for i,k in pairs(self.cubes) do

        -- love.graphics.setColor(1,1,1)
        -- if t then-- and not self.alpha_ids[i]then
        --     k:draw(s)
        -- end
        
        -- love.graphics.setColor(0,0,0)
    if t then
        love.graphics.setColor(1,1,1)
        self.model:draw(s)
    end

    if g then
        love.graphics.setColor(0,0,0)
        love.graphics.setWireframe(true)
        self.model:draw( )
        love.graphics.setWireframe(false)
    end
    -- end
    
    -- for i,k in pairs(self.alpha_ids) do
    --     love.graphics.setColor(1,1,1)
    --     self.cubes[i]:draw( )
    -- end
end

return Scene