local lg = love.graphics
local camera = g3d.camera
local new_cube, current_cube --, new_text

-- CPML 3D Vector
---@class vec3:Cpml
---@field x number
---@field y number
---@field z number
---@module 'vec3'
local vec3 = Cpml.vec3

-- create the mesh for the block cursor
do
    local a = -0.505
    local b = 0.505
    current_cube = g3d.newModel{
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
end

local function sign(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
end

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
        result.x = sign(dif.x)
    elseif st.y=='1' then
        result.y = sign(dif.y)
    elseif st.z=='1' then
        result.z = sign(dif.z)
    else
        print("some shit happened!")
    end
    if not(result==vec3.zero) then
        return npos+result
    end
    return npos
end

---@TODO: a way to edit multiple cubes at the same time
-- maybe holding [ctrl] and dragging and/or left_clicking the mouse
-- the cubes will be edited after releasing [ctrl]
-- have to consider how it will work with UNDO/REDO

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
    new_cube = g3d.newModel(DATA.model.cube, nil)
    MOUSE:set_texture("0:0")
end

MOUSE.set_mode = function(mode)
    MOUSE.mode = mode
end

MOUSE.get_cube_under = function( )
    local cp = vec3(unpack(camera.position))
    local ray = camera.get_mouse_ray()

    local nearest, position = APP.map:cast_ray(cp.x, cp.y, cp.z, ray.x, ray.y, ray.z)
    
    if nearest then
        local hit_position = vec3(position)
        
        MOUSE.set_mode("edit")
        local nearest_position = vec3(APP.map.cubes[nearest].position)
        local result_position = get_side(hit_position, nearest_position)
        MOUSE.selected = { new = result_position, id = nearest}
        
        local rx,ry,rz = result_position:unpack()
        -- local new_id = To_id({rx,ry,rz})
        -- if not MOUSE.multi[new_id] then
        --     MOUSE.multi[new_id] = {pos={rx,ry,rz},id=nearest}
        -- end
        -- new_text:setTranslation(rx,ry,rz)
        new_cube:setTranslation(rx,ry,rz)
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
        if MOUSE.tool=="pencil" then
            lg.setColor(1,1,1,0.6)
            lg.setMeshCullMode( "back" )
            -- for key, selected in pairs(MOUSE.multi) do
                -- new_cube:setTranslation(selected.pos[1],selected.pos[2],selected.pos[3])
                new_cube:draw( )
            -- end
            -- new_cube:draw( )
            lg.setMeshCullMode("none")
        end
    end
end

local mouse_tools = {
    release = {
        pencil = function(mx,my,mb)
            if MOUSE.mode == "edit" then
                if mb==1 then
                    -- print(MOUSE.texture_type)
                    -- for key, selected in pairs(MOUSE.multi) do
                    --     APP.map:add_cube( MOUSE.texture, selected.pos)
                    -- end
                    -- MOUSE.multi = {}
                    APP.map:add_cube( MOUSE.texture, {MOUSE.selected.new:unpack()})
                elseif mb==2 then
                    if APP.map:remove_cube(MOUSE.selected.id) then
                        MOUSE.mode = "wait"
                    end
                end
            end
        end,
        brush = function(mx,my,mb)
            if MOUSE.mode~="edit" then return end
            
            if mb==1 then
                APP.map:paint_cube(MOUSE.selected.id, {texture = MOUSE.texture})
            elseif mb==2 then
                local cube = APP.map:get_cube( MOUSE.selected.id)
                if not cube then return end
                MOUSE:set_texture(cube.texture)
            end
        end,
    },
    press = {
        pencil = function(mx,my,mb)

        end,
        brush = function(mx,my,mb)

        end,
    },
}

function MOUSE.pressed(x,y,b)
    mouse_tools.press[MOUSE.tool](x,y,b)
end
function MOUSE.released(x,y,b)
    mouse_tools.release[MOUSE.tool](x,y,b)
    MOUSE.get_cube_under()
end
