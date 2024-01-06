-- tab_tools.lua
local utf8 = require("utf8")
local Inky = require"library.Inky"
local Button = require"core.ui.button"
local Theme = require"core.ui.Theme"

local gradient = require"core.misc.gradient"("horizontal",{ 0.45,0.45,0.45,1},Theme.tab.active_color)
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

local function Text_input(name, scene)
    local e = Inky.defineElement(function(self)
        -- self:onPointerExit(function(self, pointer)
        --     Tools.active_info_text = {}
            -- self.props.active = false
            -- self.props.txt = self.props.old_txt
        -- end)
        self:onPointer("press", function(this)
            -- self.props.txt = ""
            this.props.active = true
            Tools.active_info_text = {type = name, props = this.props}
        end)
        return function(_,x,y,w,h)
            local txt = self.props.txt
            if self.props.active then
                txt = txt ..'|'
                love.graphics.setColor(0.1,0.3,0.3)
            else
                love.graphics.setColor(0.1,0.1,0.1)
            end
            love.graphics.rectangle("fill", x,y,w,h)
            love.graphics.setColor(1,1,1)
            love.graphics.printf(txt, x, y, w, "center")
        end
    end)
    return e(scene)
end

local function info_input_box(scene)
    local e = Inky.defineElement(function(self)
        -- self:onPointerExit(function(self, pointer)
        --     Tools.active_info_text = {}
        -- self.props.active = false
        --     self.props.txt = self.props.old_txt
        -- end)
        -- self:onPointer("press", function(self)
        --     -- self.props.txt = ""
        --     self.props.active = true
        --     Tools.active_info_text = {self.props.index, self.props.type}
        -- end)
        -- self:onPointerEnter( function(self)
            -- MOUSE.set_mode("hud")
            -- print"mouse enter"
        --     -- self.props.txt = ""
        --     self.props.active = true
        --     Tools.active_info_text = {self.props.index, self.props.type}
        -- end)
        local name_input = Text_input("key", scene)
        name_input.props.txt = ""
        name_input.props.old_txt = ""
        local value_input = Text_input("value", scene)
        value_input.props.txt = ""
        value_input.props.old_txt = ""
        local btn_ok = Button.button(scene, "ok", function()
            -- print"ok"
            APP.map:add_info(MOUSE.texture, name_input.props.txt, value_input.props.txt)
            self.dead = true
        end)
        local btn_cancel = Button.button(scene, "cancel", function()
            print"cancel"
            self.dead = true
        end)
        local btn_discard = Button.button(scene, "discard", function() print"discard" end)
        local btn_size = 16
        return function(_,x,y,w,h)
            
            love.graphics.setColor(0.2,0.2,0.2)
            love.graphics.rectangle("fill", x,y,w,h)
            love.graphics.setColor(1,1,1)
            love.graphics.printf("name:", x, y, w, "left")
            local yy = y+btn_size+4
            --txt_input
            name_input:render(x,yy,w,btn_size)
            yy = yy+btn_size+4
            love.graphics.printf("value:", x, yy, w, "left")
            yy = yy+btn_size+4
            --txt_input
            value_input:render(x,yy,w,btn_size)
            -- yy = y+btn_size
            btn_ok:render(x+4,y+h-btn_size-4,btn_size,btn_size)
            btn_discard:render(x+(w-btn_size)*0.5,y+h-btn_size-4,btn_size,btn_size)
            btn_cancel:render(x+w-btn_size-4,y+h-btn_size-4,btn_size,btn_size)
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

-- -@param scene table Inky scene
---@param id string tile id
---@param key string key|value
---@param value boolean|number|string info value
Tools.new_info = function( id, key, value)
    local index = #Tools.info+1

    -- local k = Text_input(scene)
    -- k.props.txt = tostring(key)
    -- k.props.old_txt = tostring(key)
    -- k.props.index = index
    -- k.props.type = "key"
    
    -- local v = Text_input(scene)
    -- v.props.txt = tostring(value)
    -- v.props.old_txt = tostring(value)
    -- v.props.index = index
    -- v.props.type = "value"
    
    Tools.info[index]={id=id, key = key, value=value}
    return index
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

-- Tools.info[1] = Text_input()
Tools.textinput = function(self, t)
    -- local index, tipo = unpack(Tools.active_info_text)
    -- local field = Tools.info[index]
    print(t)
    -- print(bytecount)
    -- if field then
        local txt = Tools.active_info_text.props.txt
        local len = utf8.len(txt)
        -- local byteoffset = utf8.offset(txt, -1)
    --     -- print(bytecount, byteoffset)
        if len==9 then
            txt = string.sub(txt,1, len-1)
        end
        Tools.active_info_text.props.txt = txt .. t
    -- end
end
Tools.keypressed = function( key)
    -- if key then print(key) end
    if key == "backspace" then
        local txt = Tools.active_info_text.props.txt
        -- local field = Tools.info[index]
        -- if field then
            -- get the byte offset to the last UTF-8 character in the string.
            local len = utf8.len(txt)
            if len>0 then
                -- remove the last UTF-8 character.
                -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
                Tools.active_info_text.props.txt = string.sub(txt, 1, len - 1)
            end
        -- end
    elseif key == "return" then
        local txt = Tools.active_info_text.props.txt
        local len = utf8.len(txt)
        if len>0 then
            -- local info_type = Tools.active_info_text.props.type
            -- local old_txt = Tools.active_info_text.props.old_txt
            -- if info_type == "key" then
                -- APP.map:set_info_key(MOUSE.texture, old_txt, txt)
                -- Tools.active_info_text.props.old_txt = txt
                -- Tools.new_info( MOUSE.texture, "", "")
            -- else
                -- APP.map:add_info(MOUSE.texture, field.key.props.txt, field.value.props.txt)
                -- Tools.active_info_text.props.old_txt = txt
            -- end
            Tools.active_info_text.props.old_txt = txt
        end
        -- local index,tipo = unpack(Tools.active_info_text)
        -- local field = Tools.info[index]
        -- if field then
            --tipo is 'key'
            -- if tipo=="key" then
        --         APP.map:set_info_key(field.id, field.key.props.old_txt, field.key.props.txt)
        --         field.key.props.old_txt = field.key.props.txt
        --     else
        --         APP.map:add_info(field.id, field.key.props.txt, field.value.props.txt)
                -- field.value.props.old_txt = field.value.props.txt
        --     end
        --     Tools.active_info_text = {}
        --     field[tipo].props.active = false
        -- end
    end
end
Tools.element = Inky.defineElement(function(self, scene)
    local files_tab = Button.button(scene, "files", Tools.switch_tab)

    tool_buttons[1] = {
        Button.radio(scene, "pencil", Tools.setToolActiveKey, true),
        Button.radio(scene, "brush", Tools.setToolActiveKey)
    }
    tool_buttons[2] = {
        Button.toggle(scene, "texture", APP.option_toggle),
        Button.toggle(scene, "grid", APP.option_toggle),
    }
    tool_buttons[3] = {
        Button.toggle(scene, "light", APP.option_toggle),
        Button.toggle(scene, "retro", APP.option_toggle),
    }
    tool_buttons[4] = {
        Button.edit(scene, "undo", APP.cube_map_history),
        Button.edit(scene, "redo", APP.cube_map_history),
    }
    local texture_label = Label(scene, "TEXTURE")
    local info_label = Label(scene, "TILE INFO")
    -- local info_panel = info_input_box(scene)
    local info_panel
    local add_info = Button.button(scene, "new_info", function()
        -- Tools.new_info(scene, MOUSE.texture, "", "")
        info_panel = info_input_box(scene)
        self.props.info_panel = info_panel
    end)
    -- new_info(scene, "0:0", "key")
    -- new_info(scene, "0:0", "value")
    local info_panel_height = 128
    local label_height = 16
    local texture_atlas_size = 8*TILE_SIZE
    local current_texture_x = TILE_SIZE*2

    return function(_,x,y,w,h)

        --draw tabs
        files_tab:render(x+w, y, 20, 60)
        love.graphics.setColor(1,1,1)
        love.graphics.draw(DATA.image.tools, x+w, y+64)

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
        sy = sy+label_height+5
        -- local ww = w*0.5

        for key,value in pairs(APP.map:get_info(MOUSE.texture)) do
            -- print(key, value)
            love.graphics.printf(key, x+4, sy, w, "left")
            love.graphics.printf(tostring(value), x, sy, w-4, "right")
            sy = sy+10
        end
        sy = sy+10
        --draw add_info button
        add_info:render(x, sy, w, label_height)

        if info_panel then
            info_panel:render(x+w+5, sy, w, info_panel_height)
            if info_panel.dead then
                info_panel = nil
            end
        end
        
    end
end)

return Tools