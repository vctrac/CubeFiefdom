-- tab_tools.lua
local utf8 = require("utf8")
local Inky = require"library.Inky"
local Button = require"core.ui.button"
local Theme = require"core.ui.Theme"
local Info_button = require"core.ui.info_label_button"
local Gradient_Label = require"core.ui.gradient_label"
local button_size = 22
local tool_buttons = {}
local texture_buttons = {}
local lg = love.graphics

local Tools = {
    start_x = 4,
    start_y = button_size,
    -- integer indexed table
    info = {},
    info_count = 0,
    active_info_text = {},
    switch_tab = nil
}
local text_inputs = {
    info = {}
}

local function text_field_active( i)
    for index,field in pairs(text_inputs.info) do
        field.props.active = index==i
    end
end


local function Text_input(name, scene)
    local e = Inky.defineElement(function(self)
        self:onPointer("press", function(this)
            text_field_active( name)
            Tools.active_info_text = {name = name, props = this.props}
        end)
        return function(_,x,y,w,h)
            local txt = self.props.txt
            if self.props.active then
                txt = txt ..'|'
                lg.setColor(0.1,0.3,0.3)
            else
                lg.setColor(0.1,0.1,0.1)
            end
            lg.rectangle("fill", x,y,w,h)
            lg.setColor(1,1,1)
            lg.printf(txt, x, y, w, "center")
        end
    end)
    return e(scene)
end

local function info_input_box(scene)
    local e = Inky.defineElement(function(self)
        -- self.props.active = true
        text_inputs.info.key = Text_input("key", scene)
        text_inputs.info.key.props.txt = ""
        text_inputs.info.key.props.old_txt = ""
        text_inputs.info.value = Text_input("value", scene)
        text_inputs.info.value.props.txt = ""
        -- text_inputs.info.value.props.old_txt = ""
        local btn_ok = Button.button(scene, "ok", function()
            print"ok"
            local tik = text_inputs.info.key.props
            local tiv = text_inputs.info.value.props
            -- print("here", text_inputs.info.value.props.txt)
            if tik.txt ~= tik.old_txt then
                APP.map:set_info_key(MOUSE.texture,tik.old_txt, tik.txt, tiv.txt)
                Tools.load_tool_info(scene, MOUSE.texture)
            else
                APP.map:add_info(MOUSE.texture, tik.txt, tiv.txt)
                Tools.new_info(scene, tik.txt, tiv.txt)
            end
            -- text_inputs.info.key.props.old_txt = text_inputs.info.key.props.txt
            -- text_inputs.info.value.props.old_txt = text_inputs.info.value.props.txt
            self.props.visible = false
            text_inputs:clear()
        end)
        local btn_cancel = Button.button(scene, "cancel", function()
            print"cancel"
            text_inputs:clear()
            -- text_inputs.info.key.props.txt = ""
            -- text_inputs.info.value.props.txt = ""
            self.props.visible = false
        end)
        local btn_discard = Button.button(scene, "discard", function()
            print"discard"
            APP.map:remove_info(MOUSE.texture, text_inputs.info.key.props.txt)
            Tools.load_tool_info(scene, MOUSE.texture)
            self.props.visible = false
            text_inputs:clear()
        end)
        local btn_size = 16
        return function(_,x,y,w,h)
            
            lg.setColor(0.2,0.2,0.2)
            lg.rectangle("fill", x,y,w,h)
            lg.setColor(1,1,1)
            lg.printf("name:", x, y, w, "left")
            local yy = y+btn_size+4
            --txt_input
            text_inputs.info.key:render(x,yy,w,btn_size)
            yy = yy+btn_size+4
            lg.printf("value:", x, yy, w, "left")
            yy = yy+btn_size+4
            --txt_input
            text_inputs.info.value:render(x,yy,w,btn_size)
            -- yy = y+btn_size
            btn_ok:render(x+4,y+h-btn_size-4,btn_size,btn_size)
            btn_discard:render(x+(w-btn_size)*0.5,y+h-btn_size-4,btn_size,btn_size)
            btn_cancel:render(x+w-btn_size-4,y+h-btn_size-4,btn_size,btn_size)
        end
    end)
    return e(scene)
end

text_inputs.clear = function(self)
    self.info.key.props.txt = ""
    self.info.key.props.old_txt = ""
    self.info.value.props.txt = ""
    text_field_active( "key")
end

Tools.clear_info=function()
    for key in pairs(Tools.info) do
        Tools.info[key] = nil
    end
    Tools.info = {}
end

Tools.load_tool_info = function(scene, id)
    Tools.clear_info()
    local info = APP.map:get_info(id)
    for k,v in pairs(info) do
        Tools.new_info(scene, k, v)
    end
end

-- -@param scene table Inky scene
-- -@param id string tile id
---@param key string key|value
---@param value boolean|number|string info value
Tools.new_info = function( scene, key, value)
    Tools.info[key] = Info_button(scene, key, tostring(value),
    function(self)
        Tools.info_panel_dialog.props.visible = true
        text_inputs.info.key.props.txt = key
        text_inputs.info.key.props.old_txt = key
        text_inputs.info.value.props.txt = tostring(value)
    end)
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

Tools.textinput = function(self, t)
    if self.active_info_text.name then
        local txt = Tools.active_info_text.props.txt
        local len = utf8.len(txt)
        -- local byteoffset = utf8.offset(txt, -1)
    --     -- print(bytecount, byteoffset)
        if len==9 then
            txt = string.sub(txt,1, len-1)
        end
        self.active_info_text.props.txt = txt .. t
    end
end
Tools.keypressed = function(self, key)
    -- if key then print(key) end
    if key == "backspace" then
        local txt = self.active_info_text.props.txt
        local len = utf8.len(txt)
        if len>0 then
            self.active_info_text.props.txt = string.sub(txt, 1, len - 1)
        end
    -- elseif key == "return" then
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
    local tools_label = Gradient_Label(scene, "Tools")
    local texture_label = Gradient_Label(scene, "TEXTURE")
    local infos_label = Gradient_Label(scene, "TILE INFO")
    
    Tools.info_panel_dialog = info_input_box(scene)

    local add_info = Button.label(scene, "new", "center",function()
        if text_inputs.info["key"] then
            Tools.active_info_text = {name = "key", props = text_inputs.info.key.props}
        else
            Tools.active_info_text = {}
        end
        Tools.info_panel_dialog.props.visible = true
    end)
    -- new_info(scene, "0:0", "key")
    -- new_info(scene, "0:0", "value")
    local info_panel_height = 128
    local label_height = 16
    local texture_atlas_size = 8*TILE_SIZE
    local current_texture_x = TILE_SIZE*2

    return function(_,x,y,w,h)

        --TABS-----------------------------------------------
        files_tab:render(x+w, y, 20, 60)
        lg.setColor(1,1,1)
        lg.draw(DATA.image.tools, x+w, y+64)

        --LABEL-----------------------------------------------
        tools_label:render(x, y, w, label_height)
        --TOOLS-----------------------------------------------
        lg.setColor(1,1,1)
        local sx = x+Tools.start_x
        local sy = y+Tools.start_y
        for row=1,#tool_buttons do
            local yy = sy+button_size*(row-1)
            for column=1,#tool_buttons[row] do
                local xx = sx+button_size*(column-1)
                tool_buttons[row][column]:render(xx, yy, button_size, button_size)
            end
        end

        --LABEL----------------------------------------------
        sy = sy+button_size*(#tool_buttons+1)
        texture_label:render(x, sy, w, label_height)
        sx = x+4
        sy = sy+label_height*2
        --TEXTURES----------------------------------------------
        lg.setColor(1,1,1)
        lg.draw(APP.texture_atlas, sx, sy)
        for _,tex in ipairs(texture_buttons) do
            tex:render(sx+tex.props.x, sy+tex.props.y, TILE_SIZE, TILE_SIZE)
        end
        sx = x+w*0.5 - current_texture_x
        sy = sy+texture_atlas_size+button_size
        lg.draw(APP.texture[MOUSE.texture],sx,sy,0,4,4)

        sy = sy+texture_atlas_size
        --LABEL----------------------------------------------
        infos_label:render(x, sy, w, label_height)
        sy = sy+label_height+5
        --INFO--------------------------------------------------

        for _,lb in pairs(Tools.info) do
            lb:render(x, sy, w, label_height)
            sy = sy+label_height+1
        end
        sy = sy+1
        --draw add_info button
        add_info:render(x, sy, w, label_height)

        if Tools.info_panel_dialog.props.visible then
            Tools.info_panel_dialog:render(x+w+5, sy, w, info_panel_height)
        end
    end
end)

return Tools