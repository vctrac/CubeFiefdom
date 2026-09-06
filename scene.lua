
local aabb_model = g3d.newModel(RES.model.cube)
---@diagnostic disable-next-line: undefined-field
aabb_model:generateAABB()

local tile_row_size = 8
local tile_column_size = 8

local Scene = {
    list = {},
    model = nil,
    count = 0,
}

local function get_corners(x, y, z, tipo)
    local xv,yv,zv = 1,1,1
    if tipo=="slab" then
        zv = 0.5
    end
    return {
        {x,   y,   z},   -- 1: Inferior Frontal Esquerda
        {x+xv, y,   z},   -- 2: Inferior Frontal Direita
        {x+xv, y+yv, z},   -- 3: Inferior Traseira Direita
        {x,   y+yv, z},   -- 4: Inferior Traseira Esquerda
        {x,   y,   z+zv}, -- 5: Superior Frontal Esquerda
        {x+xv, y,   z+zv}, -- 6: Superior Frontal Direita
        {x+xv, y+yv, z+zv}, -- 7: Superior Traseira Direita
        {x,   y+yv, z+zv}, -- 8: Superior Traseira Esquerda
    }
end

local function addFace(p1, p2, p3, p4, u, v, verts, flip_winding, mtype, rotation)
    -- p1 até p4 são tabelas {x, y, z}
    local order = flip_winding and {1, 4, 3, 3, 2, 1} or {1, 2, 3, 3, 4, 1}
    local points = {p1, p2, p3, p4}
    
    local df = 0.001
    local pu = 1/tile_row_size - df
    local pv = 1/tile_column_size - df

    if mtype == "slab" then
        pv = pv*0.5
    end
    -- Coordenadas base
    local u0, v0 = u + df, v + df -- Topo Esq
    local u1, v1 = u + pu, v + df -- Topo Dir
    local u2, v2 = u + pu, v + pv -- Baixo Dir
    local u3, v3 = u + df, v + pv -- Baixo Esq

    -- Tabela de UVs originais
    local uvs = { {u0,v0}, {u1,v1}, {u2,v2}, {u3,v3} }

    -- Rotação de UV (Shift na tabela)
    if rotation then
        uvs = { {u3,v3}, {u0,v0}, {u1,v1}, {u2,v2} }
    end

    if mtype == "triangle" then
        uvs[4] = uvs[1]
    end

    for i = 1, 6 do
        local idx = order[i]
        local p = points[idx]
        local uv = uvs[idx]
        
        table.insert(verts, {
            p[1], p[2], p[3],   -- Posição
            uv[1], uv[2],       -- UV
            0, 0, 1,            -- Normal (g3d:makeNormals resolve depois)
            255, 255, 255, 255  -- Cor
        })
    end
end

local ramp_defs = {
    north = { slope = {1,2,7,8}, sideL = {1,4,8,8}, sideR = {2,3,7,7}, back = {3,4,8,7}, back_check = {0,1,0} },
    south = { slope = {4,3,6,5}, sideL = {4,1,5,5}, sideR = {3,2,6,6}, back = {1,2,6,5}, back_check = {0,-1,0} },
    west  = { slope = {2,5,8,3}, sideL = {3,4,8,8}, sideR = {2,1,5,5}, back = {4,1,5,8}, back_check = {-1,0,0} },
    east  = { slope = {1,6,7,4}, sideL = {4,3,7,7}, sideR = {1,2,6,6}, back = {2,3,7,6}, back_check = {1,0,0} },
}
local object_types = {
    cube = function(obj, verts)
        local x,y,z = obj.position[1], obj.position[2], obj.position[3]
        local c = get_corners(x, y, z)
        local u, v = obj.uv[1]/tile_row_size, obj.uv[2]/tile_column_size

        -- Face botton
        local gc = Scene:get_cube({x, y, z-1})
        if not gc or gc.type~="cube" then addFace(c[1], c[2], c[3], c[4], u, v, verts, true) end
        -- Face top
        if not Scene:get_cube({x, y, z+1}) then addFace(c[5], c[6], c[7], c[8], u, v, verts) end
        -- Face left
        gc = Scene:get_cube({x, y-1, z})
        if not gc or gc.type~="cube" then addFace(c[1], c[2], c[6], c[5], u, v, verts) end
        -- Face right
        gc = Scene:get_cube({x, y+1, z})
        if not gc or gc.type~="cube" then addFace(c[3], c[4], c[8], c[7], u, v, verts) end
        -- Face back
        gc = Scene:get_cube({x-1, y, z})
        if not gc or gc.type~="cube" then addFace(c[5], c[8], c[4], c[1], u, v, verts) end
        -- Face front
        gc = Scene:get_cube({x+1, y, z})
        if not gc or gc.type~="cube" then addFace(c[2], c[3], c[7], c[6], u, v, verts) end
    end,
    slab = function(obj, verts)
        local x,y,z = obj.position[1], obj.position[2], obj.position[3]
        local c = get_corners(x, y, z, obj.type)
        local u, v = obj.uv[1]/tile_row_size, obj.uv[2]/tile_column_size

        -- Face botton
        local gc = Scene:get_cube({x, y, z-1})
        if not gc or gc.type~="cube" then addFace(c[1], c[2], c[3], c[4], u, v, verts, true) end
        -- Face top
        addFace(c[5], c[6], c[7], c[8], u, v, verts)
        -- Face left
        gc = Scene:get_cube({x, y-1, z})
        if not gc or gc.type=="ramp" then addFace(c[1], c[2], c[6], c[5], u, v, verts, nil,"slab") end
        -- Face right
        gc = Scene:get_cube({x, y+1, z})
        if not gc or gc.type=="ramp" then addFace(c[3], c[4], c[8], c[7], u, v, verts, nil,"slab") end
        -- Face back
        gc = Scene:get_cube({x-1, y, z})
        if not gc or gc.type=="ramp" then addFace(c[5], c[8], c[4], c[1], u, v, verts, nil,"slab") end
        -- Face front
        gc = Scene:get_cube({x+1, y, z})
        if not gc or gc.type=="ramp" then addFace(c[2], c[3], c[7], c[6], u, v, verts, nil,"slab") end
    end,
    ramp = function(obj, verts)
        local odir = obj.direction
        local d = ramp_defs[odir]
        local x, y, z = obj.position[1], obj.position[2], obj.position[3]
        local c = get_corners(x, y, z)
        local u, v = obj.uv[1]/tile_row_size, obj.uv[2]/tile_column_size

        local dir = {
            north = {
                sideL = true,
            },
            south = {
                sideR = true,
                top = true
            },
            west = {
                sideR = true,
                top = true,
                rot = true
            },
            east = {
                sideL = true,
                rot = true
            },
        }
        -- Face botton
        local gc = Scene:get_cube({x, y, z-1})
        if not gc or gc.type~="cube" then addFace(c[1], c[2], c[3], c[4], u, v, verts, true) end

        -- 1. Face Inclinada
        addFace(c[d.slope[1]], c[d.slope[2]], c[d.slope[3]], c[d.slope[4]], u, v, verts, dir[odir].top, nil, dir[odir].rot)
        
        -- 2. Laterais
        addFace(c[d.sideL[1]], c[d.sideL[2]], c[d.sideL[3]], c[d.sideL[4]], u, v, verts, dir[odir].sideL, "triangle")
        addFace(c[d.sideR[1]], c[d.sideR[2]], c[d.sideR[3]], c[d.sideR[4]], u, v, verts, dir[odir].sideR, "triangle")
        
        -- 3. Culling da face traseira
        local bc = d.back_check
        gc = Scene:get_cube({x+bc[1], y+bc[2], z+bc[3]})
        if not gc or gc.type~="cube" then addFace(c[d.back[1]], c[d.back[2]], c[d.back[3]], c[d.back[4]], u, v, verts) end
    end
}
local function remesh()
    local verts = {}
    for _, obj in pairs(Scene.list) do
        object_types[obj.type](obj, verts)
    end
    Scene.model = g3d.newModel(verts, APP.atlas, {-0.5,-0.5,-0.5})
    Scene.model:makeNormals()
end
-- Add a new cube to the cubes table array
---@function add
---@param index string
---@param texture_id string
---@param position table
local add = function(index, texture_id, position, settings)
    local ipos = From_id(texture_id)
    settings = settings or {}
    Scene.count = Scene.count+1
    local nc = {
        type = settings.type,
        uv = ipos,
        texture = texture_id,
        position = position
    }
    if settings.type=="ramp" then
        nc.direction = settings.direction
    end
    Scene.list[index] = nc
    -- Scene.list[index] = {position = position, object = true}
    remesh()
    return true
end
-- Remove a cube from the cubes table array    
---@function remove
---@param index string
local remove = function(index)-- there may be bugs here!
    Scene.count = Scene.count-1
    Scene.list[index] = nil
    remesh()
    return true
end
local function paint(index, texture_id)
    local ipos = From_id(texture_id)
    local old_tex = Scene.list[index].texture

    if old_tex==texture_id then
        return false
    end
    Scene.list[index].texture = texture_id
    Scene.list[index].uv = ipos
    remesh()
    return true
end

Scene.clear=function(self)
    --reset all
    for id in pairs(self.list) do
        self.list[id] = nil
    end
    self.count = 0
end

Scene.new=function(self)
    self:clear()
    local id = "0:0:0"
    local texture_id = "0:0"

    add(id, texture_id, {0,0,0}, {type ="cube"})
    remesh()
    self.count = 1
end
Scene.load_data=function(self, data)
    self:clear()
    self.count = data.cube_count
    
    for _,k in ipairs(data.cubes) do
        local kpos = {k[1],k[2],k[3]}
        local ipos = {k[4], k[5]}

        local id = To_id(kpos)
        local ktex = To_id(ipos)
        
        self.list[id] = {uv = ipos, texture = ktex, position = kpos}--, dynamic = k[6]}
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
Scene.add_cube = function(self, settings, texture_id, x, y, z)
    -- err()
    local pos = {x,y,z}
    local index = To_id(pos)
    if self.list[index] then return false end

    APP.add_change({settings.type,"add", index, texture_id})

    return add(index, texture_id, pos, settings)
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
    if not self.list[index] then return false end

    local texture_id = tostring(self.list[index].texture)
    APP.add_change({"cube","remove",index,texture_id})

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
    return self.list[index]
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
    if not self.list[index] then return false end

    if texture and texture~=self.list[index].texture then
        APP.add_change({"cube","paint",index, texture, self.list[index].texture})
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
    local m = math.huge
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

Scene.draw = function(self, s)
    local s = APP.toggle.light and APP.light_shader
    local t = APP.toggle.texture
    local g = APP.toggle.grid
    
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
end

return Scene