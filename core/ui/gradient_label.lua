local i = require("library.Inky")
local t = require"core.ui.theme"
local gradient = require"core.misc.gradient"("horizontal", RES.palette[t.label.foreground], RES.palette[t.tab.background])
local g = love.graphics
local function l(s, n)
    local e = i.defineElement(function(self)
        return function(_,x,y,w,h)
            g.setColor(RES.palette.white)
            g.draw(gradient, x,y,0,w,h)
            g.setColor(RES.palette[t.label.text])
            g.print(n, x, y)
        end
    end)
    return e(s)
end

return l