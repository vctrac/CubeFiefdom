-- hud2.lua
local lg = love.graphics
local Inky = require"library.Inky"
local theme = require"core.ui.theme"
local Tools = require"core.ui.tab_tools"
local Files = require"core.ui.tab_files"

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
    current_tab = name
end

Files.switch_tab = hud.switchTab
Tools.switch_tab = hud.switchTab
Tools.start_x = hud.window_pos.z*0.5 -22

local tabs = {
    tools = Tools.element(hud.scene),
    files = Files.element(hud.scene)
}

function hud:update( dt)
    return
end
function hud:draw()
    local x, y, w, h = hud.window_pos:unpack()
    
    lg.setColor(1,1,1)
    self.scene:beginFrame()
    self.window:render(x, y, w, h)
    tabs[current_tab]:render( x, y, w, h)
    self.scene:finishFrame()
end
hud.load_tool_info = function( id)
    Tools.load_tool_info(hud.scene, id)
end
hud.new_texture_button = function(name)
    return Tools.setTextureButtons(hud.scene, name)
end

hud.mouse_moved = function(x,y)
    hud.pointer:setPosition(x, y)
    if hud.pointer:doesOverlapElement(hud.window)
    or hud.pointer:doesOverlapElement(Tools.info_panel_dialog) then
        return true
    end
    return false
end


hud.setToolActiveKey = Tools.setToolActiveKey
hud.textinput = Tools.textinput
hud.keypressed = Tools.keypressed
hud.keyreleased = Tools.keyreleased

return hud
