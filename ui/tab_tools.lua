-- tab_tools.lua
local utf8 = require("utf8")
local Inky = require"library.inky"
local Button = require"ui.button"
local Theme = require"ui.Theme"

local gradient = (loadfile("misc/gradient.lua")())("horizontal",{ 0.45,0.45,0.45,1},Theme.tab.active_color)
local button_size = 22
local tool_buttons = {}
local texture_buttons = {}

local Tools = {
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
            Tools.active_info_text = {}
            self.props.active = false
            self.props.txt = self.props.old_txt
        end)
        self:onPointer("press", function(self)
            -- self.props.txt = ""
            self.props.active = true
            Tools.active_info_text = {self.props.index, self.props.type}
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

Tools.clear_info=function()
    for _,k in ipairs(Tools.info) do
        k.key = nil
        k.value = nil
        k = {}
    end
    Tools.info = {}
end

---@param scene table Inky scene
---@param id string tile id
---@param key string key|value
---@param value boolean|number|string info value
Tools.new_info = function(scene, id, key, value)
    local index = #Tools.info+1

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
    
    Tools.info[index]={id=id, key = k, value=v}
    
    -- print("size",#Tools.info)
end

Tools.setToolActiveKey = function(key)
    MOUSE.tool = key
    for i=1,2 do
        local you = tool_buttons[1][i].props.key==key
        tool_buttons[1][i].props.color = you and "on" or "off"
        tool_buttons[1][i].props.activeKey = key
    end
end
Tools.setTextureButtons = function(scene, name)
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

-- Tools.info[1] = Text_input()
Tools.textinput = function(self, t)
    local index,tipo = unpack(Tools.active_info_text)
    local field = Tools.info[index]
    
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
Tools.keypressed = function( key)
    -- if key then print(key) end
    if key == "backspace" then
        local index,tipo = unpack(Tools.active_info_text)
        local field = Tools.info[index]
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
        local index,tipo = unpack(Tools.active_info_text)
        local field = Tools.info[index]
        if field then
            --tipo is 'key'
            if tipo=="key" then
                APP.map:set_info_key(field.id, field.key.props.old_txt, field.key.props.txt)
                field.key.props.old_txt = field.key.props.txt
            else
                APP.map:add_info(field.id, field.key.props.txt, field.value.props.txt)
                field.value.props.old_txt = field.value.props.txt
            end
            Tools.active_info_text = {}
            field[tipo].props.active = false
        end
    end
end
Tools.element = Inky.defineElement(function(self, scene)
    local files_tab = Button.button(scene, "files", Tools.switch_tab)

    tool_buttons[1] = {
        Button.radio(scene, "pencil", Tools.setToolActiveKey, true),
        Button.radio(scene, "brush", Tools.setToolActiveKey)
    }
    tool_buttons[2] = {
        Button.toggle(scene, "texture", toggle),
        Button.toggle(scene, "grid", toggle),
    }
    tool_buttons[3] = {
        Button.toggle(scene, "light", toggle),
    }
    tool_buttons[4] = {
        Button.edit(scene, "undo", APP.cube_map_history),
        Button.edit(scene, "redo", APP.cube_map_history),
    }
    local texture_label = Label(scene, "TEXTURE")
    local info_label = Label(scene, "TILE INFO")
    local add_info = Button.button(scene, "new_info", function()
        Tools.new_info(scene, MOUSE.texture, "", "")
    end)
    -- new_info(scene, "0:0", "key")
    -- new_info(scene, "0:0", "value")
    local label_height = 16
    local texture_atlas_size = 8*TILE_SIZE
    local current_texture_x = TILE_SIZE*2
    return function(_,x,y,w,h)

        --draw tabs
        files_tab:render(x+w, y, 20, 60)
        love.graphics.setColor(1,1,1)
        love.graphics.draw(IMAGE.tools_on, x+w, y+64)

        --TOOLS-----------------------------------------------
        local sx = x+Tools.start_x
        local sy = y+Tools.start_y
        for row=1,#tool_buttons do
            local yy = sy+button_size*(row-1)
            for column=1,#tool_buttons[row] do
                local xx = sx+button_size*(column-1)
                tool_buttons[row][column]:render(xx, yy, button_size, button_size)
            end
        end
        
        --TEXTURES----------------------------------------------
        sy = sy+button_size*(#tool_buttons+1)
        texture_label:render(x, sy, w, label_height)
        sx = x+4
        sy = sy+label_height*2
        love.graphics.draw(APP.texture_atlas, sx, sy)
        for _,tex in ipairs(texture_buttons) do
            tex:render(sx+tex.props.x, sy+tex.props.y, TILE_SIZE, TILE_SIZE)
        end
        sx = x+w*0.5 - current_texture_x
        sy = sy+texture_atlas_size+button_size
        love.graphics.draw(APP.texture[MOUSE.texture],sx,sy,0,4,4)

        sy = sy+texture_atlas_size

        --INFO--------------------------------------------------
        info_label:render(x, sy, w, label_height)
        sy = sy+label_height+10
        local ww = w*0.5

        for _,tab in ipairs(Tools.info) do
            tab.key:render(x, sy, ww, label_height)
            tab.value:render(x+ww, sy, ww, label_height)
            sy = sy+label_height+2
        end

        --draw add_info button
        add_info:render(x, sy, w, label_height)
    end
end)

return Tools