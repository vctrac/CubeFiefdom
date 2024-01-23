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

        --BUTTONS
        pencil = lg.newImage(img_bttn.."pencil.png"),
        brush = lg.newImage(img_bttn.."brush.png"),
        rotate = lg.newImage(img_bttn.."rotate.png"),
        light_on = lg.newImage(img_bttn.."light.png"),
        light_off = lg.newImage(img_bttn.."light_off.png"),
        shader_on = lg.newImage(img_bttn.."shader.png"),
        shader_off = lg.newImage(img_bttn.."shader.png"),
        retro_on = lg.newImage(img_bttn.."shader.png"),
        retro_off = lg.newImage(img_bttn.."shader.png"),
        grid_on = lg.newImage(img_bttn.."grid.png"),
        texture_on = lg.newImage(img_bttn.."texture.png"),
        redo = lg.newImage(img_bttn.."redo.png"),
        undo = lg.newImage(img_bttn.."undo.png"),
        redo_on = lg.newImage(img_bttn.."redo_on.png"),
        undo_on = lg.newImage(img_bttn.."undo_on.png"),
        ok = lg.newImage(img_bttn.."ok.png"),
        cancel = lg.newImage(img_bttn.."cancel.png"),
        discard = lg.newImage(img_bttn.."discard.png"),
        minimize = lg.newImage(img_bttn.."minimize.png"),
        minimize_on = lg.newImage(img_bttn.."minimize_on.png"),

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