if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end  


----
local lg = love.graphics
--------------------------------------------------------------------------------------
-- ######## ##     ## ##    ##  ######  ######## ####  #######  ##    ##  ######  
-- ##       ##     ## ###   ## ##    ##    ##     ##  ##     ## ###   ## ##    ## 
-- ##       ##     ## ####  ## ##          ##     ##  ##     ## ####  ## ##       
-- ######   ##     ## ## ## ## ##          ##     ##  ##     ## ## ## ##  ######  
-- ##       ##     ## ##  #### ##          ##     ##  ##     ## ##  ####       ## 
-- ##       ##     ## ##   ### ##    ##    ##     ##  ##     ## ##   ### ##    ## 
-- ##        #######  ##    ##  ######     ##    ####  #######  ##    ##  ######  
--------------------------------------------------------------------------------------

local function sign(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
end

--creates a new linear tween variable
local function val(vt)
    local t = setmetatable({v = vt, t= vt},{
        __call =function(self) return self.v end,
        __add = function(self, n)
            self.t = self.t + n
            return self
        end,
        __sub = function(self, n)
            self.t = self.t - n
            return self
        end
    })
    t.update = function(self, magnitude, dt)
        local v = self.v
        local t = self.t
        if t~=v then
            self.v = v-(v-t)*magnitude*dt
            if math.abs(t-v)<0.001 then
                self.v=t
            end
        end
    end
    return t
end
----temp
local function rc(n,x)
    local min,max = n or 1, x or 9
    return math.random(min, max)*0.1, math.random(min, max)*0.1, math.random(min, max)*0.1, 1
end
local function rnd_texture()
    local image1 = love.image.newImageData(16,16)
    local nr,ng,nb,na = rc(3,8)
    image1:mapPixel(function(x,y,r,g,b,a) return nr,ng,nb,na end)
    return lg.newImage(image1)
end

--convert a quad from an imageData to a drawable image
local function Image_from_quad(source, x,y,w,h)
    local nid = love.image.newImageData(w, h)
    nid:paste(source, 0, 0, x, y, w, h)

    return lg.newImage(nid)
end

function hex2rgb(hex)
	hex = hex:gsub("ff","",1)
    local r = tonumber("0x"..hex:sub(1,2))/255
    local g = tonumber("0x"..hex:sub(3,4))/255
    local b = tonumber("0x"..hex:sub(5,6))/255
    -- return tonumber(string.format("%.3f",r)),tonumber(string.format("%.3f",g)),tonumber(string.format("%.3f",b))
    return math.floor(r*1000)*0.001, math.floor(g*1000)*0.001, math.floor(b*1000)*0.001
end

function rgb2hex(r,g,b)
    return string.format("ff%02X%02X%02X",r*255,g*255,b*255)
end
-- local function hex2rgb(hex, alpha) 
-- 	local redColor,greenColor,blueColor=hex:match('ff?(..)(..)(..)')
-- 	redColor, greenColor, blueColor = tonumber(redColor, 16)/255, tonumber(greenColor, 16)/255, tonumber(blueColor, 16)/255
-- 	redColor, greenColor, blueColor = math.floor(redColor*1000)/1000, math.floor(greenColor*1000)*0.001, math.floor(blueColor*1000)*0.001
-- 	if alpha == nil then
-- 		return redColor, greenColor, blueColor
-- 	end
-- 	return redColor, greenColor, blueColor, alpha
-- end

-- local hex = "ffda0025"
-- local r,g,b = hex2rgb(hex)
-- local r,g,b = HexToRGB(hex)
-- print("hex:",hex)
-- print("r,g,b:",r,g,b)
-- print("hex2", rgb2hex(r,g,b))
---prints the filename and linenumber of where it was called from
local old_print = print
function print( ...)
    local info = debug.getinfo(2,"Sl");
    -- local str  = info.source:match('%w+[^.lua]',2)
    local filename  = info.source:match("(.+)%..+$",2) --removes file extension/ everything after the dot
    old_print(string.format("%s %d >",filename, info.currentline), ...)
end
--same as before, but formated
function printf( s, ...)
    local fs = string.format(s, ...)
    local info = debug.getinfo(2,"Sl")
    local filename  = info.source:match("(.+)%..+$",2)
    old_print(string.format("%s %d : %s",filename, info.currentline, fs))
end

function To_id(prefix, coords)
    local id = table.concat(coords,':')

    return string.format("%s %s",prefix, id)
    -- return string.format("%d:%d:%d", unpack(pos))
end
function From_id(id)
    print(id)
    -- local id_type = id:match("(.*) ")
    local sid = id:match(" (.*)")
    local t = {}
    for num in string.gmatch(sid, '([^:]+)') do
        table.insert(t,tonumber(num))
    end
    return unpack(t)--,id_type
end
function Id_type(id)
    return id:match("(.*) ")
end
--------------------------------------------------------------------------------------
--  ######   ##        #######  ########     ###    ##       
-- ##    ##  ##       ##     ## ##     ##   ## ##   ##       
-- ##        ##       ##     ## ##     ##  ##   ##  ##       
-- ##   #### ##       ##     ## ########  ##     ## ##       
-- ##    ##  ##       ##     ## ##     ## ######### ##       
-- ##    ##  ##       ##     ## ##     ## ##     ## ##       
--  ######   ########  #######  ########  ##     ## ######## 
--------------------------------------------------------------------------------------
-- print( love.filesystem.getWorkingDirectory( ))

require 'library.lovefs'
cpml = require"library.cpml"
require"library.g3d"

CUBE = "model/cube.obj" --default cube model, single cube projected texture
DICE = "model/dice.obj" --alternative cube model, six sides spritesheet texture

lg.setDefaultFilter("nearest", "nearest")

IMAGE = {
    atlas = lg.newImage("image/tex.png"),
    circle = lg.newImage("image/circle.png"),
    center = lg.newImage("image/center.png"),
    new_text = lg.newImage("image/new_text.png"),
    button_frame = lg.newImage("image/button_frame.png"),
    pencil = lg.newImage("image/pencil.png"),
    brush = lg.newImage("image/brush.png"),
    rotate = lg.newImage("image/rotate.png"),
    light_on = lg.newImage("image/light.png"),
    light_off = lg.newImage("image/light_off.png"),
    grid_on = lg.newImage("image/grid.png"),
    texture_on = lg.newImage("image/texture.png"),
    redo = lg.newImage("image/redo.png"),
    undo = lg.newImage("image/undo.png"),
}
IMAGE.grid_off = IMAGE.grid_on
IMAGE.texture_off = IMAGE.texture_on
IMAGE.undo_off = IMAGE.undo
IMAGE.redo_off = IMAGE.redo
-- 
local tile_size = 16
APP = {
    toggle = {light=true, grid=false, texture=true},
    shader = lg.newShader(g3d.shaderpath, "shader/lighting.frag"),
    atlas = nil,
    textures = {},
    palette = {},
    first_person_view = false,
}
function APP.load_texture(filename)
    APP.atlas_data = love.image.newImageData("image/"..filename)
    APP.atlas = lg.newImage(APP.atlas_data)
    local iw,ih = APP.atlas:getDimensions()
    for x=0,math.floor(iw/tile_size)-1 do
        for y=0,math.floor(ih/tile_size)-1 do
            local id = To_id("texture", {x,y})
            APP.textures[id] = Image_from_quad( APP.atlas_data, x*tile_size,y*tile_size,tile_size,tile_size)
        end
    end
end
function APP.add_quad(id, x, y)
    APP.textures[id] = Image_from_quad( APP.atlas, x*tile_size,y*tile_size,tile_size,tile_size)
end
-- function APP.add_color_old(id)
--     if APP.palette[id] then return false end
--     local nr,ng,nb = hex2rgb(id)
--     local image_data = love.image.newImageData(1,1)
--     image_data:setPixel(0,0,nr,ng,nb)
--     -- image_data:mapPixel(function(x,y,r,g,b,a) return nr,ng,nb end)
--     APP.palette[id] = lg.newImage(image_data)
--     return true
--     -- print(id)
-- end
function APP.add_color(coords, color)
    local id = To_id("color", coords)
    if APP.palette[id] then return false end

    local image_data = love.image.newImageData(1,1)
    image_data:setPixel(0,0,unpack(color))
    APP.palette[id] = lg.newImage(image_data)

    return id
end
-- function APP.load_palette(filename)
--     local plt = {}--require(filename)
--     for l in io.lines(filename) do
-- 		-- table.insert(plt, l)
--         APP.add_color(l)
-- 	end
    -- local image_data = love.image.newImageData(8,8)
    -- local x,y = 0,0
    -- for _,hex in ipairs(plt) do

        -- APP.add_color(hex)
        -- if APP.add_color(hex) then
            -- local r,g,b = hex2rgb(hex)
            -- local color = {r,g,b}
            -- image_data:setPixel(x,y,r,g,b)
            -- x=x+1
            -- if x>7 then
                -- x,y=0,y+1
            -- end
        -- end
        -- print(hex)
    -- end
    -- APP.palette_atlas = lg.newImage(image_data)
    -- image_data:mapPixel(function(x,y,r,g,b,a) return nr,ng,nb end)
-- end

--------------------------------------------------------------------------------------
-- ##        #######   ######     ###    ##       
-- ##       ##     ## ##    ##   ## ##   ##       
-- ##       ##     ## ##        ##   ##  ##       
-- ##       ##     ## ##       ##     ## ##       
-- ##       ##     ## ##       ######### ##       
-- ##       ##     ## ##    ## ##     ## ##       
-- ########  #######   ######  ##     ## ######## 
--------------------------------------------------------------------------------------

local vec2 = cpml.vec2
local vec3 = cpml.vec3
local camera = g3d.camera
local Inky = require"library.inky"
local Cube_map = require"scene"

local select_model, use-- = g3d.newSprite("image/use.png",{scale = 0.5})

local Key = {
    ctrl = false,
    alt = false
}
local mouse = {
    old_x = 0,
    old_x = 0,
    active = false,
    selected = {
        pos = vec3(),
        new = vec3(),
        id = "",
    },
    tool = "pencil",
    texture = "texture 0:0",
    color = "color 0:0",
    texture_type = "texture",
    set_texture = function(self, texture_index)
        local it = Id_type(texture_index)
        self[it] = texture_index
        self.texture_type = it
        select_model.mesh:setTexture(APP[it == "color" and "palette" or "textures"][texture_index])
    end
}

---@return vec3:result or false
local function get_side(pos, npos)
    -- local kp = vec3(Cube_map.cubes[id].translation)
    local dif = (pos-npos)*2
    --converted to string to avoid float point precision problems
    local st = (dif:abs()):to_string_table()

    local result = vec3(0,0,0)
    if st.x=='1' then
        result.x = sign(dif.x)
    elseif st.y=='1' then
        result.y = sign(dif.y)
    elseif st.z=='1' then
        result.z = sign(dif.z)
    else
        print("shit happens!")
    end
    if not(result==vec3.zero) then
        return npos+result
    end
    return npos
end

local cam = {
    theta = val(90),
    phi = val(35),
    offset = val(10),
}

local ZOOM_MAX = 25
local ZOOM_MIN = 0.5

local pivot = {
    x=0, y=0, z=0,
    speed = 5,
    angle = 0,
    model = nil
}
local function pivot_movement(dt)
    local moveX, moveY = 0,0
    if love.keyboard.isDown "a" then moveX = moveX - 1 end
    if love.keyboard.isDown "w" then moveY = moveY - 1 end
    if love.keyboard.isDown "d" then moveX = moveX + 1 end
    if love.keyboard.isDown "s" then moveY = moveY + 1 end
    if love.keyboard.isDown "space" then
        pivot.z = pivot.z - pivot.speed*dt
        pivot.model:setTranslation(pivot.x,pivot.y,pivot.z)
    end
    if love.keyboard.isDown "c" then
        pivot.z = pivot.z + pivot.speed*dt
        pivot.model:setTranslation(pivot.x,pivot.y,pivot.z)
    end

    if moveX ~= 0 or moveY ~= 0 then
        local angle = math.atan2(moveY, moveX)
        local dir = math.rad(cam.theta()) + angle
        pivot.x = pivot.x + math.cos(dir) * pivot.speed * dt
        pivot.y = pivot.y - math.sin(dir) * pivot.speed * dt

        pivot.model:setTranslation(pivot.x,pivot.y,pivot.z)
    end
end
--------------------------------------------------------------------------------------
-- ##     ## ##     ## ########  
-- ##     ## ##     ## ##     ## 
-- ##     ## ##     ## ##     ## 
-- ######### ##     ## ##     ## 
-- ##     ## ##     ## ##     ## 
-- ##     ## ##     ## ##     ## 
-- ##     ##  #######  ########  
--------------------------------------------------------------------------------------
-- local Button = require"ui.button"
local tools_button_size = 22
local bar_height = 14
local hud = {
    scene   = Inky.scene(),
    window_pos = cpml.quat(10,10,tile_size*8+4,600),
    tools = { },
    palette = { },
    textures = { },
    current_texture = nil,
    current_color = nil,
    colors = {
        on   = {1,1,1,0.75},
        off  = {0.5,0.5,0.5,0.75},
        on_over = {1,1,1,1},
        off_over = {0.8,0.8,0.8,1},
        click = {1,1,0,1},
    },
    atlas_pos = {0,0}
}
-- local 

hud.pointer = Inky.pointer(hud.scene)
local window = Inky.defineElement(function(self)
    return function(_, x, y, w, h)
        lg.setColor(0.5,0.5,0.7)
        lg.rectangle("fill",x,y,w,h)
        lg.setColor(0.2,0.2,0.2)
        lg.rectangle("line",x,y,w,h)
    end
end)
hud.window = window(hud.scene)

local window_bar = Inky.defineElement(function(self)
    self.props.grab = false
    self.props.gpx = 0
    self.props.gpy = 0
    self:onPointer("release", function(self)
        self.props.grab = false
    end)
    self:onPointer("press", function(self)
        self.props.grab = true
        local mx,my = love.mouse.getPosition()
        self.props.gpx = mx - hud.window_pos.x
        self.props.gpy = my - hud.window_pos.y
    end)
    return function(_, x, y, w, h)
        if self.props.grab then
            lg.setColor(0.3,0.3,0.3)
        else
            lg.setColor(0.2,0.2,0.2)
        end
        lg.rectangle("fill",x,y,w,h)
        lg.setColor(1,1,1)
        lg.printf("tools",x,y,w,"center")
    end
end)
hud.window_bar = window_bar(hud.scene)
local tx,ty = 2, bar_height+2

local function radio_button_new(name,xx,yy)
    local button = Inky.defineElement(function(self)
        self:onPointerEnter(function(self, pointer, ...)
            self.props.color ="on_over"
        end)
        self:onPointerExit(function(self, pointer, ...)
            self.props.color = mouse.tool==name and "on" or "off"
        end)
        self:onPointer("release", function(self)
            self.props.setActiveKey(self.props.key)
            -- self.props.color = "on"
        end)
        self:onPointer("press", function(self)
            self.props.color = "click"
        end)
        return function(_, x, y, w, h)
            lg.setColor(hud.colors[self.props.color])
            lg.draw(IMAGE.button_frame, x, y)
            lg.setColor(1,1,1)
            lg.draw(IMAGE[name], x, y)
        end
    end)
    hud.tools[name] = button(hud.scene)
    hud.tools[name].props.key = name
    hud.tools[name].props.color = mouse.tool==name and "on" or "off"
    hud.tools[name].props.x = xx
    hud.tools[name].props.y = yy
end

radio_button_new("pencil",tx,ty)
tx = tx+tools_button_size
radio_button_new("brush",tx,ty)
tx = tx+tools_button_size
radio_button_new("rotate",tx,ty)
tx = 2
ty = ty+tools_button_size

local function setToolActiveKey(key)
    for _,tool in pairs(hud.tools) do
        tool.props.color = (tool.props.key==key) and "on" or "off"
        tool.props.activeKey = key
    end
    mouse.tool = key
end
for _,tool in pairs(hud.tools) do
    tool.props.setActiveKey = setToolActiveKey
end

local function toggle_button_new(name, xx, yy)
    local button = Inky.defineElement(function(self)
        self.props.state = APP.toggle[name] and "_on" or "_off"
        self.props.color = APP.toggle[name] and "on" or "off"

        self:onPointerEnter(function(self, pointer, ...)
            self.props.color = (APP.toggle[name] and "on" or "off").."_over"
        end)
        self:onPointerExit(function(self, pointer, ...)
            self.props.color = APP.toggle[name] and "on" or "off"
        end)
        self:onPointer("release", function(self)
            APP.toggle[name] = not APP.toggle[name]
            self.props.state = APP.toggle[name] and "_on" or "_off"
            self.props.color = (APP.toggle[name] and "on" or "off").."_over"
        end)
        self:onPointer("press", function(self)
            self.props.color = "click"
        end)
        return function(_, x, y, w, h)
            lg.setColor(hud.colors[self.props.color])
            lg.draw(IMAGE.button_frame, x, y)
            lg.setColor(1,1,1)
            lg.draw(IMAGE[name..self.props.state], x, y)
        end
    end)
    hud.tools[name] = button(hud.scene)
    hud.tools[name].props.x = xx
    hud.tools[name].props.y = yy
end
-- local button_size = 22

toggle_button_new("light", tx, ty)
tx = tx+tools_button_size
toggle_button_new("texture", tx, ty)
tx = tx+tools_button_size
toggle_button_new("grid", tx, ty)

local function edit_button_new(name, xx, yy)
    local button = Inky.defineElement(function(self)
        self.props.color = "off"
        self:onPointerEnter(function(self, pointer, ...)
            self.props.color ="on"
        end)
        self:onPointerExit(function(self, pointer, ...)
            self.props.color = "off"
        end)
        self:onPointer("release", function(self)
            Cube_map[name](Cube_map)
            self.props.color = "on"
        end)
        self:onPointer("press", function(self)
            self.props.color = "click"
        end)
        return function(_, x, y, w, h)
            lg.setColor(hud.colors[self.props.color])
            lg.draw(IMAGE.button_frame, x, y)
            lg.setColor(1,1,1)
            lg.draw(IMAGE[name], x, y)
        end
    end)
    hud.tools[name] = button(hud.scene)
    hud.tools[name].props.x = xx
    hud.tools[name].props.y = yy
end
tx = tx+tools_button_size
edit_button_new("undo", tx, ty)
tx = tx+tools_button_size
edit_button_new("redo", tx, ty)
ty = ty + tools_button_size + 5
tx = 2
local label_bar = Inky.defineElement(function(self)
    return function(_, x, y, w, h)
        lg.setColor(0.2,0.2,0.2)
        lg.rectangle("fill",x,y,w,h)
        lg.setColor(1,1,1)
        lg.printf(self.props.text,x,y,w,"center")
    end
end)

hud.palette_label = label_bar(hud.scene)
hud.palette_label.props.text = "Palette"
hud.palette_label.props.x = 0
hud.palette_label.props.y = ty
ty = ty + bar_height + 2
hud.palette_pos = {tx,ty}
ty = ty +136
local function show_color(name,xx,yy)

    local button = Inky.defineElement(function(self)
        
        return function(_, x, y, w, h)
            lg.setColor(0,0,0,0.5)
            lg.rectangle("fill", x-1,y-1,w+2,h+2)
            lg.setColor(1,1,1)
            lg.draw(APP.palette[mouse.color],x,y,0, w, h)
        end
    end)

    hud.current_color = button(hud.scene)
    hud.current_color.props.x = xx
    hud.current_color.props.color = name
    hud.current_color.props.y = yy
end

show_color(mouse.color, tx,ty)
ty = ty+ 160
local function new_color_button(name,xx,yy)
    local button = Inky.defineElement(function(self)
        self.props.active = false
        self:onPointerEnter(function(self, pointer, ...)
            self.props.active = true
        end)
        self:onPointerExit(function(self, pointer, ...)
            self.props.active = false
        end)
        self:onPointer("release", function(self)
            mouse:set_texture(name)
        end)
        return function(_, x, y, w, h)
            if self.props.active then
                lg.setColor(0,0,0,1)
                local s = tile_size*1.5
                local s2 = tile_size*0.25
                lg.rectangle("fill", x-s2-1,y-s2-1,s+2,s+2)
                lg.setColor(1,1,1)
                -- print("dfsf")
                lg.draw(APP.palette[name],x-s2,y-s2,0,s,s)
                -- lg.draw(APP.palette[name],x,y,0,s,s)
            end
        end
    end)
    
    -- local xx,yy = From_id(name)

    hud.palette[name] = button(hud.scene)
    hud.palette[name].props.x = hud.palette_pos[1]+xx*tile_size
    hud.palette[name].props.y = hud.palette_pos[2]+yy*tile_size
end

hud.texture_label = label_bar(hud.scene)
hud.texture_label.props.text = "Texture"
hud.texture_label.props.x = 0
hud.texture_label.props.y = ty
ty = ty + bar_height + 2
hud.atlas_pos = {tx,ty}
local function new_texture_button(name)

    local button = Inky.defineElement(function(self)
        self.props.active = false
        self:onPointerEnter(function(self, pointer, ...)
            self.props.active = true
        end)
        self:onPointerExit(function(self, pointer, ...)
            self.props.active = false
        end)
        self:onPointer("release", function(self)
            mouse:set_texture(name)
        end)
        return function(_, x, y, w, h)
            if self.props.active then
                lg.setColor(0,0,0,0.5)
                local s = 1.5
                local sp = tile_size*0.25
                lg.rectangle("fill", x-sp-1,y-sp-1,w*s+2,h*s+2)
                lg.setColor(1,1,1)
                lg.draw(APP.textures[name],x-sp,y-sp,0,s,s)
            end
        end
    end)
    
    local xx,yy = From_id(name)

    hud.textures[name] = button(hud.scene)
    hud.textures[name].props.x = hud.atlas_pos[1]+xx*tile_size
    hud.textures[name].props.y = hud.atlas_pos[2]+yy*tile_size
end
-- local iw,ih = APP.atlas_data:getDimensions()
ty = ty +128
local function show_texture(name,xx,yy)

    local button = Inky.defineElement(function(self)
        
        return function(_, x, y, w, h)
            lg.setColor(0,0,0,0.5)
            lg.rectangle("fill", x-1,y-1,w+2,h+2)
            lg.setColor(1,1,1)
            lg.draw(APP.textures[mouse.texture],x,y,0,4,4)
        end
    end)

    hud.current_texture = button(hud.scene)
    hud.current_texture.props.x = xx
    -- hud.current_texture.props.texture = name
    hud.current_texture.props.y = yy
end
show_texture(mouse.texture, 8, ty+8)

function hud:update()
    if self.window_bar.props.grab then
        local mx,my = love.mouse.getPosition()
        self.window_pos.x = mx - self.window_bar.props.gpx
        self.window_pos.y = my - self.window_bar.props.gpy
    end
end
function hud:draw()
    self.scene:beginFrame()
    local wx, wy = self.window_pos.x, self.window_pos.y

    self.window:render(self.window_pos:unpack())
    self.window_bar:render(wx,wy, self.window_pos.z, bar_height)
    
    for _,tool in pairs(hud.tools) do
        tool:render(wx+tool.props.x, wy+tool.props.y, tools_button_size, tools_button_size)
    end
    lg.setColor(1,1,1)
    hud.palette_label:render(wx+hud.palette_label.props.x, wy+hud.palette_label.props.y, self.window_pos.z, bar_height)
    local cx, cy = hud.palette_pos[1]+tile_size*4, hud.palette_pos[2]+tile_size*4
    lg.draw(APP.palette_atlas, wx+cx, wy+cy, 0, tile_size, tile_size, 4,4)
    for _,color in pairs(hud.palette) do
        color:render(wx+color.props.x, wy+color.props.y, tile_size, tile_size)
    end
    hud.current_color:render(wx+hud.current_color.props.x, wy+hud.current_color.props.y,64,64)

    hud.texture_label:render(wx+hud.texture_label.props.x, wy+hud.texture_label.props.y, self.window_pos.z, bar_height)
    lg.draw(APP.atlas, wx+self.atlas_pos[1], wy+self.atlas_pos[2])
    for _,texture in pairs(hud.textures) do
        texture:render(wx+texture.props.x, wy+texture.props.y, tile_size, tile_size)
    end
    hud.current_texture:render(wx+hud.current_texture.props.x, wy+hud.current_texture.props.y,64,64)
    
    self.scene:finishFrame()
    -- lg.print(tostring(self.pointer:doesOverlapElement(self.window)),10,290)
end



--------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- Mouse state ------------------------------------------------------------------
------------------------------------------------------------------------------
---------------------------------------------------------------------------

local mouse_tools = {
    press = {
        pencil = function(mx,my,mb)
            if not(mouse.active) then return end
            
            if mb==1 then
                print(mouse.texture_type)
                Cube_map:add_cube( mouse[mouse.texture_type], {mouse.selected.new:unpack()})
            elseif mb==2 then
                if Cube_map:remove_cube(mouse.selected.id) then
                    mouse.active = false
                end
            end
        end,
        brush = function(mx,my,mb)
            if not(mouse.active) then return end
            
            if mb==1 then
                Cube_map:paint_cube(mouse.selected.id, {texture = mouse[mouse.texture_type]})
            elseif mb==2 then
                local cube = Cube_map:get_cube( mouse.selected.id)
                -- print(cube.texture_index)
                mouse:set_texture(cube.texture_index)
            end
        end,
    },
    release = {
        pencil = function(mx,my,mb)

        end,
        brush = function(mx,my,mb)

        end,
    },
}


--------------------------------------------------------------------------------------
-- ##     ##    ###    #### ##    ## 
-- ###   ###   ## ##    ##  ###   ## 
-- #### ####  ##   ##   ##  ####  ## 
-- ## ### ## ##     ##  ##  ## ## ## 
-- ##     ## #########  ##  ##  #### 
-- ##     ## ##     ##  ##  ##   ### 
-- ##     ## ##     ## #### ##    ## 
--------------------------------------------------------------------------------------
local cko_file = require"read_write.cko"

function love.load(...)
    -- love.mouse.setRelativeMode(true)
    lg.setBackgroundColor(0.502,0.502,1)
    -- lg.setMeshCullMode( "back" )
    -- APP.add_color("ff999999")
    Cube_map:load_file(cko_file.load("example.cko"))

    new_text = g3d.newSprite(IMAGE["new_text"],{vertical = true, scale = 0.5})
    select_model = g3d.newModel(CUBE, nil)
    pivot.model = g3d.newSprite(IMAGE["center"],{vertical = true, scale = 0.25})--g3d.newModel(DICE, lg.newImage("image/gimball.png"), nil,nil, 0.25)
    mouse:set_texture("color 0:0")
    local image_data = love.image.newImageData(8,8)
    -- local x,y = 0,0
    -- for l in io.lines("palette.txt") do
    --     local r,g,b = hex2rgb(l)
    --     local color_id = APP.add_color( r,g,b)
    --     if color_id then
    --         image_data:setPixel(x,y,r,g,b)
    --         new_color_button(color_id,x,y)
    --         x = x+1
    --         if x>7 then x=0;y=y+1 end
    --     end
	-- end
    local x,y = 0,0
    local palette = require"palette"
    for i,cor in ipairs(palette) do
        -- local r,g,b = unpack(cor)
        local color_id = APP.add_color( {x,y}, cor)
        if color_id then
            image_data:setPixel(x,y,unpack(cor))
            new_color_button(color_id,x,y)
            x = x+1
            if x>7 then x=0;y=y+1 end
        end
	end
    APP.palette_atlas = lg.newImage(image_data)

    for id,tex in pairs(APP.textures) do
        new_texture_button(id)
    end
end

function love.update(dt)
    if APP.first_person_view then
        camera.firstPersonMovement(dt)
    else
        if mouse.rotating then
            cam.theta:update(10,dt)
            cam.phi:update(10,dt)
        end
        
        cam.offset:update(5,dt)
        pivot_movement(dt)
        camera.pivot(pivot.x,pivot.y,pivot.z, math.rad(cam.theta.v), math.rad(cam.phi.v), cam.offset.v)
    end
    if APP.toggle.light then
        APP.shader:send("lightPosition", camera.position)
    end
    Key.ctrl = love.keyboard.isDown("lctrl")
    Key.alt = love.keyboard.isDown("lalt")

    hud:update()
end

function love.draw()
    -- local s = APP.toggle.light and APP.shader
    -- lg.setDepthMode("lequal", false)
    pivot.model:draw()
    Cube_map:draw()
    lg.setColor(1,1,1)
    if mouse.active and mouse.tool=="pencil" then
        new_text:draw( )
        lg.setColor(1,1,1,0.6)
        lg.setMeshCullMode( "back" )
        select_model:draw( )
        lg.setMeshCullMode("none")
    end

    hud:draw()

    -- local dir, pit = camera.getDirectionPitch()
    -- local cx,cy,cz = unpack(camera.position)
    -- lg.print(string.format("d:%0.2f p:%0.2f x:%0.2f y:%0.2f z:%0.2f", dir,pit,cx,cy,cz),15,250)
    -- lg.print(string.format("theta:%0.2f phi:%0.2f", math.rad(cam.theta.v+90), math.rad(cam.phi.v)),15,270)
end

function love.keypressed(k)
    if k=="escape" then
        love.event.quit()
    end
    if Key.ctrl then
        if k=='z' then
            Cube_map:undo()
        elseif k=='y' then
            Cube_map:redo()
        elseif k=='s' then
            cko_file.save(Cube_map, "cko_save_"..os.date('%Y%m%d%H%M%S'))
        end
    else
        if k=="n" then Cube_map:clear() end
        if k=="l" then APP.toggle.light = not APP.toggle.light end
        if k=="g" then APP.toggle.grid = not APP.toggle.grid end
        if k=="t" then APP.toggle.texture = not APP.toggle.texture end
        if k=="y" then
            APP.first_person_view = not APP.first_person_view
            love.mouse.setRelativeMode(APP.first_person_view)
            if APP.first_person_view then
                local cx,cy,cz = unpack(camera.position)
                camera.lookInDirection(cx,cy,cz, -math.rad(cam.theta.v+90), -math.rad(cam.phi.v))
            end
        end
        if k=="lalt" and not APP.first_person_view then
            local key = mouse.tool=="pencil" and "brush" or "pencil"
            setToolActiveKey(key)
        end
    end
    
end
function love.keyreleased(k)
    if k=="lalt" then
        local key = mouse.tool=="pencil" and "brush" or "pencil"
        setToolActiveKey(key)
    end
end

function love.mousepressed(mx,my, b)
    if APP.first_person_view then return end

    if b==3 then
        mouse.rotating = true
        mouse.old_x = mx
        mouse.old_y = my
    elseif mouse.active then
        mouse_tools.press[mouse.tool](mx,my,b)
    else
        if b==1 then hud.pointer:raise("press") end
    end
end
function love.mousereleased(x,y, b)
    if APP.first_person_view then return end
    if (b == 1) and not(mouse.active) then
		hud.pointer:raise("release")
	end
    if b==3 then
        mouse.rotating = false
        love.mouse.setPosition(mouse.old_x, mouse.old_y)
    end
end
function love.wheelmoved(x,y)
    if not APP.first_person_view then
        local val = 0.1*cam.offset.t*y
        cam.offset.t = math.min(ZOOM_MAX,math.max(ZOOM_MIN,cam.offset.t - val))
    end
end
function love.mousemoved(mx,my, dx,dy)
    if APP.first_person_view then
        
        camera.firstPersonLook(dx,dy)
    elseif mouse.rotating then
        cam.theta = cam.theta + dx*0.5
        cam.phi.t = math.min(89,math.max(-89,cam.phi.t + dy*0.5))
        mouse.active = false
    elseif hud.pointer:doesOverlapElement(hud.window) then
        mouse.active = false
    else

        local cam = cpml.vec3(unpack(camera.position))
        local ray = camera.get_mouse_ray()

        local nearest, position = Cube_map:cast_ray(cam.x, cam.y, cam.z, ray.x, ray.y, ray.z)
        
        if nearest then
            Cube_map.cubes[nearest].highlight = true
            local hit_position = vec3(position)
            
            mouse.active = true
            local nearest_position = vec3(Cube_map.cubes[nearest].translation)
            local result_position = get_side(hit_position, nearest_position)
            mouse.selected = {pos = hit_position, new = result_position, id = nearest}
            new_text:setTranslation(result_position:unpack())
            select_model:setTranslation(result_position:unpack())
        else
            mouse.active = false
        end
    end

    hud.pointer:setPosition(mx, my)
    
end

function love.filedropped(file)
    filename = file:getFilename()
	ext = filename:match("%.%w+$")

	if ext == ".cko" or ext == ".CKO" then
        Cube_map:load_file(cko_file.load(filename))
    end
end
