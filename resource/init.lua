local lg = love.graphics
lg.setDefaultFilter("nearest", "nearest")
local img = "resource/image/"
local img_bttn = img.."buttons/"

local model = "resource/model/"
local shader = "resource/shader/"

RES = {
    palette = {
        black = {0,0,0},
        white = {1,1,1},
        zeus = {0.169, 0.157, 0.129},
        deep_coffee = {0.384, 0.298, 0.235},
        tumbleweed = {0.851, 0.675, 0.545},
        desert_sand = {0.890, 0.812, 0.706},
        dark_gray_blue = {0.141, 0.239, 0.361},
        jet_grey = {0.365, 0.447, 0.459},
        horizon = {0.353, 0.529, 0.627},
        stone = {0.694, 0.647, 0.553},
        dull_red = {0.690, 0.227, 0.282},
        raw_sienna = {0.831, 0.502, 0.302},
        sand = {0.878, 0.784, 0.447},
        mineral_green = {0.243, 0.412, 0.345},
        faded_blue = {0.396, 0.549, 0.733},
        light_grey_blue = {0.631, 0.729, 0.847},
    },
    image = {
        atlas = lg.newImage(img.."tex.png"),
        circle = lg.newImage(img.."circle.png"),
        object_card = lg.newImage(img.."object_card.png"),
        center = lg.newImage(img.."center.png"),
        -- new_text = lg.newImage(img.."new_text.png"),
        button_frame = lg.newImage(img_bttn.."button_frame.png"),

        --BUTTONS
        pencil = lg.newImage(img_bttn.."pencil.png"),
        brush = lg.newImage(img_bttn.."brush.png"),
        rotate = lg.newImage(img_bttn.."rotate.png"),
        no_texture = lg.newImage(img_bttn.."no_texture.png"),
        object = lg.newImage(img_bttn.."object.png"),
        select = lg.newImage(img_bttn.."select.png"),
        light_on = lg.newImage(img_bttn.."light.png"),
        light_off = lg.newImage(img_bttn.."light_off.png"),
        retro_on = lg.newImage(img_bttn.."shader.png"),
        retro_off = lg.newImage(img_bttn.."shader_off.png"),
        grid_on = lg.newImage(img_bttn.."grid.png"),
        grid_off = lg.newImage(img_bttn.."grid_off.png"),
        texture_on = lg.newImage(img_bttn.."texture.png"),
        texture_off = lg.newImage(img_bttn.."texture_off.png"),
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
local a = -0.505
local b = 0.505
RES.model.wired_cube = {
    {a,a,a}, {b,a,a}, {b,a,a},
    {a,a,a}, {a,a,b}, {a,a,b},
    {b,a,b}, {a,a,b}, {a,a,b},
    {b,a,b}, {b,a,a}, {b,a,a},

    {a,b,a}, {b,b,a}, {b,b,a},
    {a,b,a}, {a,b,b}, {a,b,b},
    {b,b,b}, {a,b,b}, {a,b,b},
    {b,b,b}, {b,b,a}, {b,b,a},

    {a,a,a}, {a,b,a}, {a,b,a},
    {b,a,a}, {b,b,a}, {b,b,a},
    {a,a,b}, {a,b,b}, {a,b,b},
    {b,a,b}, {b,b,b}, {b,b,b},
}

setmetatable(RES.image, {
    __call = function(self, i)
        return self[i] or self.no_texture
    end
})