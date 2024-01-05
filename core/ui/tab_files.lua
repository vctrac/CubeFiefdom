-- tab_tools.lua
local utf8 = require("utf8")
local Inky = require"library.Inky"
local Button = require"core.ui.button"
local Theme = require"core.ui.Theme"

local gradient = require"core.misc.gradient"("horizontal",{ 0.45,0.45,0.45,1},Theme.tab.active_color)
local button_size = 22
local tool_buttons = {}
local texture_buttons = {}

local Files = {
    start_x = 4,
    start_y = button_size,
    -- integer indexed table
    info = {},
    info_count = 0,
    active_info_text = {},
    switch_tab = nil
}


local function Label(scene, name)
    local label = Inky.defineElement(function(self)
        return function(_,x,y,w,h)
            love.graphics.setColor(1,1,1)
            love.graphics.draw(gradient, x,y,0,w,h)
            love.graphics.print(name, x, y)
        end
    end)
    return label(scene)
end

local function Text_input(scene)
    local e = Inky.defineElement(function(self)
        self:onPointerExit(function(self, pointer)
            Files.active_info_text = {}
            self.props.active = false
            self.props.txt = self.props.old_txt
        end)
        self:onPointer("press", function(self)
            -- self.props.txt = ""
            self.props.active = true
            Files.active_info_text = {self.props.index, self.props.type}
        end)
        return function(_,x,y,w,h)
            local txt = self.props.txt
            if self.props.active then
                txt = txt ..'|'
                love.graphics.setColor(0.1,0.3,0.3)
            else
                love.graphics.setColor(0.2,0.2,0.2)
            end
            love.graphics.rectangle("fill", x,y,w,h)
            love.graphics.setColor(1,1,1)
            love.graphics.printf(txt, x, y, w, "center")
        end
    end)
    return e(scene)
end

Files.clear_info=function()
    for _,k in ipairs(Files.info) do
        k.key = nil
        k.value = nil
        k = {}
    end
    Files.info = {}
end

---@param scene table Inky scene
---@param id string tile id
---@param key string key|value
---@param value boolean|number|string info value
Files.new_info = function(scene, id, key, value)
    local index = #Files.info+1

    local k = Text_input(scene)
    k.props.txt = tostring(key)
    k.props.old_txt = tostring(key)
    k.props.index = index
    k.props.type = "key"
    
    local v = Text_input(scene)
    v.props.txt = tostring(value)
    v.props.old_txt = tostring(value)
    v.props.index = index
    v.props.type = "value"
    
    Files.info[index]={id=id, key = k, value=v}
    
    -- print("size",#Files.info)
end

Files.setToolActiveKey = function(key)
    MOUSE.tool = key
    for i=1,2 do
        local you = tool_buttons[1][i].props.key==key
        tool_buttons[1][i].props.color = you and "on" or "off"
        tool_buttons[1][i].props.activeKey = key
    end
end
Files.setTextureButtons = function(scene, name)
    local index = #texture_buttons+1
    texture_buttons[index] = Button.texture(scene, name, function(n)
        for i=1,#texture_buttons do
            texture_buttons[i].props.selected = false
        end
        MOUSE:set_texture(n)
        return n==name
    end)
    local ipos = From_id(name)

    texture_buttons[index].props.x = ipos[1]*TILE_SIZE
    texture_buttons[index].props.y = ipos[2]*TILE_SIZE
end

local function toggle(name)
    APP.toggle[name] = not APP.toggle[name]
    return APP.toggle[name]
end

-- Files.info[1] = Text_input()
Files.textinput = function(self, t)
    local index,tipo = unpack(Files.active_info_text)
    local field = Files.info[index]
    
    -- print(bytecount)
    if field then
        local txt = field[tipo].props.txt
        local len = utf8.len(txt)
        -- local byteoffset = utf8.offset(txt, -1)
        -- print(bytecount, byteoffset)
        if len==9 then
            txt = string.sub(txt,1, len-1)
        end
        field[tipo].props.txt = txt .. t
    end
end
Files.keypressed = function( key)
    -- if key then print(key) end
    if key == "backspace" then
        local index,tipo = unpack(Files.active_info_text)
        local field = Files.info[index]
        if field then
            -- get the byte offset to the last UTF-8 character in the string.
            local len = utf8.len(field[tipo].props.txt)
            if len>0 then
                -- remove the last UTF-8 character.
                -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
                field[tipo].props.txt = string.sub(field[tipo].props.txt, 1, len - 1)
            end
        end
    elseif key == "return" then
        local index,tipo = unpack(Files.active_info_text)
        local field = Files.info[index]
        if field then
            --tipo is 'key'
            if tipo=="key" then
                APP.map:set_info_key(field.id, field.key.props.old_txt, field.key.props.txt)
                field.key.props.old_txt = field.key.props.txt
            else
                APP.map:add_info(field.id, field.key.props.txt, field.value.props.txt)
                field.value.props.old_txt = field.value.props.txt
            end
            Files.active_info_text = {}
            field[tipo].props.active = false
        end
    end
end
Files.element = Inky.defineElement(function(self, scene)
    local tools_tab = Button.button(scene, "tools", Files.switch_tab)

    local info_label = Label(scene, "SAVE")
    local save_lua = Button.button(scene, "save_lua", function()
        APP.save_lua()
    end)
    local save_json = Button.button(scene, "save_json", function()
        APP.save_json()
    end)
    local save_obj = Button.button(scene, "save_obj", function()
        APP.save_obj()
    end)

    local label_height = 16
    return function(_,x,y,w,h)
        local sx = x+Files.start_x
        local sy = y+Files.start_y

        tools_tab:render(x+w, y+64, 20, 60)
        love.graphics.setColor(1,1,1)
        love.graphics.draw(DATA.image.files_on, x+w, y)

        --INFO--------------------------------------------------
        info_label:render(x, sy, w, label_height)
        sy = sy+label_height*1.5

        save_lua:render(sx, sy, w, label_height)
        sy = sy+label_height*1.5
        save_json:render(sx, sy, w, label_height)
        sy = sy+label_height*1.5
        save_obj:render(sx, sy, w, label_height)
        
    end
end)

return Files