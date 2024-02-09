local i = require("library.Inky")
local t = require"core.ui.theme"
local g = love.graphics

local function lb(scene, name, value, f)
    local l= i.defineElement(function(self)
        self.props.color = "background"
        return function(_, x, y, w, h)
            g.setColor(RES.palette[ t.label[self.props.color]])
            g.rectangle("fill",x,y,w,h)
            g.setColor(RES.palette[ t.label.text])
            g.printf(name,x,y,w,"left")
            g.printf(value,x,y,w,"right")
        end
    end)(scene)
    l:onPointerEnter(function(self, pointer)
        self.props.color ="highlight"
    end)
    l:onPointerExit(function(self, pointer)
        self.props.color = "background"
    end)
    l:onPointer("press", function(self)
        self.props.color = "click"
    end)
    l:onPointer("release", function(self)
        f()
        self.props.color ="highlight"
    end)
    return l
end

return lb