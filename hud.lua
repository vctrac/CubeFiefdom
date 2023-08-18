-- hud.lua
--------------------------------------------------------------------------------------
-- ##     ## ##     ## ########  
-- ##     ## ##     ## ##     ## 
-- ##     ## ##     ## ##     ## 
-- ######### ##     ## ##     ## 
-- ##     ## ##     ## ##     ## 
-- ##     ## ##     ## ##     ## 
-- ##     ##  #######  ########  
--------------------------------------------------------------------------------------


local lg = love.graphics
local Inky = require"library.inky"


-- local Button = require"ui.button"
local tools_button_size = 22
local bar_height = 14
local window_height_min = bar_height
local window_height_max = 620
local hud = {
    scene   = Inky.scene(),
    window_pos = cpml.quat(10,10,TILE_SIZE*8+4,window_height_max),
    tools = { },
    palette = { },
    textures = { },
    current_texture = nil,
    current_color = nil,
    minimized = false,
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

local window = Inky.defineElement(function(self)
    return function(_, x, y, w, h)
        lg.setColor(0.5,0.5,0.7)
        lg.rectangle("fill",x,y,w,h)
        lg.setColor(0.2,0.2,0.2)
        lg.rectangle("line",x,y,w,h)
    end
end)

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
        lg.setColor(0.4,0.5,0.6)
        for i=1,2 do
            lg.line(x,y+i*4,x+w,y+i*4)
        end
    end
end)
local minimize_button = Inky.defineElement(function(self)
    -- self:onPointer("release", function(self)
    --     self.props.active = not self.props.active
    -- end)
    self:onPointer("press", function(self)
        hud.minimized = not hud.minimized
        hud.window_pos.w = hud.minimized and window_height_min or window_height_max
    end)
    return function(_, x, y, w, h)
        lg.setColor(0.3,0.3,0.7)
        lg.rectangle("fill",x,y,w,h)
        lg.setColor(1,1,1)
        lg.printf("-",x,y,w,"center")
    end
end)
local label_bar = Inky.defineElement(function(self)
    return function(_, x, y, w, h)
        lg.setColor(self.props.color)
        lg.rectangle("fill",x,y,w,h)
        lg.setColor(1,1,1)
        lg.printf(self.props.text,x,y,w,"center")
    end
end)

local function radio_button_new(name,xx,yy)
    local button = Inky.defineElement(function(self)
        self:onPointerEnter(function(self, pointer, ...)
            self.props.color ="on_over"
        end)
        self:onPointerExit(function(self, pointer, ...)
            self.props.color = MOUSE.tool==name and "on" or "off"
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
    hud.tools[name].props.color = MOUSE.tool==name and "on" or "off"
    hud.tools[name].props.x = xx
    hud.tools[name].props.y = yy
end

local function setToolActiveKey(key)
    for _,tool in pairs(hud.tools) do
        tool.props.color = (tool.props.key==key) and "on" or "off"
        tool.props.activeKey = key
    end
    MOUSE.tool = key
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
            -- Cube_map[name](Cube_map)
            APP.cube_map_history(name)
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

local function show_color(name,xx,yy)

    local button = Inky.defineElement(function(self)
        
        return function(_, x, y, w, h)
            lg.setColor(0,0,0,0.5)
            lg.rectangle("fill", x-1,y-1,w+2,h+2)
            lg.setColor(1,1,1)
            lg.draw(APP.palette[MOUSE.color],x,y,0, w, h)
        end
    end)

    hud.current_color = button(hud.scene)
    hud.current_color.props.x = xx
    hud.current_color.props.color = name
    hud.current_color.props.y = yy
end

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
            MOUSE:set_texture(name)
        end)
        return function(_, x, y, w, h)
            if self.props.active then
                lg.setColor(0,0,0,1)
                local s = TILE_SIZE*1.5
                local s2 = TILE_SIZE*0.25
                lg.rectangle("fill", x-s2-1,y-s2-1,s+2,s+2)
                lg.setColor(1,1,1)
                lg.draw(APP.palette[name],x-s2,y-s2,0,s,s)
            end
        end
    end)

    hud.palette[name] = button(hud.scene)
    hud.palette[name].props.x = hud.palette_pos[1]+xx*TILE_SIZE
    hud.palette[name].props.y = hud.palette_pos[2]+yy*TILE_SIZE
end

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
            MOUSE:set_texture(name)
        end)
        return function(_, x, y, w, h)
            if self.props.active then
                lg.setColor(0,0,0,0.5)
                local s = 1.5
                local sp = TILE_SIZE*0.25
                lg.rectangle("fill", x-sp-1,y-sp-1,w*s+2,h*s+2)
                lg.setColor(1,1,1)
                lg.draw(APP.textures[name],x-sp,y-sp,0,s,s)
            end
        end
    end)
    
    local xx,yy = From_id(name)

    hud.textures[name] = button(hud.scene)
    hud.textures[name].props.x = hud.atlas_pos[1]+xx*TILE_SIZE
    hud.textures[name].props.y = hud.atlas_pos[2]+yy*TILE_SIZE
end

local function show_texture(name,xx,yy)

    local button = Inky.defineElement(function(self)
        
        return function(_, x, y, w, h)
            lg.setColor(0,0,0,0.5)
            lg.rectangle("fill", x-1,y-1,w+2,h+2)
            lg.setColor(1,1,1)
            lg.draw(APP.textures[MOUSE.texture],x,y,0,4,4)
        end
    end)

    hud.current_texture = button(hud.scene)
    hud.current_texture.props.x = xx
    -- hud.current_texture.props.texture = name
    hud.current_texture.props.y = yy
end


----------------------------------------------------------------------------------------------------
--  ######  ########    ###    ########  ######## 
-- ##    ##    ##      ## ##   ##     ##    ##    
-- ##          ##     ##   ##  ##     ##    ##    
--  ######     ##    ##     ## ########     ##    
--       ##    ##    ######### ##   ##      ##    
-- ##    ##    ##    ##     ## ##    ##     ##    
--  ######     ##    ##     ## ##     ##    ##    
----------------------------------------------------------------------------------------------------

hud.pointer = Inky.pointer(hud.scene)

hud.window = window(hud.scene)
hud.window_bar = window_bar(hud.scene)
hud.minimize_button = minimize_button(hud.scene)

local tx,ty = 2, bar_height

hud.tools_label = label_bar(hud.scene)
hud.tools_label.props.text = "Tools"
hud.tools_label.props.color = {0,0.6,0.1}
hud.tools_label.props.x = 0
hud.tools_label.props.y = ty
ty = ty + bar_height + 2

radio_button_new("pencil",tx,ty)
tx = tx+tools_button_size
radio_button_new("brush",tx,ty)
-- tx = tx+tools_button_size
-- radio_button_new("rotate",tx,ty)
tx = 2
ty = ty+tools_button_size

for _,tool in pairs(hud.tools) do
    tool.props.setActiveKey = setToolActiveKey
end

-- local button_size = 22

toggle_button_new("light", tx, ty)
tx = tx+tools_button_size
toggle_button_new("texture", tx, ty)
tx = tx+tools_button_size
toggle_button_new("grid", tx, ty)

tx = tx+tools_button_size
edit_button_new("undo", tx, ty)
tx = tx+tools_button_size
edit_button_new("redo", tx, ty)
ty = ty + tools_button_size + 5
tx = 2

hud.palette_label = label_bar(hud.scene)
hud.palette_label.props.text = "Palette"
hud.palette_label.props.color = {0,0.3,1}
hud.palette_label.props.x = 0
hud.palette_label.props.y = ty
ty = ty + bar_height + 2
hud.palette_pos = {tx,ty}
ty = ty +136


show_color(MOUSE.color, 8,ty)
ty = ty+ 160


hud.texture_label = label_bar(hud.scene)
hud.texture_label.props.text = "Texture"
hud.texture_label.props.color = {0.8,0,0}
hud.texture_label.props.x = 0
hud.texture_label.props.y = ty
ty = ty + bar_height + 2
hud.atlas_pos = {tx,ty}

-- local iw,ih = APP.atlas_data:getDimensions()
ty = ty +128

show_texture(MOUSE.texture, 8, ty+8)

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
    self.window_bar:render(wx,wy, self.window_pos.z-TILE_SIZE, bar_height)
    self.minimize_button:render(wx+self.window_pos.z-TILE_SIZE,wy,TILE_SIZE, bar_height)
    if hud.minimized then return end
    self.tools_label:render(wx+self.tools_label.props.x,wy+self.tools_label.props.y, self.window_pos.z, bar_height)
    
    for _,tool in pairs(self.tools) do
        tool:render(wx+tool.props.x, wy+tool.props.y, tools_button_size, tools_button_size)
    end
    lg.setColor(1,1,1)
    self.palette_label:render(wx+self.palette_label.props.x, wy+self.palette_label.props.y, self.window_pos.z, bar_height)
    local cx, cy = self.palette_pos[1]+TILE_SIZE*4, self.palette_pos[2]+TILE_SIZE*4
    lg.draw(APP.palette_atlas, wx+cx, wy+cy, 0, TILE_SIZE, TILE_SIZE, 4,4)
    for _,color in pairs(self.palette) do
        color:render(wx+color.props.x, wy+color.props.y, TILE_SIZE, TILE_SIZE)
    end
    self.current_color:render(wx+self.current_color.props.x, wy+self.current_color.props.y,64,64)

    self.texture_label:render(wx+self.texture_label.props.x, wy+self.texture_label.props.y, self.window_pos.z, bar_height)
    lg.draw(APP.atlas, wx+self.atlas_pos[1], wy+self.atlas_pos[2])
    for _,texture in pairs(self.textures) do
        texture:render(wx+texture.props.x, wy+texture.props.y, TILE_SIZE, TILE_SIZE)
    end
    self.current_texture:render(wx+self.current_texture.props.x, wy+self.current_texture.props.y,64,64)
    
    self.scene:finishFrame()
    -- lg.print(tostring(self.pointer:doesOverlapElement(self.window)),10,290)
end
hud.minimize = function()


end

hud.new_color_button = new_color_button
hud.new_texture_button = new_texture_button
return hud