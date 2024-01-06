local lg = love.graphics
lg.setDefaultFilter("nearest", "nearest")
local img = "resource/image/"
local img_bttn = img.."buttons/"

local model = "resource/model/"
local shader = "resource/shader/"

DATA = {
    image = {
        atlas = lg.newImage(img.."tex.png"),
        circle = lg.newImage(img.."circle.png"),
        center = lg.newImage(img.."center.png"),
        -- new_text = lg.newImage(img.."new_text.png"),
        button_frame = lg.newImage(img_bttn.."button_frame.png"),
        new_info = lg.newImage(img_bttn.."new_info_on.png"),

        --FILES
        -- save_lua_off = lg.newImage(img_bttn.."save_lua.png"),
        save_lua = lg.newImage(img_bttn.."save_lua_on.png"),
        -- save_json_off = lg.newImage(img_bttn.."save_json.png"),
        save_json = lg.newImage(img_bttn.."save_json_on.png"),
        -- save_obj_off = lg.newImage(img_bttn.."save_obj.png"),
        save_obj = lg.newImage(img_bttn.."save_obj_on.png"),

        --BUTTONS
        pencil = lg.newImage(img_bttn.."pencil.png"),
        brush = lg.newImage(img_bttn.."brush.png"),
        rotate = lg.newImage(img_bttn.."rotate.png"),
        light_on = lg.newImage(img_bttn.."light.png"),
        light_off = lg.newImage(img_bttn.."light_off.png"),
        shader_on = lg.newImage(img_bttn.."rotate.png"),
        shader_off = lg.newImage(img_bttn.."rotate.png"),
        retro_on = lg.newImage(img_bttn.."rotate.png"),
        retro_off = lg.newImage(img_bttn.."rotate.png"),
        grid_on = lg.newImage(img_bttn.."grid.png"),
        texture_on = lg.newImage(img_bttn.."texture.png"),
        redo = lg.newImage(img_bttn.."redo.png"),
        undo = lg.newImage(img_bttn.."undo.png"),
        ok = lg.newImage(img_bttn.."ok.png"),
        cancel = lg.newImage(img_bttn.."cancel.png"),
        discard = lg.newImage(img_bttn.."discard.png"),
        
        --TABS
        tools = lg.newImage(img.."tabs/tools_on.png"),
        files = lg.newImage(img.."tabs/files_on.png"),

        --WORLD
        skysphere = lg.newImage(img.."skysphere.png"),
        camera = lg.newImage(img.."camera_lens.png"),
    },
    model = {
        cube = model.."cube.obj",
        sphere = model.."sphere.obj",
    },
    shader = {
        lighting = shader.."lighting.frag",
        dithering = shader.."dithering.frag",
        scanlines = shader.."scanlines.frag",
        sky = shader.."sky.frag",
        grid = shader.."grid.frag",
        gradient = shader.."gradient.frag",
        clouds = shader.."clouds.frag",
    }
}
DATA.image.grid_off = DATA.image.grid_on
DATA.image.texture_off = DATA.image.texture_on
DATA.image.undo_off = DATA.image.undo
DATA.image.redo_off = DATA.image.redo