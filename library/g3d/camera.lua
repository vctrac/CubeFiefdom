-- written by groverbuger for g3d
-- september 2021
-- MIT license

local newMatrix = require(g3d.path .. ".matrices")
-- local g3d = g3d -- save a reference to g3d in case the user makes it non-global
local mat4 = Cpml.mat4
-- local quat = Cpml.quat
local vec3 = Cpml.vec3
----------------------------------------------------------------------------------------------------
-- define the camera singleton
----------------------------------------------------------------------------------------------------
local sensitivity = 1/300
local direction = 0
local pitch = 0
local default_speed = 4
local sprint_speed = 8
local rad90 = math.rad(90)
local key = love.keyboard.isDown

---@class camera
local camera = {
    fov = math.pi/2,
    nearClip = 0.01,
    farClip = 1000,
    aspectRatio = love.graphics.getWidth()/love.graphics.getHeight(),
    position = {0,0,0},
    target = {1,0,0},
    up = {0,0,1},
    viewMatrix = newMatrix(),
    projectionMatrix = newMatrix(),
}

-- read-only variables, can't be set by the end user
function camera.getDirectionPitch()
    return direction, pitch
end

function camera.resizeScreen(w,h)
    camera.aspectRatio = w / h
    camera.updateProjectionMatrix()
end

---@param theta? number in radians
---@param phi? number in radians
---@return table forward_vector
function camera.getForwardVector(theta, phi)
    theta = theta or direction
    phi = phi or pitch

    local d = theta-rad90
    local X = math.sin(-d) * math.cos(phi)
    local Y = math.cos(d) * math.cos(phi)
    local Z = math.sin(phi)

    -- Return the vector normalized
    local mag = math.sqrt(X*X + Y*Y + Z*Z)
    return {X/mag, Y/mag, Z/mag}
end
-- function camera.target_to_direction_and_pitch(x, y, z)
--     local target_x = camera.target[1] or x
--     local target_y = camera.target[2] or y
--     local target_z = camera.target[3] or z
--     local r = math.sqrt(target_x^2 + target_y^2 + target_z^2)
    
--     local phi = math.acos(target_z / r)-math.pi
--     local theta = math.atan2(target_y, target_x)

--     -- Ensure theta is in the range [0, 2*pi)
--     theta = (theta + 2*math.pi) % ( 2*math.pi)
--     -- camera.lookAt(xAt,yAt,zAt, x, y, z)
--     camera.lookInDirection(nil,nil,nil, theta,phi)
--     -- direction, pitch = theta, phi
-- end

-- convenient function to return the camera's normalized look vector
---@return number vx
---@return number vy
---@return number vz
function camera.getLookVector()
    local vx = camera.target[1] - camera.position[1]
    local vy = camera.target[2] - camera.position[2]
    local vz = camera.target[3] - camera.position[3]
    local length = math.sqrt(vx^2 + vy^2 + vz^2)

    -- make sure not to divide by 0
    if length > 0 then
        return vx/length, vy/length, vz/length
    end
    return vx,vy,vz
end


---@return vec3 world_coord
function camera.getMouseRay()
    --https://love2d.org/forums/viewtopic.php?p=240466#p240466

	-- viewport space
	local mouse_x, mouse_y = love.mouse.getPosition()
	local width  , height  = love.graphics.getDimensions()

	-- normalized device space
	local normalized_x = 2 * mouse_x / width  - 1
	local normalized_y = 2 * mouse_y / height - 1

	-- clip space
	local clip_coord = {normalized_x, -normalized_y, 1, 0}

	-- eye space
	local inverted_projection = mat4():invert(camera.projectionMatrix)
    local eye_coord = inverted_projection*clip_coord
	eye_coord[3] = -1
	eye_coord[4] = 0

	-- world space
    local viewMatrix = mat4(camera.viewMatrix)
    
    -- apply rotation
    viewMatrix:look_at(vec3(camera.position), vec3(camera.target), vec3(camera.up))

    local inverted_view = mat4():invert( viewMatrix)
    local world_coord = vec3(inverted_view*eye_coord)
    
	return world_coord:normalize()
end

-- pivot the camera around a point
---@param target_x number
---@param target_y number
---@param target_z number
---@param theta number in radians
---@param phi number in radians
---@param distance number
function camera.pivot(target_x,target_y,target_z, theta, phi, distance)

    -- turn the cos of the pitch into a sign value, either 1 or -1
    local cosPitch = math.cos(phi)
    local sign = (cosPitch > 0) and 1 or -1

    -- don't let cosPitch ever hit 0, because weird camera glitches will happen
    cosPitch = sign*math.max(math.abs(cosPitch), 0.00001)

    -- Calculate the new camera position after pivoting
    local new_x = target_x + distance * math.sin(theta) * cosPitch
    local new_y = target_y + distance * math.cos(theta) * cosPitch
    local new_z = target_z + distance * math.sin(phi)
    -- new camera position
    camera.position[1] = new_x
    camera.position[2] = new_y
    camera.position[3] = new_z
    -- new camera target
    camera.target[1] = target_x
    camera.target[2] = target_y
    camera.target[3] = target_z

    camera.updateViewMatrix()
end

function camera.lookAt(xAt,yAt,zAt, x, y, z)
    if x and y and z then
        camera.position[1] = x
        camera.position[2] = y
        camera.position[3] = z
    end
    camera.target[1] = xAt
    camera.target[2] = yAt
    camera.target[3] = zAt

    -- update the camera's direction and pitch based on lookAt
    local dx,dy,dz = camera.getLookVector()
    direction = math.pi/2 - math.atan2(dz, dx)
    pitch = math.atan2(dy, math.sqrt(dx^2 + dz^2))

    -- update the camera in the shader
    camera.updateViewMatrix()
end

-- move and rotate the camera, given a point and a direction and a pitch (vertical direction)
function camera.lookInDirection(x,y,z, directionTowards,pitchTowards)
    camera.position[1] = x or camera.position[1]
    camera.position[2] = y or camera.position[2]
    camera.position[3] = z or camera.position[3]

    direction = directionTowards or direction
    pitch = pitchTowards or pitch

    -- turn the cos of the pitch into a sign value, either 1 or -1
    local cosPitch = math.cos(pitch)
    local sign = (cosPitch > 0) and 1 or -1

    -- don't let cosPitch ever hit 0, because weird camera glitches will happen
    cosPitch = sign*math.max(math.abs(cosPitch), 0.00001)
    
    -- convert the direction and pitch into a target point
    camera.target[1] = camera.position[1]+math.cos(direction)*cosPitch
    camera.target[2] = camera.position[2]+math.sin(direction)*cosPitch
    camera.target[3] = camera.position[3]+math.sin(pitch)

    -- update the camera in the shader
    camera.updateViewMatrix()
end

-- recreate the camera's view matrix from its current values
function camera.updateViewMatrix()
    camera.viewMatrix:setViewMatrix(camera.position, camera.target, camera.up)
end

-- recreate the camera's projection matrix from its current values
function camera.updateProjectionMatrix()
    camera.projectionMatrix:setProjectionMatrix(camera.fov, camera.nearClip, camera.farClip, camera.aspectRatio)
end

-- recreate the camera's orthographic projection matrix from its current values
function camera.updateOrthographicMatrix(size)
    camera.projectionMatrix:setOrthographicMatrix(camera.fov, size or 5, camera.nearClip, camera.farClip, camera.aspectRatio)
end

-- first person camera movement with WASD
function camera.movement(dt)
    local cameraMoved = false
    local speed = key"lshift" and sprint_speed or default_speed

    local movefb = (key"w" and 1 or 0) + (key"s" and -1 or 0)
    if movefb~=0 then
        local forward = camera.getForwardVector()
        for i=1,3 do
            camera.position[i] = camera.position[i] +movefb*forward[i]*speed*dt
        end
        cameraMoved = true
    end

    local movelr = (key"a" and 1 or 0) + (key"d" and -1 or 0)
    if movelr~=0 then
        local forward = camera.getForwardVector(direction+rad90*movelr, 0)
        camera.position[1] = camera.position[1] +forward[1]*speed*dt
        camera.position[2] = camera.position[2] +forward[2]*speed*dt
        cameraMoved = true
    end

    local moveud = (key"space" and 1 or 0) + (key"c" and -1 or 0)
    if moveud~=0 then
        camera.position[3] = camera.position[3] + moveud*speed*dt
        cameraMoved = true
    end

    if cameraMoved then
        camera.lookInDirection()
    end
end

-- simple first person camera movement with WASD
-- put this local function in your love.update to use, passing in dt
function camera.firstPersonMovement(dt)
    -- collect inputs
    local moveX, moveY = 0, 0
    local cameraMoved = false
    local speed = love.keyboard.isDown"lshift" and sprint_speed or default_speed
    -- if love.keyboard.isDown "c" then
    if love.keyboard.isDown "w" then moveX = moveX + 1 end
    if love.keyboard.isDown "a" then moveY = moveY + 1 end
    if love.keyboard.isDown "s" then moveX = moveX - 1 end
    if love.keyboard.isDown "d" then moveY = moveY - 1 end
    if love.keyboard.isDown "space" then
        camera.position[3] = camera.position[3] + speed*dt
        cameraMoved = true
    end
    if love.keyboard.isDown "c" then
        camera.position[3] = camera.position[3] -  speed*dt
        cameraMoved = true
    end
    
    -- do some trigonometry on the inputs to make movement relative to camera's direction
    -- also to make the player not move faster in diagonal directions
    if moveX ~= 0 or moveY ~= 0 then
        -- if love.keyboard.isDown"lshift" then
            
        local angle = math.atan2(moveY, moveX)
        camera.position[1] = camera.position[1] + math.cos(direction + angle) * speed * dt
        camera.position[2] = camera.position[2] + math.sin(direction + angle) * speed * dt
        
        --flying camera
        if moveX~=0 then
            camera.position[3] = camera.position[3] + math.atan(pitch)*moveX * speed * dt
        end

        cameraMoved = true
    end

    -- update the camera's in the shader
    -- only if the camera moved, for a slight performance benefit
    if cameraMoved then
        camera.lookInDirection()
    end
end

-- use this in your love.mousemoved function, passing in the movements
function camera.firstPersonLook(dx,dy)
    -- capture the mouse
    -- love.mouse.setRelativeMode(true)

    
    direction = direction - dx*sensitivity
    pitch = math.max(math.min(pitch - dy*sensitivity, math.pi*0.5), math.pi*-0.5)

    camera.lookInDirection(camera.position[1],camera.position[2],camera.position[3], direction,pitch)
end

return camera
