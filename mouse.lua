local lg = love.graphics
local camera = g3d.camera
local new_cube, new_object, current_cube --, new_text

-- Pick the side of a cube where the mouse is pointing
---@param pos vec3
---@param npos vec3
---@return vec3 npos
local function get_side(pos, npos)
    local dif = (pos-npos)*2
    --converted to string to avoid float point precision problems
    local st = (dif:abs()):to_string_table()

    local result = vec3(0,0,0)
    if st.x=='1' then
        result.x = math.sign(dif.x)
    elseif st.y=='1' then
        result.y = math.sign(dif.y)
    elseif st.z=='1' then
        result.z = math.sign(dif.z)
    else
        print("some shit happened!")
    end
    if not(result==vec3.zero) then
        return npos+result
    end
    return npos
end

MOUSE = {
    old_x = 0,
    old_y = 0,
    move_x = 0,
    move_y = 0,
    mode = "wait",
    tool = "pencil",
    texture = "0:0",
    multi = {},
    selected = {
        pos = vec3(),
        new = vec3(),
        id = "",
    }
}

function MOUSE.load()
    current_cube = g3d.newModel(RES.model.wired_cube)
    new_cube = g3d.newModel(RES.model.cube, nil)
    new_object = g3d.newSprite(RES.image"object",{scale = 0.5})
    MOUSE:set_texture("0:0")
end

MOUSE.set_mode = function(mode)
    MOUSE.mode = mode
end

MOUSE.get_cube_under = function( )
    local cp = vec3(unpack(camera.position))
    local ray = camera.getMouseRay()
    local obj = false
    local nearest, position, distance = APP.cubes:cast_ray(cp.x, cp.y, cp.z, ray.x, ray.y, ray.z)
    local nearest2, position2, distance2 = APP.objects:cast_ray(cp.x, cp.y, cp.z, ray.x, ray.y, ray.z, distance)
    -- print(distance, distance2)
    if nearest2 and distance2<distance then
        nearest = nearest2
        position = position2
        obj = true
    end
    if nearest then
        local hit_position = vec3(position)
        
        MOUSE.set_mode("edit")
        local nearest_position = vec3((obj and APP.objects.list[nearest] or APP.cubes.list[nearest]).position)
        local result_position = get_side(hit_position, nearest_position)
        MOUSE.selected = { new = result_position, id = nearest}
        
        local rx,ry,rz = result_position:unpack()
        if APP.selected_tool=="pencil" then
            new_cube:setTranslation(rx,ry,rz)
        elseif APP.selected_tool=="object" then
            new_object:setTranslation(rx,ry,rz)
        end
        rx,ry,rz = nearest_position:unpack()
        current_cube:setTranslation(rx,ry,rz)
    else
        MOUSE.set_mode"wait"
    end
end
MOUSE.set_texture = function(self, texture_index)
    self.texture = texture_index
    new_cube.mesh:setTexture(APP["texture"][texture_index])

    HUD.load_tool_info(texture_index)
end
function MOUSE.draw()
    if MOUSE.mode=="edit" then
        lg.setColor(0,0,0)
        lg.setWireframe(true)
        current_cube:draw( )
        lg.setWireframe(false)
        if APP.selected_tool=="pencil" then
            lg.setColor(1,1,1,0.6)
            lg.setMeshCullMode( "back" )
            new_cube:draw( )
            lg.setMeshCullMode("none")
        elseif APP.selected_tool=="object" then
            lg.setColor(1,1,1,0.6)
            new_object:draw( )
        end
    end
end

local mouse_tools = {
    release = {
        pencil = function(mx,my,mb)
            if MOUSE.mode == "edit" then
                if mb==1 then
                    APP.cubes:add_cube( MOUSE.texture, MOUSE.selected.new:unpack())
                elseif mb==2 then
                    if APP.cubes:remove_cube(MOUSE.selected.id) then
                        MOUSE.set_mode"wait"
                    end
                end
            end
        end,
        brush = function(mx,my,mb)
            if MOUSE.mode~="edit" then return end
            
            if mb==1 then
                APP.cubes:paint_cube(MOUSE.selected.id, MOUSE.texture)
            elseif mb==2 then
                local cube = APP.cubes:get_cube( MOUSE.selected.id)
                if not cube then return end
                MOUSE:set_texture(cube.texture)
            end
        end,
        select = function(mx,my,mb)
            if MOUSE.mode~="edit" then return end
            
            if mb==1 then
                -- APP.cubes:paint_cube(MOUSE.selected.id, MOUSE.texture)
                local isObject = APP.objects:get(MOUSE.selected.id)
                print("selected", (isObject and "object : " or "cube : ") ..MOUSE.selected.id)
            -- elseif mb==2 then
                -- local cube = APP.cubes:get_cube( MOUSE.selected.id)
                -- if not cube then return end
                -- MOUSE:set_texture(cube.texture)
            end
        end,
        object = function(mx,my,mb)
            if MOUSE.mode~="edit" then return end
            
            if mb==1 then
                APP.objects:add(MOUSE.selected.new:unpack())
                -- print("object added at", MOUSE.selected.new:unpack())
            elseif mb==2 then
                APP.objects:remove(MOUSE.selected.id)
                -- print("object removed at", MOUSE.selected.new:unpack())
                -- local cube = APP.cubes:get_cube( MOUSE.selected.id)
                -- if not cube then return end
                -- MOUSE:set_texture(cube.texture)
            end
        end,
    },
    press = {
        pencil = function(mx,my,mb)

        end,
        brush = function(mx,my,mb)

        end,
        select = function(mx,my,mb)

        end,
        object = function(mx,my,mb)

        end,
    },
}

function MOUSE.pressed(x,y,b)
    mouse_tools.press[APP.selected_tool](x,y,b)
end
function MOUSE.released(x,y,b)
    mouse_tools.release[APP.selected_tool](x,y,b)
    MOUSE.get_cube_under()
end
