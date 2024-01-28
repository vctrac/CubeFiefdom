-- tab_tools.lua
local utf8 = require("utf8")
local Inky = require"library.Inky"
local Button = require"core.ui.button"
local theme = require"core.ui.theme"
local Info_button = require"core.ui.info_label_button"
local Gradient_Label = require"core.ui.gradient_label"
local button_size = 22
local label_height = 16
local text_inputs = { info = {}}
-- local Tools.buttons = {}
-- local texture_buttons = {}
local lg = love.graphics
local blinking_cursor_timer = 0

local Tools = {
    start_x = 4,
    start_y = button_size,
    -- integer indexed table
    buttons = {},
    texture_buttons = {},
    info = {},
    info_count = 0,
    active_info_text = {},
    switch_tab = nil,
}



local function text_field_active( i)
    for index,field in pairs(text_inputs.info) do
        field.props.active = index==i
    end
end
local function text_field_get_active( )
    return Tools.active_info_text.name=="key" and "value" or "key"
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
local function ok_pressed()
    -- print"ok"
    local tik = text_inputs.info.key.props
    local tiv = text_inputs.info.value.props

    -- remove whitespace characters
    tik.old_txt = string.gsub(tik.old_txt, "%s", "")
    tik.txt = string.gsub(tik.txt, "%s", "")
    tiv.txt = string.gsub(tiv.txt, "%s", "")

    if #tik.txt==0 then return end
    if #tiv.txt==0 then tiv.txt = "false" end
    if tik.txt ~= tik.old_txt then
        APP.info:set_key(MOUSE.texture,tik.old_txt, tik.txt, tiv.txt)
        Tools.load_tool_info(Tools.scene, MOUSE.texture)
    else
        APP.info.add(MOUSE.texture, tik.txt, tiv.txt)
        Tools.new_info(Tools.scene, tik.txt, tiv.txt)
    end
    Tools.info_panel_dialog.props.visible = false
    text_inputs:clear()
    MOUSE.set_mode"wait"
end
local function info_input_box(scene)
    local e = Inky.defineElement(function(self)
        -- self.props.active = true
        -- print"rolou"
        text_inputs.info.key = Text_input("key", scene)
        text_inputs.info.key.props.txt = ""
        text_inputs.info.key.props.old_txt = ""
        text_inputs.info.value = Text_input("value", scene)
        text_inputs.info.value.props.txt = ""
        -- text_inputs.info.value.props.old_txt = ""
        local btn_ok = Button.button(scene, "ok", ok_pressed)
        local btn_cancel = Button.button(scene, "cancel", function()
            -- print"cancel"
            text_inputs:clear()
            self.props.visible = false
            MOUSE.set_mode"wait"
        end)
        local btn_discard = Button.button(scene, "discard", function()
            -- print"discard"
            APP.info.remove(MOUSE.texture, text_inputs.info.key.props.txt)
            Tools.load_tool_info(scene, MOUSE.texture)
            self.props.visible = false
            text_inputs:clear()
            MOUSE.set_mode"wait"
        end)
        local btn_size = 16
        return function(_,x,y,w,h)
            lg.setColor(0.2,0.2,0.2)
            lg.rectangle("fill", x,y,w,h)
            lg.setColor(1,1,1)
            lg.printf(string.format("[ %s ]",MOUSE.texture), x, y, w, "center")

            local yy = y+btn_size+4
            lg.printf("variable name:", x, yy, w, "left")
            yy = yy+btn_size+4
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
    local info = APP.info.get(id)
    for k,v in pairs(info) do
        Tools.new_info(scene, k, v)
    end
end

---@param scene table Inky scene
---@param key string key|value
---@param value boolean|number|string info value
Tools.new_info = function( scene, key, value)
    Tools.info[key] = Info_button(scene, key, tostring(value),
    function(self)
        Tools.info_panel_dialog.props.visible = true
        text_inputs.info.key.props.txt = key
        text_inputs.info.key.props.old_txt = key
        text_inputs.info.value.props.txt = tostring(value)
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
    if Tools.active_info_text.name then
        local txt = Tools.active_info_text.props.txt
        local len = utf8.len(txt)
        if len==9 then
            txt = string.sub(txt,1, len-1)
        end
        Tools.active_info_text.props.txt = txt .. t
    end
end
Tools.keypressed = function( key)
    if key == "backspace" then
        local txt = Tools.active_info_text.props.txt
        local len = utf8.len(txt)
        if len>0 then
            Tools.active_info_text.props.txt = string.sub(txt, 1, len - 1)
        end
    elseif key == "return" or key == "tab" then
        local name = text_field_get_active()
        if name=="key" and key=="return" then
            ok_pressed()
        else
            text_field_active(name)
            Tools.active_info_text = {name = name, props = text_inputs.info[name].props}
        end
    elseif key == "escape" then
        text_inputs:clear()
        Tools.info_panel_dialog.props.visible = false
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
    local infos_label = Gradient_Label(scene, "TILE INFO")
    local add_info = Button.label(scene, "new", "center",function()
        text_field_active( "key")
        Tools.active_info_text = {name = "key", props = text_inputs.info.key.props}
        Tools.info_panel_dialog.props.visible = true
        MOUSE.set_mode"hud_dialog"
    end)
    self.props.height = label_height*2.5
    self.props.max_height = label_height*2.5
    self.props.show = true
    local minimize_btn = minimize_button( scene, self.props, label_height+4)
    local minimize_btn_size = 16
    return function(_,x,y,w,h)
        lg.setColor(theme.tab.active_color)
        lg.rectangle("fill", x, y, w, self.props.height)
        infos_label:render(x, y, w, label_height)
        minimize_btn:render(x+w-button_size,y,minimize_btn_size,minimize_btn_size)
        if self.props.show then
            y = y+label_height+4
            local count = 2.5
            for _,lb in pairs(Tools.info) do
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
    
    self.props.height = label_height*2.5
    self.props.max_height = label_height*2.5
    self.props.show = true
    local minimize_btn = minimize_button( scene, self.props, label_height+4)
    local minimize_btn_size = 16
    return function(_,x,y,w,h)
        lg.setColor(theme.tab.active_color)
        lg.rectangle("fill", x, y, w, self.props.height)
        infos_label:render(x, y, w, label_height)
        minimize_btn:render(x+w-button_size,y,minimize_btn_size,minimize_btn_size)
        -- if self.props.show then
            -- y = y+label_height+4
            -- local count = 2.5
            -- for _,lb in pairs(Tools.info) do
            --     lb:render(x, y, w-5, label_height)
            --     y = y+label_height+1
            --     count = count+1
            -- end
            -- self.props.height = count*label_height
        -- end
    end
end)
----------------------------------------------------------------------------DRAW EVERYTHING
Tools.element = Inky.defineElement(function(self, scene)
    Tools.info_panel_dialog = info_input_box(scene)
    Tools.info_panel_dialog:render(1,1,1,1)
    Tools.scene = scene

    local files = files_panel(Tools, button_size, label_height)
    local tool = tools_panel(Tools, button_size, label_height)
    local texture = textures_panel(Tools, button_size, label_height)
    local info = info_panel(scene)
    local object = object_panel(scene)

    local info_panel_height = 128
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

        if Tools.info_panel_dialog.props.visible then
            Tools.info_panel_dialog:render(x+w+5, y+h-info_panel_height, w, info_panel_height)
        end

        self.props.height = sy
    end
end)

return Tools