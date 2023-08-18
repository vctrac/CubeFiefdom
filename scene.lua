
local function hex2rgb(hex, alpha) 
	local redColor,greenColor,blueColor=hex:match('ff?(..)(..)(..)')
	redColor, greenColor, blueColor = tonumber(redColor, 16)/255, tonumber(greenColor, 16)/255, tonumber(blueColor, 16)/255
	redColor, greenColor, blueColor = math.floor(redColor*100)/100, math.floor(greenColor*100)/100, math.floor(blueColor*100)/100
	if alpha == nil then
		return redColor, greenColor, blueColor
	end
	return redColor, greenColor, blueColor, alpha
end

local function Image_from_quad(source, x,y,w,h)
    local nid = love.image.newImageData(w, h)
    nid:paste(source, 0, 0, x, y, w, h)

    return love.graphics.newImage(nid)
end

local select_model = g3d.newModel(CUBE, love.graphics.newImage("image/select.png"), nil,nil, 1.01)
local grid_model = g3d.newModel(CUBE, nil, nil,nil, 1.001)
-- local data
local change_index = 0
local undo_list = {}
local redo_list = {}
local cube_count = 0

local function add_change(tab)--cmd,index,texture)
    local string = table.concat(tab, ',')--string.format("%s,%s,%s",cmd,index,texture)
    redo_list = {}
    change_index = change_index+1
    undo_list[change_index] = string
    print(string)
end

local Scene = {
    cubes = {},
    -- alpha_ids = {},
    palette_ids = {},
    palette_count = 0,
    texture_count = 0,
}

Scene.clear=function(self, data)
    --reset all
    self.cubes = {}
    self.redo_list = {}
    self.undo_list = {}
    change_index = 0
    -- self.alpha_ids = {}
    self.palette_ids = {}
    self.palette_count = 1
    self.texture_count = 0

    local id = "0:0:0"
    local texture_id = "1:1:1"

    -- if not APP.palette[texture_id] then
    --     APP.add_color(1,1,1)
    -- end
    -- self.palette_ids[id] = true
    self.cubes[id] = g3d.newModel(CUBE, APP.palette["color 0:0"], {0,0,0})
    cube_count = 1
end
Scene.load_file=function(self, data)
    --reset all
    self.cubes = {}
    self.redo_list = {}
    self.undo_list = {}
    -- self.alpha_ids = {}
    self.palette_ids = {}
    self.palette_count = 0
    self.texture_count = 0

    -- data = parse_cko(filename)
    local image1, image2
    local lastColor = ""
    local last_tex = ""

    if data.palette then
        self.palette_count = data.palette_count
    --     image1 = love.image.newImageData(16,16)
    end
    if data.texture then
        -- image2 = love.image.newImageData("image/"..data.texture_file)
        self.texture_file = data.texture_file
        self.texture_count = data.texture_count
        APP.load_texture(data.texture_file)
    else
        APP.load_texture("tex.png")
    end

    for i,k in ipairs(data.cubes) do
        local texture, texture_id
        local position = {k[1]-100, k[3]-100, k[2]-100}
        local id = To_id("translation", position)
        
        if k[5] then
            texture_id = To_id("texture", {k[4],k[5]})
            if not APP.textures[texture_id] then
                print(texture_id)
                APP.add_quad(texture_id, k[4], k[5])
            end
            -- if k[5]==7 then
                -- self.alpha_ids[id] = true
            -- end
            texture = APP.textures[texture_id]
        -- else
            -- local 
            -- texture_id = k[4]
            -- APP.add_color(From_id(texture_id))
            -- self.palette_ids[id] = true
            -- texture = APP.palette[texture_id]
        end
        
        self.cubes[id] = g3d.newModel(CUBE, texture, position)
        self.cubes[id].texture_index = texture_id
    end
    cube_count = #data.cubes
end
local add = function(index, texture_id, position)
    local _,a = From_id(texture_id)
    -- print(_,a)
    local material
    if APP.palette[texture_id] then 
        material = 'palette'
        Scene.palette_count = Scene.palette_count+1
        Scene.palette_ids[index] = true
    else
        material = 'textures'
        Scene.texture_count = Scene.texture_count+1
    end
    -- if(a==7)then Scene.alpha_ids[index] = true end
    Scene.cubes[index] = g3d.newModel(CUBE, APP[material][texture_id], position)
    Scene.cubes[index].texture_index = texture_id
    cube_count = cube_count+1
    return true
end
local remove = function(index)-- there is a bug somewhere around here!
    -- print(index, Scene.alpha_ids[index])
    if APP.palette[Scene.cubes[index].texture_index] then
        Scene.palette_count = Scene.palette_count-1
        Scene.palette_ids[index] = nil
    else
        Scene.texture_count = Scene.texture_count-1
    end
    cube_count = cube_count-1
    -- if Scene.alpha_ids[index] then Scene.alpha_ids[index] = nil end
    Scene.cubes[index] = nil
end
Scene.add_cube = function(self, texture_id, position)
    local index = To_id("translation", position)
    if self.cubes[index] then return false end
    
    add_change( {"add",index,texture_id})
    return add(index, texture_id, position) 
end
Scene.remove_cube = function(self, id)
    if cube_count==1 then return false end
    print(cube_count)
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
local function paint(index, texture)
    local _,a = From_id(texture)
    local material = APP.palette[texture] and 'palette' or 'textures'
    if APP.palette[Scene.cubes[index].texture_index]~=APP.palette[texture] then
        if material=="palette" then
            Scene.palette_count = Scene.palette_count+1
            Scene.texture_count = Scene.texture_count-1
            Scene.palette_ids[index] = true
        else
            Scene.palette_count = Scene.palette_count-1
            Scene.texture_count = Scene.texture_count+1
            Scene.palette_ids[index] = nil
        end
    end

    -- if(a==7)then Scene.alpha_ids[index] = true end
    Scene.cubes[index].texture_index = texture
    Scene.cubes[index].mesh:setTexture(APP[material][texture])
    return true
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
        -- print(self.cubes[index].texture_index)
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
        add(op[2], op[3], {From_id(op[2])})
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
    print(undo_list[change_index])
    if op[1] == "add" then--remove
        remove(op[2])
    elseif op[1] == "remove" then--add
        add(op[2], op[3], {From_id(op[2])})
    elseif op[1] == "paint" then--paint
        paint(op[2], op[4])
    end

    table.insert(redo_list, {c_index = change_index, string = table.remove(undo_list)})
    change_index = math.max(0, change_index-1)
end
Scene.cast_ray = function(self, ox, oy, oz, tx, ty, tz)
    local m = math.huge
    local n, p
    for i,k in pairs(self.cubes) do
        k.highlight = false
        local d,x,y,z = k:rayIntersectionAABB(ox, oy, oz, tx, ty, tz )
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
    
    for i,k in pairs(self.cubes) do

        love.graphics.setColor(1,1,1)
        if t then-- and not self.alpha_ids[i]then
            k:draw(s)
        end
        if k.highlight then
            select_model:setTranslation(unpack(k.translation))
            select_model:draw(s)
        end
        if g then
            love.graphics.setColor(0,0,0)
            grid_model:setTranslation(unpack(k.translation))
            love.graphics.setWireframe(true)
            grid_model:draw(s)
            love.graphics.setWireframe(false)
        end
    end

    -- for i,k in pairs(self.alpha_ids) do
    --     love.graphics.setColor(1,1,1)
    --     self.cubes[i]:draw( )
    -- end
end

return Scene