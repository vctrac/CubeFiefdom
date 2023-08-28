
-- local function hex2rgb(hex, alpha) 
-- 	local redColor,greenColor,blueColor=hex:match('ff?(..)(..)(..)')
-- 	redColor, greenColor, blueColor = tonumber(redColor, 16)/255, tonumber(greenColor, 16)/255, tonumber(blueColor, 16)/255
-- 	redColor, greenColor, blueColor = math.floor(redColor*100)/100, math.floor(greenColor*100)/100, math.floor(blueColor*100)/100
-- 	if alpha == nil then
-- 		return redColor, greenColor, blueColor
-- 	end
-- 	return redColor, greenColor, blueColor, alpha
-- end

-- local function Image_from_quad(source, x,y,w,h)
--     local nid = love.image.newImageData(w, h)
--     nid:paste(source, 0, 0, x, y, w, h)

--     return love.graphics.newImage(nid)
-- end

-- local select_model --= g3d.newModel(CUBE, nil, nil,nil, 1.005)
-- -- create the mesh for the block cursor
-- do
--     local a = -0.005
--     local b = 1.005
--     select_model = g3d.newModel{
--         {a,a,a}, {b,a,a}, {b,a,a},
--         {a,a,a}, {a,a,b}, {a,a,b},
--         {b,a,b}, {a,a,b}, {a,a,b},
--         {b,a,b}, {b,a,a}, {b,a,a},

--         {a,b,a}, {b,b,a}, {b,b,a},
--         {a,b,a}, {a,b,b}, {a,b,b},
--         {b,b,b}, {a,b,b}, {a,b,b},
--         {b,b,b}, {b,b,a}, {b,b,a},

--         {a,a,a}, {a,b,a}, {a,b,a},
--         {b,a,a}, {b,b,a}, {b,b,a},
--         {a,a,b}, {a,b,b}, {a,b,b},
--         {b,a,b}, {b,b,b}, {b,b,b},
--     }
-- end
-- local floor = math.floor
-- local grid_model = g3d.newModel(CUBE, nil, nil,nil, 1.001)
local aabb_model = g3d.newModel(CUBE)
aabb_model:generateAABB()

local change_index = 0
local undo_list = {}
local redo_list = {}
local cube_count = 0
local model

local function add_change(tab)--{cmd,index,texture}
    local string = table.concat(tab, ',')--string.format("%s,%s,%s",cmd,index,texture)
    redo_list = {}
    change_index = change_index+1
    undo_list[change_index] = string
end

local Scene = {
    cubes = {},
    -- alpha_ids = {},
    palette_count = 0,
    texture_count = 0,
}

--This function was taken from the g3d_voxel demo and franksteined here
--[https://github.com/groverburger/g3d_voxel/blob/master/lib/chunkremesh.lua]
local function remesh()
    local index = 1
    local verts = {}
    local function addFace(x,y,z, mx,my,mz, u,v, flip)
        for i=1, 6 do
            local df = 0.001 --this variable here prevents texture bleeding
            local pu = 1/8 - df
            local pv = 1/16 - df
            local primary = i%2 == (flip and 0 or 1)
            local secondary = i > 2 and i < 6
            verts[index] = {}
            verts[index][1]  = x + (mx == 1 and primary and 1 or 0) + (mx == 2 and secondary and 1 or 0)
            verts[index][2]  = y + (my == 1 and primary and 1 or 0) + (my == 2 and secondary and 1 or 0)
            verts[index][3]  = z + (mz == 1 and primary and 1 or 0) + (mz == 2 and secondary and 1 or 0)
            verts[index][4]  = u + (primary   and pu or df)
            verts[index][5]  = v + (secondary and df or pv)
            verts[index][6]  = 0
            verts[index][7]  = 0
            verts[index][8]  = 1
            verts[index][9]  = 255
            verts[index][10] = 255
            verts[index][11] = 255
            verts[index][12] = 255
            index = index+1
        end
    end

    for _,cube in pairs(Scene.cubes) do
        local x,y,z = cube.position[1], cube.position[2], cube.position[3]
        local u,v = unpack(cube.uv)
        u = u/8
        v = v/16
        if not Scene:get_cube( {x-1,y,z}) then addFace(x,y,z,   0,1,2, u,v) end --front
        if not Scene:get_cube( {x,y+1,z}) then addFace(x,y+1,z, 1,0,2, u,v) end --left
        if not Scene:get_cube( {x,y,z-1}) then addFace(x,y,z,   1,2,0, u,v) end --botton
        
        if not Scene:get_cube( {x+1,y,z}) then addFace(x+1,y,z, 0,1,2, u,v, true) end --back
        if not Scene:get_cube( {x,y-1,z}) then addFace(x,y,z,   1,0,2, u,v, true) end --right
        if not Scene:get_cube( {x,y,z+1}) then addFace(x,y,z+1, 1,2,0, u,v, true) end --top

    end
    model = g3d.newModel(verts, APP.atlas, {-0.5,-0.5,-0.5})
    model:makeNormals()
end
local add = function(index, texture_id, position)
    local itype, ipos = From_id(texture_id)
    
    if itype=="color" then 
        Scene.palette_count = Scene.palette_count+1
        ipos[2] = ipos[2]+8
    else
        Scene.texture_count = Scene.texture_count+1
    end
    -- if(a==7)then Scene.alpha_ids[index] = true end
    
    Scene.cubes[index] = {uv = ipos, texture_index = texture_id, position = position}
    cube_count = cube_count+1
    remesh()
    return true
end
local remove = function(index)-- beware of the bug!
    local itype,_ = From_id(Scene.cubes[index].texture_index)
    if itype=="color" then
        Scene.palette_count = Scene.palette_count-1
    else
        Scene.texture_count = Scene.texture_count-1
    end
    cube_count = cube_count-1
    -- if Scene.alpha_ids[index] then Scene.alpha_ids[index] = nil end
    Scene.cubes[index] = nil
    remesh()
end
local function paint(index, texture_id)
    local itype, ipos = From_id(texture_id)
    local old_tex_index = Scene.cubes[index].texture_index

    if itype=="texture" then
        if APP.palette[old_tex_index] then
            Scene.texture_count = Scene.texture_count+1
            Scene.palette_count = Scene.palette_count-1
        end
    else
        ipos[2] = ipos[2]+8
        if APP.texture[old_tex_index] then
            Scene.texture_count = Scene.texture_count-1
            Scene.palette_count = Scene.palette_count+1
        end
    end
    -- if(a==7)then Scene.alpha_ids[index] = true end
    Scene.cubes[index].texture_index = texture_id
    Scene.cubes[index].uv = ipos

    remesh()

    return true
end

Scene.clear=function(self)
    --reset all
    self.cubes = {}
    self.redo_list = {}
    self.undo_list = {}
    change_index = 0
    -- self.alpha_ids = {}
    self.palette_count = 0
    self.texture_count = 0
end

Scene.new=function(self)
    self:clear()
    local id = "translation 0:0:0"
    local texture_id = "color 0:0"

    add(id, texture_id, {0,0,0})
    remesh()
    cube_count = 1
end
Scene.load_file=function(self, data)
    --reset all
    self:clear()
    self.palette_count = data.palette_count
    self.texture_count = data.texture_count
    

    for i,k in ipairs(data.cubes) do
        local id = To_id("translation", k.position)
        local itype, ipos = From_id(k.texture_index)
        -- local id_type = Id_type(k.texture_index)
        
        if itype=="color" then
            ipos[2] = ipos[2]+8
        end
        
        self.cubes[id] = {uv = ipos, texture_index = k.texture_index, position = k.position}
    end
    cube_count = #data.cubes
    remesh()
end
Scene.refresh = function(self)
    remesh()
end

Scene.add_cube = function(self, texture_id, position)
    local index = To_id("translation", position)
    if self.cubes[index] then return false end
    
    add_change( {"add",index,texture_id})
    return add(index, texture_id, position) 
end
Scene.remove_cube = function(self, id)
    if cube_count==1 then return false end
    -- print(cube_count)
    local index
    if type(id)=="string" then
        index = id
    elseif type(id)=="table" then
        index = To_id("translation", id)
    else
        return false
    end

    local texture_id = ""..tostring(self.cubes[index].texture_index)
    add_change({"remove",index,texture_id})
    remove(index)
    
    return true
end
Scene.get_cube = function(self,id)
    local index
    if type(id)=="string" then
        index = id
    elseif type(id)=="table" then
        index = To_id("translation", id)
    else
        return false
    end
    return self.cubes[index]
end
Scene.paint_cube = function(self, id, tab)
    local index
    if type(id)=="string" then
        index = id
    elseif type(id)=="table" then
        index = To_id("translation", id)
    else
        return false
    end
    if not self.cubes[index] then return false end

    if tab.texture and tab.texture~=self.cubes[index].texture_index then
        add_change({"paint",index, tab.texture, self.cubes[index].texture_index})
        return paint(index, tab.texture)
    end
end
Scene.redo = function(self)
    local string, ni
    for i=1,#redo_list do
        if redo_list[i].c_index == change_index+1 then
            string = redo_list[i].string
            ni = i
        end
    end
    if not string then return end

    change_index = change_index+1

    local op = {}

    for str in string.gmatch(string, '([^,]+)') do
        table.insert(op,str)
    end

    if op[1] == "remove" then--remove
        remove(op[2])
    elseif op[1] == "add" then--add
        local itype, ipos = From_id(op[2])
        add(op[2], op[3], ipos)
    elseif op[1] == "paint" then--paint
        paint(op[2], op[3])
    end

    undo_list[change_index] = string
    table.remove(redo_list, ni)
end
Scene.undo = function(self)
    if not undo_list[change_index] then return end

    local op = {}

    for str in string.gmatch(undo_list[change_index], '([^,]+)') do
        table.insert(op,str)
    end

    if op[1] == "add" then--remove
        remove(op[2])
    elseif op[1] == "remove" then--add
        local itype, ipos = From_id(op[2])
        add(op[2], op[3], ipos)
    elseif op[1] == "paint" then--paint
        paint(op[2], op[4])
    end

    table.insert(redo_list, {c_index = change_index, string = table.remove(undo_list)})
    change_index = math.max(0, change_index-1)
end
Scene.cast_ray = function(self, ox, oy, oz, tx, ty, tz)
    -- return false
    local m = math.huge
    local n, p
    for i,k in pairs(self.cubes) do
        aabb_model:setTranslation(unpack(k.position))
        -- k.highlight = false
        local d,x,y,z = aabb_model:rayIntersectionAABB(ox, oy, oz, tx, ty, tz )
        if d and d<m then
            m = d
            p = {x,y,z}
            n = i
        end
    end
    return n, p
end
Scene.draw = function(self)
    local s = APP.toggle.light and APP.shader
    local t = APP.toggle.texture
    local g = APP.toggle.grid
    
    -- for i,k in pairs(self.cubes) do

        -- love.graphics.setColor(1,1,1)
        -- if t then-- and not self.alpha_ids[i]then
        --     k:draw(s)
        -- end
        
        -- love.graphics.setColor(0,0,0)
    if g then
        love.graphics.setColor(0,0,0)
        love.graphics.setWireframe(true)
        model:draw( )
        love.graphics.setWireframe(false)
    end
    -- end
    if t then
        love.graphics.setColor(1,1,1)
        model:draw(s )
    end
    -- for i,k in pairs(self.alpha_ids) do
    --     love.graphics.setColor(1,1,1)
    --     self.cubes[i]:draw( )
    -- end
end

return Scene