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
        local tg = self.t
        if tg~=v then
            self.v = v-(v-tg)*magnitude*dt
            if math.abs(tg-v)<0.001 then
                self.v=tg
            end
        end
    end
    return t
end
----temp
-- local function round(num, decimals)
--     decimals = math.pow(10, decimals or 0)
--     num = num * decimals
--     if num >= 0 then num = math.floor(num + 0.5) else num = math.ceil(num - 0.5) end
--     return num / decimals
-- end

-- local function rc(n,x)
--     local min,max = n or 1, x or 9
--     return math.random(min, max)*0.1, math.random(min, max)*0.1, math.random(min, max)*0.1, 1
-- end
-- local function rnd_texture(w,h)
--     local image1 = love.image.newImageData(w,h or w)
--     local nr,ng,nb,na = rc(3,8)
--     image1:mapPixel(function(x,y,r,g,b,a) return nr,ng,nb,na end)
--     return lg.newImage(image1)
-- end

--convert a quad from an imageData to a drawable image
local function Image_from_quad(source, x,y,w,h)
    local nid = love.image.newImageData(w, h)
    nid:paste(source, 0, 0, x, y, w, h)

    return lg.newImage(nid)
end

-- local function hex2rgb(hex)
-- 	hex = hex:gsub("ff","",1)
--     local r = tonumber("0x"..hex:sub(1,2))/255
--     local g = tonumber("0x"..hex:sub(3,4))/255
--     local b = tonumber("0x"..hex:sub(5,6))/255
--     -- return tonumber(string.format("%.3f",r)),tonumber(string.format("%.3f",g)),tonumber(string.format("%.3f",b))
--     -- return math.floor(r*1000)*0.001, math.floor(g*1000)*0.001, math.floor(b*1000)*0.001
--     return round(r,4), round(g,4), round(b,4)
-- end

-- function rgb2hex(r,g,b)
--     return string.format("ff%02X%02X%02X",r*255,g*255,b*255)
-- end

local old_print = print
function print( ...)
    local info = debug.getinfo(2,"Sl")
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

function To_id( coords)
    -- local id = 
    return table.concat(coords,':')
end
function From_id(id)
    -- local id_type = id:match("(.*) ")
    -- local coords = id:match(" (.*)")
    local t = {}
    for num in string.gmatch(id, '([^:]+)') do
        table.insert(t,tonumber(num))
    end
    return t
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
---@class Cpml
---@module 'cpml'
Cpml = require"library.cpml"
---@module 'g3d'
require"library.g3d"

CONFIG = {
    version = "0.4",
    app_name = "Cube Fiefdom",
    save_name = "save_"--..os.date('%Y%m%d%H%M%S') --name defined by user
}

CUBE = "model/cube.obj" --default cube model, single cube projected texture
-- DICE = "model/dice.obj" --alternative cube model, six sides spritesheet texture
TILE_SIZE = 16

lg.setDefaultFilter("nearest", "nearest")

IMAGE = {
    atlas = lg.newImage("image/tex.png"),
    circle = lg.newImage("image/circle.png"),
    center = lg.newImage("image/center.png"),
    -- new_text = lg.newImage("image/new_text.png"),
    button_frame = lg.newImage("image/buttons/button_frame.png"),
    new_info_off = lg.newImage("image/buttons/new_info.png"),
    new_info_on = lg.newImage("image/buttons/new_info_on.png"),
    save_lua_off = lg.newImage("image/buttons/save_lua.png"),
    save_lua_on = lg.newImage("image/buttons/save_lua_on.png"),
    save_json_off = lg.newImage("image/buttons/save_json.png"),
    save_json_on = lg.newImage("image/buttons/save_json_on.png"),
    save_obj_off = lg.newImage("image/buttons/save_obj.png"),
    save_obj_on = lg.newImage("image/buttons/save_obj_on.png"),
    pencil = lg.newImage("image/buttons/pencil.png"),
    brush = lg.newImage("image/buttons/brush.png"),
    rotate = lg.newImage("image/buttons/rotate.png"),
    light_on = lg.newImage("image/buttons/light.png"),
    light_off = lg.newImage("image/buttons/light_off.png"),
    grid_on = lg.newImage("image/buttons/grid.png"),
    texture_on = lg.newImage("image/buttons/texture.png"),
    redo = lg.newImage("image/buttons/redo.png"),
    undo = lg.newImage("image/buttons/undo.png"),
    tools_on = lg.newImage("image/tabs/tools_on.png"),
    tools_off = lg.newImage("image/tabs/tools_off.png"),
    files_on = lg.newImage("image/tabs/files_on.png"),
    files_off = lg.newImage("image/tabs/files_off.png"),
    skysphere = lg.newImage("image/skysphere.png"),
    camera = lg.newImage("image/camera_lens.png"),
}
IMAGE.grid_off = IMAGE.grid_on
IMAGE.texture_off = IMAGE.texture_on
IMAGE.undo_off = IMAGE.undo
IMAGE.redo_off = IMAGE.redo
-- 

APP = {
    map = require"scene",
    toggle = {light=true, grid=false, texture=true},
    shader = lg.newShader(g3d.shaderpath, "shader/lighting.frag"),
    atlas = nil,
    texture = {},
    palette = {},
    colors = {},
    first_person_view = false,
    width = lg.getWidth(),
    height = lg.getHeight()
}

function APP.load_texture(filename)
    APP.atlas_data = love.image.newImageData("image/"..filename)
    APP.texture_atlas = lg.newImage(APP.atlas_data)
    local iw,ih = APP.texture_atlas:getDimensions()
    for x=0,math.floor(iw/TILE_SIZE)-1 do
        for y=0,math.floor(ih/TILE_SIZE)-1 do
            local id = To_id({x,y})
            APP.texture[id] = Image_from_quad( APP.atlas_data, x*TILE_SIZE,y*TILE_SIZE,TILE_SIZE,TILE_SIZE)
        end
    end
end

-- APP.save_lua
-- function APP.add_quad(id, x, y)
--     APP.texture[id] = Image_from_quad( APP.texture_atlas, x*TILE_SIZE,y*TILE_SIZE,TILE_SIZE,TILE_SIZE)
-- end

-- function APP.add_color(coords, color)
--     -- print(color)
--     local id = To_id("color", coords)
--     if APP.palette[id] then return false end

--     local image_data = love.image.newImageData(1,1)
--     image_data:setPixel(0,0,unpack(color))
--     APP.palette[id] = lg.newImage(image_data)
--     APP.colors[id] = color
--     return id
-- end

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
    old_y = 0,
    move_x = 0,
    move_y = 0,
    mode = "wait",
    tool = "pencil",
    texture = "0:0",
    -- color = "color 0:0",
    -- texture_type = "texture",
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

-- local save_obj = require"io.obj"

local file_handler = require"file_handler"
-- local APP.map = require"scene"
local hud = require"hud"

-- CPML 3D Vector
---@class vec3:Cpml
---@field x number
---@field y number
---@field z number
---@module 'vec3'
local vec3 = Cpml.vec3
local camera = g3d.camera
local new_cube, current_cube --, new_text
local sky, camera_lens

-- create the mesh for the block cursor
do
    local a = -0.505
    local b = 0.505
    current_cube = g3d.newModel{
        {a,a,a}, {b,a,a}, {b,a,a},
        {a,a,a}, {a,a,b}, {a,a,b},
        {b,a,b}, {a,a,b}, {a,a,b},
        {b,a,b}, {b,a,a}, {b,a,a},

        {a,b,a}, {b,b,a}, {b,b,a},
        {a,b,a}, {a,b,b}, {a,b,b},
        {b,b,b}, {a,b,b}, {a,b,b},
        {b,b,b}, {b,b,a}, {b,b,a},

        {a,a,a}, {a,b,a}, {a,b,a},
        {b,a,a}, {b,b,a}, {b,b,a},
        {a,a,b}, {a,b,b}, {a,b,b},
        {b,a,b}, {b,b,b}, {b,b,b},
    }
end
local Key = {
    ctrl = false,
    alt = false,
    shift = false
}

---@param pos vec3
---@param npos vec3
---@return vec3 npos
local function get_side(pos, npos)
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
        print("some shit happened!")
    end
    if not(result==vec3.zero) then
        return npos+result
    end
    return npos
end

local cam = {
    rotating_speed = 10,
    theta = 90,
    theta_target = 90,
    phi = 35,
    phi_target = 35,
    offset = 10,
    offset_target = 10,
    update = function(self, name, magnitude, dt)
        local v = self[name]
        local tg = self[name.."_target"]
        if tg~=v then
            self[name] = v-(v-tg)*magnitude*dt
            if math.abs(tg-v)<0.001 then
                self[name]=tg
            end
        end
    end
}

local ZOOM_MAX = 25
local ZOOM_MIN = 0.5

local pivot = {
    x=0, y=0, z=0,
    speed = 10,
    angle = 0,
    model = nil
}
local function pivot_movement(dt)
    local moveX, moveY = 0,0--MOUSE.move_x, MOUSE.move_y
    local moved = false
    if love.keyboard.isDown "d" then moveX = moveX - 1 end
    if love.keyboard.isDown "s" then moveY = moveY - 1 end
    if love.keyboard.isDown "a" then moveX = moveX + 1 end
    if love.keyboard.isDown "w" then moveY = moveY + 1 end
    if love.keyboard.isDown "c" then
        pivot.z = pivot.z - pivot.speed*dt
        moved = true
    end
    if love.keyboard.isDown "space" then
        pivot.z = pivot.z + pivot.speed*dt
        moved = true
    end

    if moveX ~= 0 or moveY ~= 0 then
        local angle = math.atan2(moveY, moveX)
        local dir = math.rad(cam.theta) + angle
        pivot.x = pivot.x + math.cos(dir) * pivot.speed * dt
        pivot.y = pivot.y - math.sin(dir) * pivot.speed * dt

        moved = true
    end

    if moved then
        pivot.model:setTranslation(pivot.x,pivot.y,pivot.z)
        sky:setTranslation(pivot.x,pivot.y,pivot.z)
    end
end

-- ---@TODO function to load textures
-- local function load_atlas(filename)
--     --body
-- end
-- local function save_atlas()
--     local data = APP.atlas:newImageData()
--     local file_data = data:encode("png")
--     nfs.write(CONFIG.save_name..".png", file_data:getString())
-- end
local function set_atlas()
    APP.atlas = lg.newCanvas(128,128)
    APP.atlas:renderTo( function()
        lg.draw(APP.texture_atlas,0,0)
        -- lg.draw(APP.palette_atlas,0,128,0,TILE_SIZE,TILE_SIZE)
    end)
end
-- local function modify_atlas()
--     local x,y = 0,0
--     local palette = require"palette"
--     local image_data = love.image.newImageData(8,8)

--     for i=1,#palette do
--     -- for _,cor in pairs(APP.colors) do
--         local id = To_id("color", {x,y})
--         if APP.colors[id] then
--             image_data:setPixel(x,y,unpack(APP.colors[id]))
--             x = x+1
--             if x>7 then x=0;y=y+1 end
--         end
-- 	end
--     APP.palette_atlas = lg.newImage(image_data)

--     set_atlas()
-- end

-- function APP.replace_color(coords, color)
--     local id = To_id("color", coords)
--     APP.palette[id] = nil
--     APP.add_color(coords, color)
--     modify_atlas()
--     APP.map:refresh()
-- end

APP.cube_map_history = function(name) --used for undo and redo features in hud.lua
    APP.map[name](APP.map)
end

APP.save_lua = function()
    file_handler.save("lua", APP.map, CONFIG.save_name)
end

APP.save_json = function()
    file_handler.save("json", APP.map, CONFIG.save_name)
end

APP.save_obj = function()
    file_handler.save("obj", APP.map, CONFIG.save_name)
end
--------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- MOUSE state ------------------------------------------------------------------
------------------------------------------------------------------------------
---------------------------------------------------------------------------
MOUSE.multi = {}
MOUSE.selected = {
    pos = vec3(),
    new = vec3(),
    id = "",
}
MOUSE.set_mode = function(mode)
    MOUSE.mode = mode
end

MOUSE.get_cube_under = function( )
    local cp = vec3(unpack(camera.position))
    local ray = camera.get_mouse_ray()

    local nearest, position = APP.map:cast_ray(cp.x, cp.y, cp.z, ray.x, ray.y, ray.z)
    -- print(nearest)
    if nearest then
        -- print(nearest, unpack(position))
        -- APP.map.cubes[nearest].highlight = true
        local hit_position = vec3(position)
        
        -- MOUSE.active = true
        MOUSE.set_mode("edit")
        local nearest_position = vec3(APP.map.cubes[nearest].position)
        local result_position = get_side(hit_position, nearest_position)
        MOUSE.selected = { new = result_position, id = nearest}
        
        local rx,ry,rz = result_position:unpack()
        -- local new_id = To_id({rx,ry,rz})
        -- if not MOUSE.multi[new_id] then
        --     MOUSE.multi[new_id] = {pos={rx,ry,rz},id=nearest}
        -- end
        -- new_text:setTranslation(rx,ry,rz)
        new_cube:setTranslation(rx,ry,rz)
        rx,ry,rz = nearest_position:unpack()
        current_cube:setTranslation(rx,ry,rz)
    else
        -- MOUSE.active = false
        MOUSE.set_mode"wait"
    end
end
MOUSE.set_texture = function(self, texture_index)
    -- local it = Id_type(texture_index)
    self.texture = texture_index
    -- self.texture_type = it
    new_cube.mesh:setTexture(APP["texture"][texture_index])

    hud.load_tool_info(texture_index)
end

local mouse_tools = {
    release = {
        pencil = function(mx,my,mb)
            if MOUSE.mode == "edit" then
                if mb==1 then
                    -- print(MOUSE.texture_type)
                    -- for key, selected in pairs(MOUSE.multi) do
                    --     APP.map:add_cube( MOUSE.texture, selected.pos)
                    -- end
                    -- MOUSE.multi = {}
                    APP.map:add_cube( MOUSE.texture, {MOUSE.selected.new:unpack()})
                elseif mb==2 then
                    if APP.map:remove_cube(MOUSE.selected.id) then
                        MOUSE.mode = "wait"
                    end
                end
            end
        end,
        brush = function(mx,my,mb)
            if MOUSE.mode~="edit" then return end
            
            if mb==1 then
                APP.map:paint_cube(MOUSE.selected.id, {texture = MOUSE.texture})
            elseif mb==2 then
                local cube = APP.map:get_cube( MOUSE.selected.id)
                -- print(cube.texture)
                if not cube then return end
                MOUSE:set_texture(cube.texture)
            end
        end,
    },
    press = {
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


function love.load(...)

    -- lg.setBackgroundColor(0.502,0.502,1)

    APP.load_texture("tex.png")
    APP.map:new()

    sky = g3d.newModel("model/dome.obj", IMAGE.skysphere, nil, nil, 500)
    camera_lens = g3d.newSprite(IMAGE["camera"],{vertical = true, scale = 0.5})
    -- -- new_text = g3d.newSprite(IMAGE["new_text"],{vertical = true })
    new_cube = g3d.newModel(CUBE, nil)
    pivot.model = g3d.newSprite(IMAGE["center"],{vertical = true, scale = 0.25})--g3d.newModel(DICE, lg.newImage("image/gimball.png"), nil,nil, 0.25)
    MOUSE:set_texture("0:0")
    -- local image_data = love.image.newImageData(8,8)
    -- local x,y = 0,0
    -- local palette = require"palette"
    -- for _,cor in ipairs(palette) do
    --     -- local r,g,b = unpack(cor)
    --     local color_id = APP.add_color( {x,y}, cor)
    --     if color_id then
    --         image_data:setPixel(x,y,unpack(cor))
    --         hud.new_color_button(color_id,x,y)
    --         x = x+1
    --         if x>7 then x=0;y=y+1 end
    --     end
	-- end
    -- APP.palette_atlas = lg.newImage(image_data)

    for id,_ in pairs(APP.texture) do
        hud.new_texture_button(id)
    end
    set_atlas()
    APP.map:refresh()

    -- APP.map:add_info("0:0", "breakable", "true")
    -- APP.map:add_info("0:2", "walkable", true)
    -- APP.map:add_info("1:2", "walkable", true)
    -- APP.map:add_info("1:2", "breakable", false)
    -- APP.map:add_info("3:2", "walkable", true)
end

function love.update(dt)
    if MOUSE.stopped then
        MOUSE.move_x = 0
        MOUSE.move_y = 0
    end
    if APP.first_person_view then
        -- camera.firstPersonMovement(dt)
        camera.movement(dt)
    else
        if MOUSE.mode=="rotating" then
            cam:update("theta", 10,dt)
            cam:update("phi",10,dt)
        end
        cam:update("offset",5,dt)
        if MOUSE.mode~="hud" then
            pivot_movement(dt)
        end
        camera.pivot(pivot.x,pivot.y,pivot.z, math.rad(cam.theta), math.rad(cam.phi), cam.offset)
    end
    if APP.toggle.light then
        -- APP.shader:send("lightPosition", light.position)
        APP.shader:send("lightPosition", camera.position)
    end
    Key.ctrl = love.keyboard.isDown("lctrl")
    Key.alt = love.keyboard.isDown("lalt")
    Key.shift = love.keyboard.isDown("lshift")

    hud:update()
    MOUSE.stopped = true
end

function love.draw()
    -- local s = APP.toggle.light and APP.shader
    -- lg.setDepthMode("lequal", false)
    lg.setColor(1,1,1)
    sky:draw()
    pivot.model:draw()
    APP.map:draw()
    -- lg.setColor(1,1,1)
    if MOUSE.mode=="edit" then
        lg.setColor(0,0,0)
        lg.setWireframe(true)
        current_cube:draw( )
        lg.setWireframe(false)
        if MOUSE.tool=="pencil" then
            lg.setColor(1,1,1)
            -- new_text:draw( )
            lg.setColor(1,1,1,0.6)
            lg.setMeshCullMode( "back" )
            -- for key, selected in pairs(MOUSE.multi) do
                -- new_cube:setTranslation(selected.pos[1],selected.pos[2],selected.pos[3])
                new_cube:draw( )
            -- end
            -- new_cube:draw( )
            lg.setMeshCullMode("none")
        end
        
    end
    
    if APP.first_person_view then
        lg.setColor(1,1,1)
        camera_lens:draw()
    else
        hud:draw()
    end
    lg.printf(MOUSE.mode,0, APP.height-35, APP.width,"right")
    -- lg.setColor(1,1,1,1)
    lg.printf(tostring(love.timer.getFPS( )),0, APP.height-14, APP.width,"right")
end

function love.keypressed(k)
    if k=="escape" then
        love.event.quit()
    end
    if k=="f1" then
        file_handler.save("obj", APP.map, CONFIG.save_name)
        -- save_atlas()
    end
    if Key.ctrl then
        if k=='z' then
            APP.map:undo()
        elseif k=='y' then
            APP.map:redo()
        elseif k=='s' then
            file_handler.save("json", APP.map, CONFIG.save_name)

            -- save_atlas()
        end
    elseif MOUSE.mode~="hud" then
        -- if k=="n" then APP.map:clear() end
        if k=="l" then APP.toggle.light = not APP.toggle.light end
        if k=="g" then APP.toggle.grid = not APP.toggle.grid end
        if k=="t" then APP.toggle.texture = not APP.toggle.texture end
        if k=="tab" then
            APP.first_person_view = not APP.first_person_view
            love.mouse.setRelativeMode(APP.first_person_view)
            if APP.first_person_view then
                local cx,cy,cz = unpack(camera.position)
                camera_lens:setTranslation(cx,cy,cz)
                camera.lookInDirection(cx,cy,cz, -math.rad(cam.theta+90), -math.rad(cam.phi))
                MOUSE.mode = "wait"
            end
        end
        if k=="lalt" and not APP.first_person_view then
            local key = MOUSE.tool=="pencil" and "brush" or "pencil"
            hud.setToolActiveKey(key)
        end
    end
    hud.keypressed(k)
end
function love.keyreleased(k)
    if k=="lalt" then
        local key = MOUSE.tool=="pencil" and "brush" or "pencil"
        hud.setToolActiveKey(key)
    end
end

function love.mousepressed(mx,my, b)
    if APP.first_person_view then return end

    if b==3 then
        if Key.shift then
            -- MOUSE.panning = true
            MOUSE.mode = "panning"
        else
            -- MOUSE.rotating = true
            MOUSE.mode = "rotating"
        end
        MOUSE.old_x = mx
        MOUSE.old_y = my
    elseif MOUSE.mode=="edit" then
        mouse_tools.press[MOUSE.tool](mx,my,b)
    else
        if b==1 then hud.pointer:raise("press") end
    end
end
function love.mousereleased(mx,my, b)
    if APP.first_person_view then return end
    -- if (b == 1) and not(MOUSE.active) then
		-- hud.pointer:raise("release")
	-- end
    if b==3 then
        -- MOUSE.rotating = false
        -- MOUSE.panning = false
        MOUSE.set_mode("wait")
        -- love.mouse.setPosition(MOUSE.old_x, MOUSE.old_y)
    elseif MOUSE.mode=="edit" then
        mouse_tools.release[MOUSE.tool](mx,my,b)
        MOUSE.get_cube_under()
    else
        if b==1 then hud.pointer:raise("release") end
    end
end
function love.wheelmoved(x,y)
    if not APP.first_person_view then
        local v = 0.1*cam.offset_target*y
        cam.offset_target = math.min(ZOOM_MAX,math.max(ZOOM_MIN,cam.offset_target - v))
        -- MOUSE.set_mode("zooming")
    end
end
function love.mousemoved(mx,my, dx,dy)
    MOUSE.stopped = false
    if APP.first_person_view then
        camera.firstPersonLook(dx,dy)
    elseif MOUSE.mode=="rotating" then
        cam.theta_target = cam.theta_target + dx*0.5
        cam.phi_target = math.min(89,math.max(-89,cam.phi_target + dy*0.5))
    elseif MOUSE.mode=="panning" then
        MOUSE.move_x = dx
        MOUSE.move_y = dy
    elseif hud.pointer:doesOverlapElement(hud.window) then
        MOUSE.set_mode("hud")
        if (love.mouse.isDown(1)) then
            hud.pointer:setPosition(mx, my)
            hud.pointer:raise("drag", dx, dy)
        end
    else
        MOUSE.get_cube_under()
    end

    hud.pointer:setPosition(mx, my)
end

function love.filedropped(file)
    local filename = file:getFilename()
    if not filename then
        return
    end
	local ext = string.lower( string.sub( filename:match("%.%w+$"),2))

	if file_handler[ext] then
        if ext=="obj" then return end
        APP.map:load_file(file_handler.load(ext, filename))
    end
end

function love.textinput(t)
    if MOUSE.mode=="hud" then
        hud.textinput(t)
    end
end

function love.resize(w, h)
    APP.width = w
    APP.height = h
    g3d.camera.aspectRatio = w / h
    g3d.camera.updateProjectionMatrix()
end