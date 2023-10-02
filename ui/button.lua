-- button.lua
local Inky = require"library.Inky"
local theme = require"ui.theme"
local lg = love.graphics

local Button = Inky.defineElement(function(self)
    self:onPointer("press", function(self)
        self.props.color = "click"
    end)
    return function(_, x, y, w, h)
        love.graphics.setColor(theme.button[self.props.color])
        love.graphics.draw(IMAGE.button_frame, x, y)
        love.graphics.setColor(1,1,1)
        love.graphics.draw(IMAGE[self.props.key], x, y)
    end
end)

local function image_button(scene, name, fun)
    local button = (Inky.defineElement(function(self)
        return function(_, x, y, w, h)
            love.graphics.setColor(theme.button[self.props.color])
            love.graphics.draw(IMAGE[self.props.key], x, y)
        end
    end))(scene)

    button.props.key = name .. "_off"
    button.props.color = "off"

    button:onPointerEnter(function(self, pointer)
        self.props.color ="on_over"
    end)
    button:onPointerExit(function(self, pointer)
        self.props.color = "off"
    end)
    button:onPointer("press", function(self)
        self.props.color = "click"
    end)
    button:onPointer("release", function(self)
        fun(name)
        self.props.color ="on_over"
    end)
    return button
end

local function radio_button(scene, name, fun, active)
    local button = Button(scene)

    button.props.key = name
    button.props.color = active and "on" or "off"
    if active then button.props.activeKey=name end

    button:onPointerEnter(function(self, pointer)
        self.props.color ="on_over"
    end)
    button:onPointerExit(function(self, pointer)
        local isOn = self.props.activeKey==name
        self.props.color = isOn and "on" or "off"
    end)
    button:onPointer("release", function(self)
        fun(name)
    end)
    return button
end

local function toggle_button(scene, name, fun)
    local button = Button(scene)

    button.props.color = APP.toggle[name] and "on" or "off"
    button.props.key = name..(APP.toggle[name] and "_on" or "_off")

    button:onPointerEnter(function(self, pointer)
        self.props.color = (APP.toggle[name] and "on" or "off").."_over"
    end)
    button:onPointerExit(function(self, pointer)
        self.props.color = APP.toggle[name] and "on" or "off"
    end)
    button:onPointer("release", function(self)
        local atn = fun(name)
        self.props.color = (atn and "on" or "off").."_over"
        self.props.key = name..(atn and "_on" or "_off")
    end)
    return button
end

local function edit_button(scene, name, fun)
    local button = Button(scene)
    button.props.key = name
    button.props.color = "off"
    button:onPointerEnter(function(self, pointer)
        self.props.color ="on"
    end)
    button:onPointerExit(function(self, pointer)
        self.props.color = "off"
    end)
    button:onPointer("release", function(self)
        fun(name)
        self.props.color = "on"
    end)
    return button
end

local function texture_button(scene, name, fun)

    local button = (Inky.defineElement(function(self)
        return function(_, x, y, w, h)
            if self.props.active or self.props.selected then
                lg.setColor(0,0,0,1)
                local s = 1.25
                local sp = TILE_SIZE*0.125
                lg.rectangle("fill", x-sp-1,y-sp-1,w*s+2,h*s+2)
                lg.setColor(1,1,1)
                lg.draw(APP.texture[name],x-sp,y-sp,0,s,s)
            end
        end
    end))(scene)

    button.props.active = false
    button:onPointerEnter(function(self, pointer)
        self.props.active = true
    end)
    button:onPointerExit(function(self, pointer)
        self.props.active = false
    end)
    button:onPointer("release", function(self)
        self.props.selected = fun(name)
    end)
    return button
end

return {
    button = image_button,
    radio= radio_button,
    toggle = toggle_button,
    edit = edit_button,
    texture = texture_button
}

