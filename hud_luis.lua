local initLuis = require("library.luis.init")

-- Direct this to your widgets folder.
local luis = initLuis("library/luis/widgets")
local g = love.graphics
-- register flux in luis, some widgets need it for animations
luis.flux = require("luis.3rdparty.flux")
local hud = {
    current_texture = "0:0"
}

-- Create a Button widget
local ImageButton = {}
function ImageButton.new(draw_f, x,y,w,h, onClick)
    local self = {
        type = "ImageButton", position = {x=x, y=y},
        width = w, height = h,
        onClick = onClick, hovered = false, pressed = false
    }
    function self:update(mx, my)
        self.hovered = mx > self.position.x and mx < self.position.x + self.width and
                       my > self.position.y and my < self.position.y + self.height
    end
    function self:draw()
        g.setColor(self.pressed and {1,1,1} or {0,0,0})
        g.rectangle("line", self.position.x, self.position.y, self.width, self.height, 3)
        draw_f(self.position.x, self.position.y, self.width, self.height)
    end
    function self:click(_, _, button)
        if button == 1 and self.hovered then
            self.pressed = true
            if self.onClick then self.onClick() end
            return true
        end
        return false
    end
    function self:release(_, _, button)
        if button == 1 and self.pressed then
            self.pressed = false
            return true
        end
        return false
    end
    return self
end
ImageButton.luis = luis
luis.widgets["ImageButton"] = ImageButton
luis["newImageButton"] = ImageButton.new

local transparent_theme = {
    button = {
        color = {1,1,1, 0},
        hoverColor = {1,1,1, 0.1},
        pressedColor = {1,1,1, 0.5},
        cornerRadius = 0,
        elevation = 4,
        elevationHover = 8,
        elevationPressed = 12,
        transitionDuration = 0.25,
    },
    flexContainer = {
        backgroundColor = {0.2, 0.2, 0.2, 0},
        borderColor = {0.3, 0.3, 0.3, 1},
        borderWidth = 2,
        padding = 0,
        handleSize = 10,
        handleColor = {0.1, 0, 0.1, 1}
	}
}

local block_panel = {
    container = {},
    load = function(self)
        local scale = 0.5
        local selected = 1

        self.container = luis.newFixedContainer(1, 3, 16, 1, transparent_theme.flexContainer, "block_panel")

        for i=1,3 do
            local draw = function( x,y,w,h)
                if selected == i then
                    g.setColor(1,1,1)
                else
                    g.setColor(0.5,0.5,0.5)
                end
                g.draw(RES.image.tools[CUBE_TYPES[i]], x, y+i,0,scale,scale)
            end
            local b = luis.newImageButton( draw, 0,i, 32,32, function( )
                    selected = i
                    MOUSE.set_new_cube_type(CUBE_TYPES[i])
                end)
            self.container:addChild(b)
        end
        luis.createElement("main", "FixedContainer", self.container)
    end,
}

local texture_panel = {
    -- buttons = {},
    container = {},
    load = function(self)
        local scale = 2
        -- current

        self.container = luis.newFixedContainer(RES.atlas.rows, RES.atlas.colls, 16, 2, transparent_theme.flexContainer, "texture_panel")
        self.container:hide()
        self.container:setAutoHide(true)
        self.container:setBackgroundImage(RES.atlas.image, scale)

        local function draw_texture( x,y,w,h)
            g.setColor(1,1,1)
            g.draw(APP.texture[hud.current_texture], x,y, 0, scale, scale)
        end
        local iw,ih = APP.texture[hud.current_texture]:getDimensions()
        iw,ih = iw*scale,ih*scale
        local ib = luis.newImageButton(draw_texture, TILE_SIZE*2,hud.height-TILE_SIZE*3.5, iw,ih,  function( )
            self.container:toggleVisibility()
        end)

        for x=1,RES.atlas.rows do
            for y=1,RES.atlas.colls do
                local id = To_id({y-1,x-1})

                local function click( )
                    MOUSE.set_texture(id)
                    hud.current_texture = id
                end
                local b = luis.newButton("",1,1, click, nil, x, y, transparent_theme.button)
                -- table.insert(self.buttons, b)
                self.container:addChild(b)
            end
        end
        luis.createElement("main", "ImageButton",draw_texture, TILE_SIZE*4,hud.height-TILE_SIZE*3.5, iw,ih,  function( )
            self.container:toggleVisibility()
        end)
        luis.createElement("main", "TextInput", 10, 1, "add tag...", function(text) APP.texture_info:add(hud.current_texture, text) end, 4, (hud.height/TILE_SIZE)-1)

        luis.createElement("main", "ImageButton", ib)
        luis.createElement("main", "FixedContainer", self.container)
    end,
}
-- local add_tag = {
--     load = function(self)
--         self.tag_text = luis.newTextInput(4,1,"tags", nil, 0,0)

--         luis.createElement("main", "TextInput", self.tag_text)
--     end
-- }
local top_menu = {
    load = function(self)
        local choice = function(item, value)
            if value == 1 then
                APP.save_lua()
                print("lua file saved")
            elseif value == 2 then
                APP.save_obj()
                print("obj file saved")
            elseif value == 2 then
                APP.save_json()
                print("json file saved")
            end
        end
        self.file = luis.newDropDown({"lua", "obj", "json"}, 1, 3, 0.75, choice, 1, 1, 5, nil, "save")
        luis.createElement("main", "DropDown", self.file )
    end
}
function hud.load()
    hud.width, hud.height = g.getDimensions( )
    luis.baseWidth, luis.baseHeight = hud.width, hud.height
    
    luis.setGridSize(TILE_SIZE*2)
    
    luis.newLayer("main")
    luis.setCurrentLayer("main")
    
    texture_panel:load()
    -- add_tag:load()
    top_menu:load()
    block_panel:load()

end

local time = 0
function hud.update(dt)
	time = time + dt
	if time >= 1/60 then	
		luis.flux.update(time)
		time = 0
	end

    luis.update(dt)
end

function hud.draw()
    luis.draw()
end

function hud.mousemoved(x, y, dx, dy)
    luis.mousemoved(x, y, dx, dy)
    -- print"err"
end
function hud.mousepressed(x, y, button, istouch)
    luis.mousepressed(x, y, button, istouch)
end

function hud.mousereleased(x, y, button, istouch)
    luis.mousereleased(x, y, button, istouch)
end

function hud.keypressed(key)
    if key == "escape" then
        if luis.currentLayer == "main" then
            love.event.quit()
        end
    elseif key == "tab" then -- Debug View
        luis.showGrid = not luis.showGrid
        luis.showLayerNames = not luis.showLayerNames
        luis.showElementOutlines = not luis.showElementOutlines
    else
        luis.keypressed(key)
    end
end
function hud.textinput(text)
    luis.textinput(text)
end
return hud