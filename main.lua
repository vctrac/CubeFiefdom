if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

local lg = love.graphics
local keydown = love.keyboard.isDown
CONFIG = {
    version = "0.4",
    app_name = "Cube Fiefdom",
    save_name = "save_"--..os.date('%Y%m%d%H%M%S') --name defined by user
}

TILE_SIZE = 16

---@class Cpml
---@module 'cpml'
Cpml = require"library.cpml"

-- CPML 3D Vector
---@class vec3:Cpml
---@field x number
---@field y number
---@field z number
---@module 'vec3'
vec3 = Cpml.vec3

-- -- CPML 2D Vector
-- ---@class vec2:Cpml
-- ---@field x number
-- ---@field y number
-- ---@module 'vec2'
-- vec2 = Cpml.vec2

---@module 'g3d'
require"library.g3d"

require"resource"
require"core.misc.helpers"



require"app"
require"mouse"
HUD = require"hud"

local camera = g3d.camera
local sky

local Key = {
    ctrl = false,
    alt = false,
    shift = false
}

local cam_controls = {
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
    model = nil,
    movement = function(self, dt)
        ---@TODO: mouse panning should move the CUBE_MAP relative to screen (left and right, up and down) like in cubeKingdom

        if not Key.shift then return end
        local moveX, moveY = 0,0--MOUSE.move_x, MOUSE.move_y
        local moved = false

        if keydown"d" then moveX = moveX - 1 end
        if keydown"s" then moveY = moveY - 1 end
        if keydown"a" then moveX = moveX + 1 end
        if keydown"w" then moveY = moveY + 1 end
        if keydown "q" then
            self.z = self.z - self.speed*dt
            moved = true
        end
        if keydown "e" then
            self.z = self.z + self.speed*dt
            moved = true
        end

        if moveX ~= 0 or moveY ~= 0 then
            local angle = math.atan2(moveY, moveX)
            local dir = math.rad(cam_controls.theta) + angle
            self.x = self.x + math.cos(dir) * self.speed * dt
            self.y = self.y - math.sin(dir) * self.speed * dt

            moved = true
        end

        if moved then
            self.model:setTranslation(self.x,self.y,self.z)
            sky:setTranslation(self.x,self.y,self.z)
        end
    end
}


---@param id string
---@param translation table
local function edit(id, translation)
    local has_cube = APP.map:get_cube( id)
    if APP.selected_tool == "pencil" then
        if has_cube then
            APP.map:remove_cube( id)
        else
            APP.map:add_cube( MOUSE.texture, unpack( translation))
        end
    elseif APP.selected_tool == "brush" then
        if has_cube then
            APP.map:paint_cube( id, MOUSE.texture)
        end
    end
end

local move_keys = {w={0,1,0}, a={1,0,0}, s={0,-1,0}, d={-1,0,0}, q={0,0,-1}, e={0,0,1}}

local selected = {
    translation = {0,0,0},
    direction = {0,0,0}, --vec2(),
    id = To_id({0,0,0}),
    hold = false,
    multiple = { list_of_ids = {}},
    movement = function(self)
        -- if self.moved then
            local rx, ry, rz = unpack( self.direction)
            if not(rx==0 and ry==0) then
                local angle = math.atan2(ry, rx)
                local dir = math.rad(cam_controls.theta) + angle
                self.translation[1] = self.translation[1] +math.round(math.cos(dir))
                self.translation[2] = self.translation[2] -math.round(math.sin(dir))
                -- print(table.concat(self.translation, ':'))
            end
            self.translation[3] = self.translation[3] +rz
            self.cube:setTranslation(unpack(self.translation))
            -- self.moved = false
            self.id = To_id(self.translation)
            if self.hold then
                if not self.multiple.list_of_ids[ self.id] then
                    self.multiple.list_of_ids[ self.id] = true
                    table.insert(self.multiple, {id = self.id, translation = {unpack(self.translation)}})
                    -- print(#self.multiple)
                end
            end
        -- end
    end,
    input_press = function(self, key)
        if not Key.shift and move_keys[key] then
            self.direction = move_keys[key]
            -- self.moved = true
            self:movement()
        end
        if key =='space' then
            self.hold = true
            edit(self.id, self.translation)
        end
    end,
    input_release = function(self, key)
        if key =='space' then
            if self.hold then
                local count = #self.multiple
                for i=1,count do
                    edit(self.multiple[i].id, self.multiple[i].translation)
                end
                self.hold = false
                for i=1,count do
                    self.multiple[i] = nil
                end
                self.multiple.list_of_ids = {}
            end
        end
    end,
    draw = function(self)
        lg.setWireframe(true)
        if self.hold then
            lg.setColor(1,1,1,0.1)
            for i=1,#self.multiple do
                self.cube:setTranslation(unpack(self.multiple[i].translation))
                self.cube:draw( )
            end
            self.cube:setTranslation(unpack(self.translation))
        end
        lg.setColor(1,1,1)
        self.cube:draw( )
        lg.setWireframe(false)
    end
}

-- create the mesh for the block cursor
do
    local a = -0.505
    local b = 0.505
    selected.cube = g3d.newModel{
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
--------------------------------------------------------------------------------------
-- ##     ##    ###    #### ##    ## 
-- ###   ###   ## ##    ##  ###   ## 
-- #### ####  ##   ##   ##  ####  ## 
-- ## ### ## ##     ##  ##  ## ## ## 
-- ##     ## #########  ##  ##  #### 
-- ##     ## ##     ##  ##  ##   ### 
-- ##     ## ##     ## #### ##    ## 
--------------------------------------------------------------------------------------

local day_time = 0 --used to control the skysphere shader
local day_time_multiplier = 1

function love.load(...)

    -- lg.setBackgroundColor(0.502,0.502,1)

    APP.load()
    MOUSE.load()

    sky = g3d.newModel(DATA.model.sphere, nil, {0,0,-50}, nil, 500)
    sky.shader = love.graphics.newShader(g3d.shaderpath, DATA.shader["gradient"]) --gradient, grid, sky, clouds
    sky.shader:send("Time",5)

    camera.sprite = g3d.newSprite(DATA.image["camera"],{scale = 0.5})
    pivot.model = g3d.newSprite(DATA.image["center"],{scale = 0.25})--g3d.newModel(DICE, lg.newImage("image/gimball.png"), nil,nil, 0.25)

    for id,_ in pairs(APP.texture) do
        HUD.new_texture_button(id)
    end

    -- APP.map:add_info("0:0", "breakable", "true")
    -- APP.map:add_info("0:2", "walkable", true)
end

function love.update(dt)
    
    Key.ctrl = keydown("lctrl")
    Key.alt = keydown("lalt")
    Key.shift = keydown("lshift")

    day_time = day_time+0.1*dt*day_time_multiplier
    sky.shader:send("Time",day_time)

    -- if MOUSE.stopped then
    --     MOUSE.move_x = 0
    --     MOUSE.move_y = 0
    -- end

    if APP.first_person_view then
        camera.movement(dt)
    else
        if MOUSE.mode~="hud" then
            -- selected:movement()
            if Key.ctrl then
                MOUSE.set_mode"rotating"
            end
            if MOUSE.mode=="rotating" then
                cam_controls:update("theta", 10,dt)
                cam_controls:update("phi",10,dt)
            end
            pivot:movement(dt)
                
            cam_controls:update("offset",5,dt)
            camera.pivot(pivot.x,pivot.y,pivot.z, math.rad(cam_controls.theta), math.rad(cam_controls.phi), cam_controls.offset)
        end
    end
    if APP.toggle.light then
        APP.map.light_shader:send("lightPosition", APP.first_person_view and camera.sprite.translation or camera.position)
    end

    -- HUD:update(dt)
    -- MOUSE.stopped = true

    --- Draw to Canvas ---
    lg.setCanvas({APP.canvas, depth=true})
    lg.clear()
    lg.setColor(1,1,1)
    sky:draw()
    APP.map:draw()
    pivot.model:draw()
    MOUSE.draw()
    if APP.first_person_view then
        camera.sprite:draw()
    else
        selected:draw()
    end
    lg.setCanvas({depth=false})
end

function love.draw()
    
    lg.setColor(1,1,1)

    if APP.toggle.retro then
        love.graphics.setShader(APP.retro_shader)
        lg.draw(APP.canvas,0,0,0,APP.pixel_scale,APP.pixel_scale)
        love.graphics.setShader()
    else
        lg.draw(APP.canvas,0,0,0,APP.pixel_scale,APP.pixel_scale)
    end
    
    if not APP.first_person_view then
        HUD:draw()
    end

    ---@DEBUG
    lg.setColor(1,1,1)
    lg.printf(MOUSE.mode,0, APP.height-35, APP.width,"right")
    -- lg.printf(tostring(love.timer.getFPS( )),0, APP.height-14, APP.width,"right")
    -- lg.printf( day_time, 0, APP.height-24, APP.width,"right")
end

function love.keypressed(k)
    -- if k=="escape" then
    --     love.event.quit()
    -- end
    
    HUD.keypressed(k)
    if MOUSE.mode=="hud_dialog" then
        return
    end
    if Key.ctrl then
        if k=='z' then
            APP.undo()
        elseif k=='y' then
            APP.redo()
        end
        MOUSE.set_mode"rotating"
    elseif MOUSE.mode~="hud" then
        if k=="n" then APP.clear() end
        
        -- if k=="l" then APP.toggle.light = not APP.toggle.light end
        -- if k=="g" then APP.toggle.grid = not APP.toggle.grid end
        -- if k=="t" then APP.toggle.texture = not APP.toggle.texture end
        -- if k=="up" then day_time_multiplier = day_time_multiplier+1
        -- elseif k=="down" then day_time_multiplier = day_time_multiplier-1 end
        if k=="tab" then
            APP.first_person_view = not APP.first_person_view
            love.mouse.setRelativeMode(APP.first_person_view)
            if APP.first_person_view then
                local cx,cy,cz = unpack(camera.position)
                camera.sprite:setTranslation(cx,cy,cz)
                camera.lookInDirection(cx,cy,cz, -math.rad(cam_controls.theta+90), -math.rad(cam_controls.phi))
                MOUSE.set_mode"wait"
            end
        end
        
        -- if k=="lalt" and not APP.first_person_view then
        --     local key = APP.selected_tool=="pencil" and "brush" or "pencil"
        --     HUD.setToolActiveKey(key)
        -- end
    end
    if not APP.first_person_view then
        selected:input_press(k)
    end
    HUD.keypressed(k)
end
function love.keyreleased(k)
    if k=="lalt" then
        local key = APP.selected_tool=="pencil" and "brush" or "pencil"
        HUD.setToolActiveKey(key)
    elseif k=="lctrl" then
        MOUSE.set_mode"wait"
    end
    if not APP.first_person_view then
        selected:input_release(k)
    end
end

function love.mousepressed(mx,my, b)
    if APP.first_person_view then return end

    if b==3 then
        -- if Key.shift then
            ---@TODO: implement panning
            -- MOUSE.set_mode"panning"
        -- else
        MOUSE.set_mode"rotating"
        -- end
        MOUSE.old_x = mx
        MOUSE.old_y = my
    elseif MOUSE.mode=="edit" then
        -- MOUSE.pressed(mx,my,b)
    else
        if b==1 then HUD.pointer:raise("press") end
    end
end
function love.mousereleased(mx,my, b)
    if APP.first_person_view then return end
    if (b == 1) and not(MOUSE.active) then
		HUD.pointer:raise("release")
	end
    if b==3 then
        MOUSE.set_mode"wait"
    elseif MOUSE.mode=="edit" then
        MOUSE.released(mx,my,b)
    -- else
        -- if b==1 then HUD.pointer:raise("release") end
    end
end
function love.wheelmoved(x,y)
    if not APP.first_person_view then
        local v = 0.1*cam_controls.offset_target*y
        cam_controls.offset_target = math.min(ZOOM_MAX,math.max(ZOOM_MIN,cam_controls.offset_target - v))
        -- MOUSE.set_mode("zooming")
    end
end
function love.mousemoved(mx,my, dx,dy)
    -- print(dx,dy)
    -- MOUSE.stopped = false
    HUD.mouse_moved(mx,my)
    if MOUSE.mode=="hud_dialog" then return end
    if APP.first_person_view then
        camera.firstPersonLook(dx,dy)
    elseif MOUSE.mode=="rotating" then
        cam_controls.theta_target = cam_controls.theta_target + dx*0.5
        cam_controls.phi_target = math.min(89,math.max(-89,cam_controls.phi_target + dy*0.5))
    -- elseif MOUSE.mode=="panning" then
    --     MOUSE.move_x = dx
    --     MOUSE.move_y = dy
    else
        local over,obj = HUD.is_overlaping()
        if over then
            MOUSE.set_mode(obj)
        else
            MOUSE.get_cube_under()
        end
    end
end

function love.filedropped(file)
    local filename = file:getFilename()
    if not filename then
        return
    end
	local ext = string.lower( string.sub( filename:match("%.%w+$"),2))
    
    APP.drop_file(filename, ext)

    ---@TODO: method to load new textures
end

function love.textinput(t)
    if MOUSE.mode=="hud_dialog" then
        HUD.textinput(t)
    end
end

function love.resize(w, h)
    APP.resize_screen(w,h)
    g3d.camera.resizeScreen(w,h)
end