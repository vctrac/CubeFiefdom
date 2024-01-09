local i = require("library.Inky")
local t = require"core.ui.theme"
local gradient = require"core.misc.gradient"("horizontal", t.label.foreground, t.tab.active_color)
local g = love.graphics
local function l(s, n)
    local e = i.defineElement(function(self)
        return function(_,x,y,w,h)
            g.setColor(1,1,1)
            g.draw(gradient, x,y,0,w,h)
            g.setColor(t.label.text)
            g.print(n, x, y)
        end
    end)
    return e(s)
end

return l