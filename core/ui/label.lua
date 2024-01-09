local i = require("library.Inky")
local t = require"core.ui.theme"
local g = love.graphics
local l = i.defineElement(function(self)
    return function(_, x, y, w, h)
        g.setColor(t.label.background)
        g.rectangle("fill",x,y,w,h)
        g.setColor(t.label.text)
        g.printf(self.props.text,x,y,w,"center")
    end
end)

return l