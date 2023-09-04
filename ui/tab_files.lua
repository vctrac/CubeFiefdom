-- local Inky = require("library.inky")
local label = require("ui.label")
local lg = love.graphics

return function(system, scene)
    local anchor_x = 5
    local files = label(scene)
    local show_options = false
    files:onPointerEnter(function( self, pointer, ...)
        self.props.color = {1,1,0.2,1}
    end)
    files:onPointer("press", function(self)
        show_options = not show_options
    end)
    return function(_, x, y, w, h)
        lg.setColor(0.2,0.2,0.2)
        lg.rectangle("fill",x,y,w,h)

        files:render(anchor_x+x,y,w,h)
    end
end

-- return system_bar()