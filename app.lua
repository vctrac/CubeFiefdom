local lg = love.graphics
local file_handler = require"file_handler"
--convert a quad from an imageData to a drawable image
local function Image_from_quad(source, x,y,w,h)
    local nid = love.image.newImageData(w, h)
    nid:paste(source, 0, 0, x, y, w, h)

    return lg.newImage(nid)
end

local pixel_scale = 4
APP = {
    map = require"scene",
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
    
    APP.retro_shader = lg.newShader(DATA.shader.scanlines) --scanlines, dithering

    APP.load_texture("tex.png")
    
    APP.atlas = lg.newCanvas(128,128)
    APP.atlas:renderTo( function()
        lg.draw(APP.texture_atlas,0,0)
    end)

    APP.canvas_normal = lg.newCanvas(APP.width, APP.height)
    APP.canvas_small = lg.newCanvas(APP.width/pixel_scale, APP.height/pixel_scale)
    APP.canvas = APP.canvas_normal

    APP.map:new()
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

function APP.cube_map_history(name) --used for undo and redo features in hud.lua
    APP.map[name](APP.map)
end

function APP.save_lua()
    file_handler.save("lua", APP.map, CONFIG.save_name)
end

function APP.save_json()
    file_handler.save("json", APP.map, CONFIG.save_name)
end

function APP.save_obj()
    file_handler.save("obj", APP.map, CONFIG.save_name)
end

function APP.drop_file(filename, ext)
    print(filename, ext)
	if file_handler[ext] then
        print"exist"
        if ext=="obj" then return end
        APP.map:load_file(file_handler.load(ext, filename))
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