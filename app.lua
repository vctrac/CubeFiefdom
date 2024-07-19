local lg = love.graphics
local file_handler = require"core.modules.file_handler"
local new_info = require"core.modules.info"
--convert a quad from an imageData to a drawable image
local function Image_from_quad(source, x,y,w,h)
    local nid = love.image.newImageData(w, h)
    nid:paste(source, 0, 0, x, y, w, h)

    return lg.newImage(nid)
end

local change_index = 0
local undo_list = {}
local redo_list = {}
local pixel_scale = 4
local types = {cube=1, object=1}

APP = {
    cubes = require"scene",
    objects = require"core.modules.object",
    -- object_info = require"core.modules.info",
    toggle = {light=true, grid=false, texture=true, retro=false},
    atlas = nil,
    texture = {},
    palette = {},
    colors = {},
    first_person_view = false,
    width = lg.getWidth(),
    height = lg.getHeight(),
    canvas = nil,
    canvas_small = nil,
    canvas_normal = nil,
    pixel_scale = 1,
    selected_tool = "pencil"
}
function APP.load()
    -- err()
    file_handler:init()

    APP.retro_shader = lg.newShader(RES.shader.scanlines) --scanlines, dithering
    APP.light_shader = lg.newShader(g3d.shaderpath, RES.shader.lighting)
    
    APP.load_texture("tex.png")
    
    APP.atlas = lg.newCanvas(128,128)
    APP.atlas:renderTo( function()
        lg.draw(APP.texture_atlas,0,0)
    end)

    APP.canvas_normal = lg.newCanvas(APP.width, APP.height)
    APP.canvas_small = lg.newCanvas(APP.width/pixel_scale, APP.height/pixel_scale)
    APP.canvas = APP.canvas_normal
    APP.texture_info = new_info()
    APP.selected_info = new_info()
    APP.cubes:new()
end

function APP.clear()
    change_index = 0
    APP.cubes:clear()
    APP.cubes:new()
end

function APP.load_texture(filename)
    APP.atlas_data = love.image.newImageData("resource/image/"..filename)
    APP.texture_atlas = lg.newImage(APP.atlas_data)
    local iw,ih = APP.texture_atlas:getDimensions()
    for x=0,math.floor(iw/TILE_SIZE)-1 do
        for y=0,math.floor(ih/TILE_SIZE)-1 do
            local id = To_id({x,y})
            APP.texture[id] = Image_from_quad( APP.atlas_data, x*TILE_SIZE,y*TILE_SIZE,TILE_SIZE,TILE_SIZE)
        end
    end
end

function APP.option_toggle(name)
    APP.toggle[name] = not APP.toggle[name]

    if name=="retro" then
        APP.pixel_scale = APP.toggle[name] and pixel_scale or 1
        APP.canvas = APP.toggle[name] and APP.canvas_small or APP.canvas_normal
    end

    return APP.toggle[name]
end

function APP.get(id)
    local index
    if type(id)=="string" then
        index = id
    elseif type(id)=="table" then
        index = To_id(id)
    else
        return false
    end

    return APP.objects.list[index] or APP.cubes.list[index]
end

--Returns either object, cube, empty or nil
---@param id string
---@return string type
function APP.get_type(id)
    if type(id)~="string" then return "false" end
    return (APP.objects.list[id] and "object") or (APP.cubes.list[id] and "cube") or "empty"
end

function APP.add_change(tab)--{type, cmd, position_index, texture}
    local string = table.concat(tab, ',')
    for i=1,#redo_list do
        redo_list[i] = nil
    end
    change_index = change_index+1
    undo_list[change_index] = string
end

function APP.redo()
    local string, ni
    for i=1,#redo_list do
        if redo_list[i].c_index == change_index+1 then
            string = redo_list[i].string
            ni = i
        end
    end
    if not string then return end

    change_index = change_index+1
    -- print(string)
    local op = {}
    local t = ""
    for str in string.gmatch(string, '([^,]+)') do
        if types[str] then
            t = str
        else
            table.insert(op,str)
        end
    end

    undo_list[change_index] = string
    table.remove(redo_list, ni)
    if t=="cube" then
        APP.cubes.redo(op)
    elseif t=="object" then
        APP.objects.redo(op)
    end
end

function APP.undo( )
    if not undo_list[change_index] then return end

    local op = {}
    local t = ""
    for str in string.gmatch(undo_list[change_index], '([^,]+)') do
        if types[str] then
            t = str
        else
            table.insert(op,str)
        end
    end

    -- print(undo_list[change_index])
    table.insert(redo_list, {c_index = change_index, string = table.remove(undo_list)})
    change_index = math.max(0, change_index-1)

    if t=="cube" then
        APP.cubes.undo(op)
    elseif t=="object" then
        APP.objects.undo(op)
    end
end

function APP.cube_map_history(name) --used for undo and redo features in hud.lua
    APP[name]()
end

function APP.save_lua()
    local data = {}
    data.cubes = APP.cubes.list
    data.cube_count = APP.cubes.count
    data.objects = APP.objects.list
    data.object_count = APP.objects.count

    file_handler.save("lua", data, APP.texture_info:save_data(), CONFIG.save_name)
end

function APP.save_json()
    local data = {}
    data.cubes = APP.cubes.list
    data.cube_count = APP.cubes.count
    data.objects = APP.objects.list
    data.object_count = APP.objects.count

    file_handler.save("json", data, APP.info:save_data(), CONFIG.save_name)
end

function APP.save_obj()

    file_handler.save("obj", APP.cubes.model.verts, CONFIG.save_name)
end

function APP.drop_file(filename, ext)
	if file_handler[ext] and ext~="obj" then
        local data = file_handler.load(ext, filename)
        APP.cubes:load_data(data)
        APP.objects:load_data(data)
        APP.texture_info:load_data(data)
        APP.selected_info:load_data(data)
        data = nil
    end
end
function APP.resize_screen(w, h)
    APP.width = w
    APP.height = h
    APP.canvas = nil
    APP.canvas_normal = lg.newCanvas(w, h)
    APP.canvas_small = lg.newCanvas(w/pixel_scale, h/pixel_scale)
    APP.canvas = APP.toggle.retro and APP.canvas_small or APP.canvas_normal
end