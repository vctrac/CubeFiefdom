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
    -- print(id)
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
TILE_SIZE = 16

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


APP = {
    toggle = {light=true, grid=false, texture=true},
    shader = lg.newShader(g3d.shaderpath, "shader/lighting.frag"),
    atlas = nil,
    textures = {},
    palette = {},
    colors = {},
    first_person_view = false,
}
function APP.load_texture(filename)
    APP.atlas_data = love.image.newImageData("image/"..filename)
    APP.atlas = lg.newImage(APP.atlas_data)
    local iw,ih = APP.atlas:getDimensions()
    for x=0,math.floor(iw/TILE_SIZE)-1 do
        for y=0,math.floor(ih/TILE_SIZE)-1 do
            local id = To_id("texture", {x,y})
            APP.textures[id] = Image_from_quad( APP.atlas_data, x*TILE_SIZE,y*TILE_SIZE,TILE_SIZE,TILE_SIZE)
        end
    end
end
function APP.add_quad(id, x, y)
    APP.textures[id] = Image_from_quad( APP.atlas, x*TILE_SIZE,y*TILE_SIZE,TILE_SIZE,TILE_SIZE)
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
    APP.colors[id] = color
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
MOUSE = {
    old_x = 0,
    old_x = 0,
    active = false,
    tool = "pencil",
    texture = "texture 0:0",
    color = "color 0:0",
    texture_type = "texture",
}

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
local Cube_map = require"scene"
local hud = require"hud"
local select_model, use-- = g3d.newSprite("image/use.png",{scale = 0.5})

local Key = {
    ctrl = false,
    alt = false
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


APP.cube_map_history = function(name)
    Cube_map[name](Cube_map)
end

--------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- MOUSE state ------------------------------------------------------------------
------------------------------------------------------------------------------
---------------------------------------------------------------------------

MOUSE.selected = {
    pos = vec3(),
    new = vec3(),
    id = "",
}

MOUSE.set_texture = function(self, texture_index)
    local it = Id_type(texture_index)
    self[it] = texture_index
    self.texture_type = it
    select_model.mesh:setTexture(APP[it == "color" and "palette" or "textures"][texture_index])
end

local mouse_tools = {
    press = {
        pencil = function(mx,my,mb)
            if not(MOUSE.active) then return end
            
            if mb==1 then
                print(MOUSE.texture_type)
                Cube_map:add_cube( MOUSE[MOUSE.texture_type], {MOUSE.selected.new:unpack()})
            elseif mb==2 then
                if Cube_map:remove_cube(MOUSE.selected.id) then
                    MOUSE.active = false
                end
            end
        end,
        brush = function(mx,my,mb)
            if not(MOUSE.active) then return end
            
            if mb==1 then
                Cube_map:paint_cube(MOUSE.selected.id, {texture = MOUSE[MOUSE.texture_type]})
            elseif mb==2 then
                local cube = Cube_map:get_cube( MOUSE.selected.id)
                -- print(cube.texture_index)
                MOUSE:set_texture(cube.texture_index)
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

    new_text = g3d.newSprite(IMAGE["new_text"],{vertical = true })
    select_model = g3d.newModel(CUBE, nil)
    pivot.model = g3d.newSprite(IMAGE["center"],{vertical = true, scale = 0.25})--g3d.newModel(DICE, lg.newImage("image/gimball.png"), nil,nil, 0.25)
    MOUSE:set_texture("color 0:0")
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
            hud.new_color_button(color_id,x,y)
            x = x+1
            if x>7 then x=0;y=y+1 end
        end
	end
    APP.palette_atlas = lg.newImage(image_data)

    for id,tex in pairs(APP.textures) do
        hud.new_texture_button(id)
    end
end

function love.update(dt)
    if APP.first_person_view then
        camera.firstPersonMovement(dt)
    else
        if MOUSE.rotating then
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
    -- lg.setColor(1,1,1)
    if MOUSE.active and MOUSE.tool=="pencil" then
        lg.setColor(1,1,1)
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
            local key = MOUSE.tool=="pencil" and "brush" or "pencil"
            setToolActiveKey(key)
        end
    end
    
end
function love.keyreleased(k)
    if k=="lalt" then
        local key = MOUSE.tool=="pencil" and "brush" or "pencil"
        setToolActiveKey(key)
    end
end

function love.mousepressed(mx,my, b)
    if APP.first_person_view then return end

    if b==3 then
        MOUSE.rotating = true
        MOUSE.old_x = mx
        MOUSE.old_y = my
    elseif MOUSE.active then
        mouse_tools.press[MOUSE.tool](mx,my,b)
    else
        if b==1 then hud.pointer:raise("press") end
    end
end
function love.mousereleased(x,y, b)
    if APP.first_person_view then return end
    if (b == 1) and not(MOUSE.active) then
		hud.pointer:raise("release")
	end
    if b==3 then
        MOUSE.rotating = false
        love.mouse.setPosition(MOUSE.old_x, MOUSE.old_y)
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
    elseif MOUSE.rotating then
        cam.theta = cam.theta + dx*0.5
        cam.phi.t = math.min(89,math.max(-89,cam.phi.t + dy*0.5))
        MOUSE.active = false
    elseif hud.pointer:doesOverlapElement(hud.window) then
        MOUSE.active = false
    else

        local cam = cpml.vec3(unpack(camera.position))
        local ray = camera.get_mouse_ray()

        local nearest, position = Cube_map:cast_ray(cam.x, cam.y, cam.z, ray.x, ray.y, ray.z)
        
        if nearest then
            Cube_map.cubes[nearest].highlight = true
            local hit_position = vec3(position)
            
            MOUSE.active = true
            local nearest_position = vec3(Cube_map.cubes[nearest].translation)
            local result_position = get_side(hit_position, nearest_position)
            MOUSE.selected = {pos = hit_position, new = result_position, id = nearest}
            new_text:setTranslation(result_position:unpack())
            select_model:setTranslation(result_position:unpack())
        else
            MOUSE.active = false
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
