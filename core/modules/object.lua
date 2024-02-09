local sprite = g3d.newSprite(RES.image"object_card",{scale = 0.5})
local block = g3d.newModel(RES.model.wired_cube)
local aabb_model = g3d.newModel(RES.model.cube)
---@diagnostic disable-next-line: undefined-field
aabb_model:generateAABB()

local o = {
    list = {},
    count = 0
}

---@param index string
---@param position table
local function add(index,position)
    o.count = o.count+1
    o.list[index] = { position = position, color= "white"}
    return true
end

---@param index string
local function remove(index)
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

o.redo = function(op)
    if op[1] == "remove" then--remove
        remove(op[2])
    elseif op[1] == "add" then--add
        local ipos = From_id(op[2])
        add(op[2], ipos)
    end
end
o.undo = function(op)
    if op[1] == "add" then--remove
        remove(op[2])
    elseif op[1] == "remove" then--add
        local ipos = From_id(op[2])
        add(op[2], ipos)
    end
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

o.get = function(self,id)
    assert(type(id)=="string", "id must be a string eg.:1:1:0")
    return self.list[id]
end

o.load_data=function(self, data)
    self:clear()
    self.count = data.object_count
    
    for _,k in ipairs(data.objects) do
        local kpos = {unpack(k.position)}
        local kcor = k.color or "white"
        local id = To_id(k.position)
        
        self.list[id] = { position = kpos, color = kcor}
    end
end

o.draw = function(self)
    local s = APP.toggle.light and APP.light_shader
    local t = APP.toggle.texture
    local g = APP.toggle.grid
    
    if t then
        -- love.graphics.setColor(1,1,1)
        for _,m in pairs(self.list) do
            love.graphics.setColor(RES.palette[m.color])
            sprite:setTranslation(unpack(m.position))
            sprite:draw(s)
        end
    end

    if g then
        love.graphics.setColor(0,1,0.5,0.3)
        love.graphics.setWireframe(true)
        for _,m in pairs(self.list) do
            block:setTranslation(unpack(m.position))
            block:draw(s)
        end
        love.graphics.setWireframe(false)
    end
end

return o