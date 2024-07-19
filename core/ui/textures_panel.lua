----------------------------------------------------------------------------TOOLS PANEL

local Inky = require"library.Inky"
-- local Button = require"core.ui.button"
local minimize_button = require"core.ui.minimize_button"
local theme = require"core.ui.theme"
local Gradient_Label = require"core.ui.gradient_label"
local g = love.graphics

return function(tools, button_size, label_height)
    local _ = Inky.defineElement(function(self, scene)
        local texture_label = Gradient_Label(scene, "TEXTURE")
        local texture_atlas_size = TILE_SIZE*8 --tileset_height
        local current_texture_x = TILE_SIZE*2
        
        self.props.show = true
        self.props.height = texture_atlas_size*2
        self.props.max_height = texture_atlas_size*2
    
        local minimize_btn = minimize_button( scene, self.props, label_height+4)
        local minimize_btn_size = 16
        return function(_,x,y,w,h)
            g.setColor(RES.palette[ theme.tab.background])
            g.rectangle("fill", x, y, w, self.props.height)
            texture_label:render(x, y, w, label_height)
            minimize_btn:render(x+w-button_size,y,minimize_btn_size,minimize_btn_size)
            if self.props.show then
                x = x+4
                y = y+label_height+4
                
                g.setColor(RES.palette.white)
                g.draw(APP.texture_atlas, x, y)
                for _,tex in ipairs(tools.texture_buttons) do
                    tex:render(x+tex.props.x, y+tex.props.y, TILE_SIZE, TILE_SIZE)
                end
                x = x+w*0.5 - current_texture_x
                y = y+texture_atlas_size+button_size
                g.draw(APP.texture[MOUSE.texture],x,y,0,4,4)
            end
        end
    end)(tools.scene)
    return _
end