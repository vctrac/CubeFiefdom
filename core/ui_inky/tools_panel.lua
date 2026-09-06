----------------------------------------------------------------------------TOOLS PANEL

local Inky = require"library.Inky"
local Button = require"core.ui.button"
local minimize_button = require"core.ui.minimize_button"
local theme = require"core.ui.theme"
local Gradient_Label = require"core.ui.gradient_label"
local g = love.graphics

return function(tools, button_size, label_height)
    local _ = Inky.defineElement(function(self, scene)
        tools.buttons[1] = {
            Button.radio(scene, "pencil", tools.setToolActiveKey, true),
            Button.radio(scene, "brush", tools.setToolActiveKey),
            Button.radio(scene, "object", tools.setToolActiveKey),
            Button.radio(scene, "select", tools.setToolActiveKey)
        }
        tools.buttons[2] = {
            Button.toggle(scene, "texture", APP.option_toggle),
            Button.toggle(scene, "grid", APP.option_toggle),
        -- }
        -- tools.buttons[3] = {
            Button.toggle(scene, "light", APP.option_toggle),
            Button.toggle(scene, "retro", APP.option_toggle),
        }
        tools.buttons[3] = {
            Button.edit(scene, "undo", APP.cube_map_history),
            Button.edit(scene, "redo", APP.cube_map_history),
        }
        self.props.show = true
        self.props.height = (#tools.buttons+1)*button_size
        self.props.max_height = (#tools.buttons+1)*button_size
    
        local tools_label = Gradient_Label(scene, "TOOLS")
        local minimize_btn = minimize_button( scene, self.props, label_height+4)
        local minimize_btn_size = 16
        return function(_,x,y,w,h)
            g.setColor(RES.palette[ theme.tab.background])
            g.rectangle("fill", x, y, w, self.props.height)
            tools_label:render(x, y, w, label_height)
            minimize_btn:render(x+w-button_size,y,minimize_btn_size,minimize_btn_size)
            if self.props.show then
                g.setColor(RES.palette.white)
                local sx = x+button_size
                y = y+label_height+4
                for row=1,#tools.buttons do
                    local yy = y+button_size*(row-1)
                    for column=1,#tools.buttons[row] do
                        local xx = sx+button_size*(column-1)
                        tools.buttons[row][column]:render(xx, yy, button_size, button_size)
                    end
                end
            end
        end
    end)(tools.scene)
    return _
end