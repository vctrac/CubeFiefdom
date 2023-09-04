local Inky = require("library.inky")
local slider = require"ui.slider"

local rgb_color = {
    {1,0.2,0.2},
    {0.2,1,0.2},
    {0.2,0.2,1},
}

return function(scene, anchor_y, get_color)

    return (Inky.defineElement(function(self, scene)
        local rgb = {}

        local get_values = function()
            local c = {}
            for i=1,3 do
                c[i] = rgb[i].props.progress
            end
            return c
        end
        for i=1,3 do
            rgb[i] = slider(scene)
            rgb[i].props.progress = 1
            rgb[i].props.color = rgb_color[i]
            rgb[i]:onPointer("release", function(_, pointer)
                pointer:captureElement(rgb[i], false)
                get_color(self, get_values())
            end)
        end

        return function(_, x, y, w, h)
            
            local yy = anchor_y+y
            local nh = h/3

            love.graphics.setColor(0.3,0.3,0.3)
            love.graphics.rectangle("fill", x, yy, w, h)
            for i,color in ipairs(rgb) do
                color:render(x+5, yy+(i-1)*nh, w-45, nh)
            end
        end
    end))(scene)
end