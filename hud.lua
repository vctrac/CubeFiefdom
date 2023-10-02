-- hud2.lua
local lg = love.graphics
local Inky = require"library.Inky"
local theme = require"ui.theme"
local Tools = require"ui.tab_tools"
-- local Button = require"ui.button"

local current_tab = "tools"

local hud = {
    scene   = Inky.scene(),
    window_pos = Cpml.quat(0,0,TILE_SIZE*8+8,APP.height),
}
hud.window = (Inky.defineElement(function(self)
    return function(_,x,y,w,h)
        lg.setColor(theme.tab.active_color)
        lg.rectangle("fill", x, y, w, h)
    end
end))(hud.scene)
hud.pointer = Inky.pointer(hud.scene)

function hud.switchTab(name)
    print(name)
    -- current_tab = name
end

Tools.switch_tab = hud.switchTab
Tools.start_x = hud.window_pos.z*0.5 -22

local tabs = {
    tools = Tools.element(hud.scene),
    -- files = Tools.element(hud.scene)
}

function hud:update( dt)
    return
end
function hud:draw()
    local x, y, w, h = hud.window_pos:unpack()
    -- lg.setColor(theme.tab.active_color)
    -- lg.rectangle("fill", x, y, w, h)
    
    lg.setColor(1,1,1)
    self.scene:beginFrame()
    self.window:render(x, y, w, h)
    tabs[current_tab]:render( x, y, w, h)
    -- button_tools:render(x+w,y,25,25)
    -- button_files:render(x+w,y+25,25,25)
    self.scene:finishFrame()

end
hud.load_tool_info = function( id)
    local info = APP.map:get_info(id)
    Tools.clear_info()
    for k,v in pairs(info) do
        Tools.new_info(hud.scene, id, k, v)
    end
end
hud.setToolActiveKey = Tools.setToolActiveKey
hud.new_texture_button = function(name)
    return Tools.setTextureButtons(hud.scene, name)
end
hud.textinput = function(t)
    Tools:textinput(t)
end

hud.keypressed = function(key)
    Tools.keypressed(key)
end
return hud
