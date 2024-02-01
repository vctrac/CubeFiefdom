local sprite = g3d.newSprite(DATA.image"object_card",{scale = 0.5})
local block = g3d.newModel(DATA.model.wired_cube)
local aabb_model = g3d.newModel(DATA.model.cube)
---@diagnostic disable-next-line: undefined-field
aabb_model:generateAABB()
local white_color = {1,1,1}

local o = {
    list = {},
    count = 0
}

local function add(index,position)
    o.count = o.count+1
    o.list[index] = { position = position}
    return true
end

local remove = function(index)
    o.count = o.count-1
    o.list[index] = nil
    return true
end

o.clear=function(self)
    --reset all
    for id in pairs(self.list) do
        self.list[id] = nil
    end
    self.count = 0
end

-- Add a new object to the list
---@function add_cube
---@param x integer
---@param y integer
---@param z integer
---@return boolean 
o.add = function(self, x, y, z)
    local pos = {x,y,z}
    local index = To_id(pos)
    if self.list[index] then return false end

    APP.add_change({"object", "add", index})
    -- print"add"
    return add(index, pos)
end

-- Remove a object from the list
---@function add_cube
---@param id string
---@return boolean
o.remove = function(self, id)
    local index
    if type(id)=="string" then
        index = id
    elseif type(id)=="table" then
        index = To_id(id)
    else
        return false
    end
    if not self.list[index] then return false end

    APP.add_change({"object", "remove", index})

    return remove(index)
end

o.cast_ray = function(self, ox, oy, oz, tx, ty, tz, m)
    -- return false
    -- local m = math.huge
    if self.count == 0 then return end
    local n, p
    for i,k in pairs(self.list) do
        aabb_model:setTranslation(unpack(k.position))
        ---@diagnostic disable-next-line: undefined-field
        local d,x,y,z = aabb_model:rayIntersectionAABB(ox, oy, oz, tx, ty, tz )
        if d and d<m then
            m = d
            p = {x,y,z}
            n = i
        end
    end
    return n, p, m
end
o.draw = function(self)
    -- local s = APP.toggle.light and self.light_shader
    local t = APP.toggle.texture
    local g = APP.toggle.grid
    
    if t then
        
        -- love.graphics.setMeshCullMode( "back" )
        -- love.graphics.setWireframe(true)
        love.graphics.setColor(1,1,1)
        for _,m in pairs(self.list) do
            -- love.graphics.setColor(m.color or white_color)
            sprite:setTranslation(unpack(m.position))
            sprite:draw( )
        end

        -- love.graphics.setColor(0,1,0.5,0.3)
        -- love.graphics.setWireframe(true)
        -- for _,m in pairs(self.list) do
        --     block:setTranslation(unpack(m.position))
        --     block:draw( )
        -- end
        -- love.graphics.setWireframe(false)
        
        -- love.graphics.setWireframe(false)
        -- love.graphics.setMeshCullMode( "none" )
    end

    if g then
        love.graphics.setColor(0,1,0.5,0.3)
        love.graphics.setWireframe(true)
        for _,m in pairs(self.list) do
            block:setTranslation(unpack(m.position))
            block:draw( )
        end
        love.graphics.setWireframe(false)
    end
end

return o