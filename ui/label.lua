local Inky = require("library.inky")
local lg = love.graphics
local label_bar = Inky.defineElement(function(self)
    return function(_, x, y, w, h)
        lg.setColor(self.props.color)
        lg.rectangle("fill",x,y,w,h)
        lg.setColor(1,1,1)
        lg.printf(self.props.text,x,y,w,"center")
    end
end)