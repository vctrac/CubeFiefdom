----------------------------------------------------------------------------FILES PANEL

local Inky = require"library.Inky"
local Button = require"core.ui.button"
local minimize_button = require"core.ui.minimize_button"
local theme = require"core.ui.theme"
local Gradient_Label = require"core.ui.gradient_label"
local g = love.graphics
return function(tools, button_size, label_height)
    local lh4 = label_height+4
    local _ = Inky.defineElement(function(self, scn)
        local files_label = Gradient_Label(scn, "FILES")
        local save_lua = Button.label(scn, "save as lua", "left", APP.save_lua)
        local save_json = Button.label(scn, "save as json", "left", APP.save_json)
        local save_obj = Button.label(scn, "save as obj", "left", APP.save_obj)
        self.props.show = true
        self.props.height = label_height*5
        self.props.max_height = label_height*5
        local minimize_btn = minimize_button( scn, self.props, lh4)
        local minimize_btn_size = 16
        return function(_,x,y,w,h)
            g.setColor(theme.tab.active_color)
            g.rectangle("fill", x, y, w, self.props.height)
            files_label:render(x, y, w, h)
            minimize_btn:render(x+w-button_size,y,minimize_btn_size,minimize_btn_size)
            if self.props.show then
                local sy = y+lh4
                save_lua:render(x, sy, w, label_height)
                sy = sy+lh4
                save_json:render(x, sy, w, label_height)
                sy = sy+lh4
                save_obj:render(x, sy, w, label_height)
            end
        end
    end)(tools.scene)
    return _
end