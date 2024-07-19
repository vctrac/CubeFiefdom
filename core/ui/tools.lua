-- tab_tools.lua
local utf8 = require("utf8")
local Inky = require"library.Inky"
local Button = require"core.ui.button"
local theme = require"core.ui.theme"
local Info_button = require"core.ui.info_label_button"
local Gradient_Label = require"core.ui.gradient_label"
local button_size = 22
local label_height = 16
local current_text_input = "texture"
local text_inputs = {
    -- current = "texture",
    texture = {},
    object={},
}
-- local Tools.buttons = {}
-- local texture_buttons = {}
local lg = love.graphics
-- local blinking_cursor_timer = 0
local info_data = {
    texture = {},
    object = {}
}
local panel_input = {}

local Tools = {
    start_x = 4,
    start_y = button_size,
    -- integer indexed table
    buttons = {},
    texture_buttons = {},
    -- texture_info = {},
    -- object_info = {},
    info_count = 0,
    active_text = {},
    current = "texture", --or "object"
    switch_tab = nil,
}


--radio function for text fields
local function text_field_active( index)
    local t = text_inputs[ current_text_input]
    for i,field in pairs( t) do
        field.props.active = i==index
    end
end
local function text_field_get_active( )
    return Tools.active_text.name=="key" and "value" or "key"
end

local function Text_input( name, scene)
    local e = Inky.defineElement(function(self)
        self:onPointer("press", function(this)
            text_field_active( name)
            Tools.active_text = {name = name, props = this.props}
        end)
        return function(_,x,y,w,h)
            local txt = self.props.txt
            if self.props.active then
                txt = txt ..'|'
                lg.setColor(RES.palette[ theme.text_input.active])
            else
                lg.setColor(RES.palette[ theme.text_input.inactive])
            end
            lg.rectangle("fill", x,y,w,h)
            lg.setColor(RES.palette.white)
            lg.printf(txt, x, y, w, "center")
        end
    end)
    return e(scene)
end
local function ok_pressed( )
    -- print"ok"
    local tik = text_inputs[current_text_input].key.props
    local tiv = text_inputs[current_text_input].value.props

    -- remove whitespace characters
    tik.old_txt = string.gsub(tik.old_txt, "%s", "")
    tik.txt = string.gsub(tik.txt, "%s", "")
    tiv.txt = string.gsub(tiv.txt, "%s", "")

    if #tik.txt==0 then return end
    if #tiv.txt==0 then tiv.txt = "false" end
    if Tools.current=="texture" then
        if tik.txt ~= tik.old_txt then
            APP.texture_info:set_key(MOUSE.texture,tik.old_txt, tik.txt, tiv.txt)
            Tools.load_texture_info(Tools.scene, MOUSE.texture)
        else
            APP.texture_info:add(MOUSE.texture, tik.txt, tiv.txt)
            Tools.new_info(Tools.scene, "texture", tik.txt, tiv.txt)
        end
    else
        if tik.txt ~= tik.old_txt then
            APP.selected_info:set_key(MOUSE.selected.id,tik.old_txt, tik.txt, tiv.txt)
            Tools.load_object_info(Tools.scene, MOUSE.selected.id)
        else
            APP.selected_info:add(MOUSE.selected.id, tik.txt, tiv.txt)
            Tools.new_info(Tools.scene, "object", tik.txt, tiv.txt)
        end
        -- print(tik.txt, tiv.txt)
        -- APP.selected_info:set_key(MOUSE.selected.id,tik.old_txt, tik.txt, tiv.txt)
        -- Tools.new_info(Tools.scene, "object", tik.txt, tiv.txt)  ---@TODO create a function to save and load 
    end
    panel_input[Tools.current].props.visible = false
    text_inputs:clear( )
    MOUSE.set_mode"wait"
end

local input_box = function(scene , type)
    local e = Inky.defineElement(function(self)
        self.props.name = "???"
        self.props.type = type

        text_inputs[type].key = Text_input( "key", scene)
        text_inputs[type].key.props.txt = ""
        text_inputs[type].key.props.old_txt = ""
        text_inputs[type].value = Text_input( "value", scene)
        text_inputs[type].value.props.txt = ""

        local btn_ok = Button.button(scene, "ok", function() ok_pressed( ) end)
        local btn_cancel = Button.button(scene, "cancel", function()
            text_inputs:clear( )
            self.props.visible = false
            MOUSE.set_mode"wait"
        end)
        local btn_discard = Button.button(scene, "discard", function()
            print(type)
            if type == "texture" then
                APP.texture_info:remove(MOUSE.texture, text_inputs[type].key.props.txt)
                Tools.load_texture_info(scene, MOUSE.texture)
            else
                APP.selected_info:remove(MOUSE.selected.id, text_inputs[type].key.props.txt)
                Tools.load_object_info(Tools.scene, MOUSE.selected.id)
            end
            self.props.visible = false
            text_inputs:clear( )
            MOUSE.set_mode"wait"
        end)
        local btn_size = 16
        return function(_,x,y,w,h)
            lg.setColor(RES.palette.zeus)
            lg.rectangle("fill", x,y,w,h)
            lg.setColor(RES.palette.white)
            lg.printf(string.format("[ %s ]", self.props.name), x, y, w, "center")

            local yy = y+btn_size+4
            lg.printf("variable name:", x, yy, w, "left")
            yy = yy+btn_size+4
            --txt_input
            text_inputs[self.props.type].key:render(x,yy,w,btn_size)
            yy = yy+btn_size+4
            lg.printf("value:", x, yy, w, "left")
            yy = yy+btn_size+4
            --txt_input
            text_inputs[self.props.type].value:render(x,yy,w,btn_size)
            -- yy = y+btn_size
            btn_ok:render(x+4,y+h-btn_size-4,btn_size,btn_size)
            btn_discard:render(x+(w-btn_size)*0.5,y+h-btn_size-4,btn_size,btn_size)
            btn_cancel:render(x+w-btn_size-4,y+h-btn_size-4,btn_size,btn_size)
        end
    end)
    return e(scene)
end

local function info_input_box(scene, type)
    local e = Inky.defineElement(function(self)
        -- self.props.active = true
        -- print"rolou"
        -- text_inputs:setup( scene)
        text_inputs[type].key = Text_input( "key", scene)
        text_inputs[type].key.props.txt = ""
        text_inputs[type].key.props.old_txt = ""
        text_inputs[type].value = Text_input( "value", scene)
        text_inputs[type].value.props.txt = ""
        -- text_inputs[k].value.props.old_txt = ""
        local btn_ok = Button.button(scene, "ok", function() ok_pressed( ) end)
        local btn_cancel = Button.button(scene, "cancel", function()
            -- print"cancel"
            text_inputs:clear( )
            self.props.visible = false
            MOUSE.set_mode"wait"
        end)
        local btn_discard = Button.button(scene, "discard", function() --esse
            -- print"discard"
            APP.texture_info:remove(MOUSE.texture, text_inputs[type].key.props.txt)
            Tools.load_tool_info(scene, MOUSE.texture)
            self.props.visible = false
            text_inputs:clear( )
            MOUSE.set_mode"wait"
        end)
        local btn_size = 16
        return function(_,x,y,w,h)
            lg.setColor(RES.palette.zeus)
            lg.rectangle("fill", x,y,w,h)
            lg.setColor(RES.palette.white)
            lg.printf(string.format("[ %s ]",MOUSE.texture), x, y, w, "center")

            local yy = y+btn_size+4
            lg.printf("variable name:", x, yy, w, "left")
            yy = yy+btn_size+4
            --txt_input
            text_inputs[type].key:render(x,yy,w,btn_size)
            yy = yy+btn_size+4
            lg.printf("value:", x, yy, w, "left")
            yy = yy+btn_size+4
            --txt_input
            text_inputs[type].value:render(x,yy,w,btn_size)
            -- yy = y+btn_size
            btn_ok:render(x+4,y+h-btn_size-4,btn_size,btn_size)
            btn_discard:render(x+(w-btn_size)*0.5,y+h-btn_size-4,btn_size,btn_size)
            btn_cancel:render(x+w-btn_size-4,y+h-btn_size-4,btn_size,btn_size)
        end
    end)
    return e(scene)
end

text_inputs.clear = function(self )
    self[current_text_input].key.props.txt = ""
    self[current_text_input].key.props.old_txt = ""
    self[current_text_input].value.props.txt = ""
    text_field_active( "key")
end
text_inputs.set_up = function(scene, t)
    text_inputs[t].key = Text_input( "key", scene)
    text_inputs[t].key.props.txt = ""
    text_inputs[t].key.props.old_txt = ""
    text_inputs[t].value = Text_input( "value", scene)
    text_inputs[t].value.props.txt = ""
end

Tools.clear_info=function(type)
    for key in pairs(info_data[type]) do
        info_data[type][key] = nil
    end
    print(type)
    info_data[type] = {}
end

Tools.load_texture_info = function(scene, id) --esse
    Tools.clear_info("texture")
    local info = APP.texture_info:get(id)
    for k,v in pairs(info) do
        Tools.new_info(scene, "texture", k, v)
    end
end

Tools.load_object_info = function(scene, id) --esse
    Tools.clear_info("object")
    local info = APP.selected_info:get(id)
    for k,v in pairs(info) do
        Tools.new_info(scene, "object", k, v)
    end
end

---@param scene table Inky scene
---@param type string info type
---@param key string key|value
---@param value boolean|number|string info value
Tools.new_info = function( scene, type, key, value) --esse
    info_data[type][key] = Info_button(scene, key, tostring(value),
    function(self)
        panel_input[type].props.visible = true
        text_inputs[type].key.props.txt = key
        text_inputs[type].key.props.old_txt = key
        text_inputs[type].value.props.txt = tostring(value)
        MOUSE.set_mode"hud_dialog"
    end)
end

Tools.setToolActiveKey = function(key)
    APP.selected_tool = key
    for i=1,#Tools.buttons[1] do
        local you = Tools.buttons[1][i].props.key==key
        Tools.buttons[1][i].props.color = you and "on" or "off"
        Tools.buttons[1][i].props.activeKey = key
    end
end
Tools.setTextureButtons = function(scene, name)
    local index = #Tools.texture_buttons+1
    Tools.texture_buttons[index] = Button.texture(scene, name, function(n)
        for i=1,#Tools.texture_buttons do
            Tools.texture_buttons[i].props.selected = false
        end
        MOUSE:set_texture(n)
        return n==name
    end)
    local ipos = From_id(name)

    Tools.texture_buttons[index].props.x = ipos[1]*TILE_SIZE
    Tools.texture_buttons[index].props.y = ipos[2]*TILE_SIZE
end

Tools.textinput = function( t)
    if Tools.active_text.name then
        local txt = Tools.active_text.props.txt
        local len = utf8.len(txt)
        if len==9 then
            txt = string.sub(txt,1, len-1)
        end
        Tools.active_text.props.txt = txt .. t
    end
end
Tools.keypressed = function( key)
    if key == "backspace" then
        local txt = Tools.active_text.props.txt
        local len = utf8.len(txt)
        if len>0 then
            Tools.active_text.props.txt = string.sub(txt, 1, len - 1)
        end
    elseif key == "return" or key == "tab" then
        local name = text_field_get_active()
        if name=="key" and key=="return" then
            ok_pressed()
        else
            text_field_active( name)
            Tools.active_text = {name = name, props = text_inputs[current_text_input][name].props}
        end
    elseif key == "escape" then
        text_inputs:clear()
        panel_input[Tools.current].props.visible = false
        MOUSE.set_mode"wait"
    end
end


local minimize_button = require"core.ui.minimize_button"
----------------------------------------------------------------------------FILES PANEL
local files_panel = require"core.ui.files_panel"
----------------------------------------------------------------------------TOOLS PANEL
local tools_panel = require"core.ui.tools_panel"
----------------------------------------------------------------------------TEXTURE PANEL
local textures_panel = require"core.ui.textures_panel"
----------------------------------------------------------------------------INFO PANEL
local info_panel = Inky.defineElement(function(self, scene)
    local lhp4 = label_height+4
    local infos_label = Gradient_Label(scene, "TILE INFO")
    local add_info = Button.label(scene, "new", "center",function()
        Tools.current = "texture"
        current_text_input = "texture"
        text_field_active( "key")
        Tools.active_text = {name = "key", props = text_inputs.texture.key.props}
        panel_input.texture.props.visible = true
        MOUSE.set_mode"hud_dialog"
    end)
    self.props.height = lhp4
    self.props.max_height = label_height*2.5
    self.props.show = false
    local minimize_btn = minimize_button( scene, self.props, lhp4)
    local minimize_btn_size = 16
    return function(_,x,y,w,h)
        lg.setColor(RES.palette[ theme.tab.background])
        lg.rectangle("fill", x, y, w, self.props.height)
        infos_label:render(x, y, w, label_height)
        minimize_btn:render(x+w-button_size,y,minimize_btn_size,minimize_btn_size)
        if self.props.show then
            y = y+lhp4
            local count = 2.5
            for _,lb in pairs(info_data.texture) do
                lb:render(x, y, w-5, label_height)
                y = y+label_height+1
                count = count+1
            end
            self.props.height = count*label_height
            y = y+1
            --draw add_info button
            add_info:render(x, y, w, label_height)
        end
    end
end)
----------------------------------------------------------------------------OBJECT PANEL

local object_panel = Inky.defineElement(function(self, scene)
    local infos_label = Gradient_Label(scene, "OBJECT INFO")
    local lhp4 = label_height+4

    local add_info = Button.label(scene, "new", "center",function()
        local isObject = APP.objects:get(MOUSE.selected.id)
        if isObject then
            Tools.current = "object"
            current_text_input = "object"
            text_field_active( "key")
            Tools.active_text = {name = "key", props = text_inputs.object.key.props}
            panel_input.object.props.visible = true
            MOUSE.set_mode"hud_dialog"
        end
    end)

    self.props.height = lhp4
    self.props.max_height = label_height*2.5
    self.props.show = false
    local minimize_btn = minimize_button( scene, self.props, lhp4)
    local minimize_btn_size = 16
    return function(_,x,y,w,h)
        lg.setColor(RES.palette[ theme.tab.background])
        lg.rectangle("fill", x, y, w, self.props.height)
        infos_label:render(x, y, w, label_height)
        minimize_btn:render(x+w-button_size,y,minimize_btn_size,minimize_btn_size)
        if self.props.show then
            y = y+label_height+4
            local count = 2.5
            for _,lb in pairs(info_data.object) do
                lb:render(x, y, w-5, label_height)
                y = y+label_height+1
                count = count+1
            end
            self.props.height = count*label_height
            y = y+1
            --draw add_info button
            add_info:render(x, y, w, label_height)
        end
    end
end)
----------------------------------------------------------------------------DRAW EVERYTHING
Tools.element = Inky.defineElement(function(self, scene)
    panel_input.texture = input_box(scene, "texture")
    panel_input.texture:render(1,1,1,1)
    panel_input.object = input_box(scene, "object")
    panel_input.object:render(1,1,1,1)
    Tools.scene = scene

    local files = files_panel(Tools, button_size, label_height)
    local tool = tools_panel(Tools, button_size, label_height)
    local texture = textures_panel(Tools, button_size, label_height)
    local info = info_panel(scene)
    local object = object_panel(scene)

    local dialog_panel_height = 128
    return function(_,x,y,w,h)
        local sy = y

        --FILES-----------------------------------------------
        files:render(x, sy, w, h)
        sy = sy + files.props.height

        --TOOLS-----------------------------------------------
        tool:render(x, sy, w, h)
        sy = sy + tool.props.height

        --TEXTURES--------------------------------------------
        texture:render(x, sy, w, h)
        sy = sy + texture.props.height

        --INFO------------------------------------------------
        info:render(x, sy, w, h)
        sy = sy + info.props.height

        --OBJECT----------------------------------------------
        object:render(x, sy, w, h)
        sy = sy + object.props.height

        if panel_input.texture.props.visible then
            panel_input.texture:render(x+w+5, sy-dialog_panel_height, w, dialog_panel_height)
        end

        if panel_input.object.props.visible then
            panel_input.object:render(x+w+5, sy-dialog_panel_height, w, dialog_panel_height)
        end

        self.props.height = sy
    end
end)

return Tools