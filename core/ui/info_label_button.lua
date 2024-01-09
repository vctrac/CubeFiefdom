local i = require("library.Inky")
local t = require"core.ui.theme"
local g = love.graphics

local function lb(scene, k, v, f)
    local l= i.defineElement(function(self)
        return function(_, x, y, w, h)
            g.setColor(t.label.background)
            g.rectangle("fill",x,y,w,h)
            g.setColor(t.label.text)
            g.printf(k,x,y,w,"left")
            g.printf(v,x,y,w,"right")
        end
    end)(scene)
    l:onPointer("release", f)
    return l
end
return lb