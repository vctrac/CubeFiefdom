-- tab_tools.lua

local Inky = require"library.inky"
local Button = require"ui.button"
local Theme = require"ui.Theme"

local button_size = 22

local tool_buttons = {}
local texture_buttons = {}

local Tools = {
    start_x = 4,
    start_y = button_size,
    
    switch_tab = nil
}


local function Label(scene, name)
    local gradient = (loadfile("misc/gradient.lua")())("horizontal",{ 0.45,0.45,0.45,1},Theme.tab.active_color)
    local label = Inky.defineElement(function(self)
        return function(_,x,y,w,h)
            love.graphics.setColor(1,1,1)
            love.graphics.draw(gradient, x,y,0,w,h)
            love.graphics.print(name, x, y)
        end
    end)
    return label(scene)
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
    -- local itype, ipos = From_id(name)
    local index = #texture_buttons+1
    texture_buttons[index] = Button.texture(scene, name, function(n)
        for i=1,#texture_buttons do
            texture_buttons[i].props.selected = false
        end
        MOUSE:set_texture(n)
        return n==name
    end)
    -- print(name)
    local _, ipos = From_id(name)

    -- hud.textures[name] = button(hud.scene)
    texture_buttons[index].props.x = ipos[1]*TILE_SIZE
    texture_buttons[index].props.y = ipos[2]*TILE_SIZE
end

local function toggle(name)
    APP.toggle[name] = not APP.toggle[name]
    return APP.toggle[name]
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
    local label_height = 16
    local texture_atlas_size = 8*TILE_SIZE
    local current_texture_x = TILE_SIZE*2
    return function(_,x,y,w,h)
        local sx = x+Tools.start_x
        local sy = y+Tools.start_y
        for row=1,#tool_buttons do
            local yy = sy+button_size*(row-1)
            for column=1,#tool_buttons[row] do
                local xx = sx+button_size*(column-1)
                tool_buttons[row][column]:render(xx, yy, button_size, button_size)
            end
        end
        --draw tabs
        files_tab:render(x+w, y, 20, 60)
        love.graphics.setColor(1,1,1)
        love.graphics.draw(IMAGE.tools_on, x+w, y+64)
        --draw label
        sy = sy+button_size*(#tool_buttons+1)
        texture_label:render(x, sy, w, label_height)
        --draw textures
        sx = x+4
        sy = sy+label_height*2
        love.graphics.draw(APP.texture_atlas, sx, sy)
        for _,tex in ipairs(texture_buttons) do
            tex:render(sx+tex.props.x, sy+tex.props.y, TILE_SIZE, TILE_SIZE)
        end
        -- print(#texture_buttons/TILE_SIZE)
        sx = x+w*0.5 - current_texture_x
        sy = sy+texture_atlas_size+button_size
        love.graphics.draw(APP.texture[MOUSE.texture],sx,sy,0,4,4)

        sy = sy+texture_atlas_size
        info_label:render(x, sy, w, label_height)
    end
end)

return Tools