-- hud2.lua
local lg = love.graphics
local Inky = require"library.Inky"
local Tools = require"core.ui.tools"

local hud = {
    scene   = Inky.scene(),
    window_pos = Cpml.quat(0,0,TILE_SIZE*8+8,APP.height),
}
hud.window = (Inky.defineElement(function() end))(hud.scene)
hud.pointer = Inky.pointer(hud.scene)
Tools.start_x = hud.window_pos.z*0.5 -22

local tools = Tools.element(hud.scene)

-- function hud:update( dt)
--     return
-- end
function hud:draw()
    
    local x, y, w, h = hud.window_pos:unpack()
    
    lg.setColor(1,1,1)
    self.scene:beginFrame()
    self.window:render(x, y, w, h)
    tools:render( x, y, w, h)
    self.scene:finishFrame()
    hud.window_pos.w = tools.props.height
end
hud.load_tool_info = function( id)
    Tools.load_tool_info(hud.scene, id)
end
hud.new_texture_button = function(name)
    return Tools.setTextureButtons(hud.scene, name)
end

hud.mouse_moved = function(x,y)
    hud.pointer:setPosition(x, y)
end

hud.is_overlaping = function()
    local overlap, obj = false, "none"
    -- if hud.pointer:doesOverlapElement(Tools.info_panel_dialog) then
        -- overlap, obj = true, "hud_input"
    if hud.pointer:doesOverlapElement(hud.window) then
        overlap, obj = true, "hud"
    -- else
    end
    return overlap, obj
end


hud.setToolActiveKey = Tools.setToolActiveKey
hud.textinput = Tools.textinput
hud.keypressed = Tools.keypressed
hud.keyreleased = Tools.keyreleased

return hud
