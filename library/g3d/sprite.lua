-- MIT license

---@module 'model'
local new_model = require(g3d.path .. ".model")

---@module 'camera'
local cam = require(g3d.path .. ".camera")

local verts = {
    { 0, -.5, .5, 1,0 },
    { 0, .5, .5, 0,0 },
    { 0, .5, -.5, 0,1 },
    { 0, -.5, -.5, 1,1 },
    { 0, -.5, .5, 1,0 },
    { 0, .5, -.5, 0,1 }
}

local pixel_shader = [[
vec4 effect(vec4 color, Image tex, vec2 texCoords, vec2 screenCoords) {
    vec4 pixel = Texel(tex, texCoords);
    
    if(pixel.a < 0.1) discard;
    return pixel*color;
}
]]

--Shader billboard - got some bugs with canvases
-- local horizontal_billboard_shader = love.graphics.newShader( pixel_shader, [[
--     uniform mat4 modelMatrix;
--     uniform mat4 viewMatrix;
--     uniform mat4 projectionMatrix;

--     vec4 position( mat4 transform_projection, vec4 vertex_position ) {

--         mat4 modelView = viewMatrix*modelMatrix;
--         float scale = length(modelMatrix[0]);

--         // horizontal.
--         modelView[1][0] = -scale; 
--         modelView[1][1] = 0.0; 
--         modelView[1][2] = 0.0;

--         vec4 P = modelView * vertex_position;
--         return projectionMatrix * P;
--     }
-- ]])
-- local full_billboard_shader = love.graphics.newShader(pixel_shader, [[
--     uniform mat4 modelMatrix;
--     uniform mat4 viewMatrix;
--     uniform mat4 projectionMatrix;

--     vec4 position( mat4 transform_projection, vec4 vertex_position ) {

--         mat4 modelView = viewMatrix*modelMatrix;
--         vec2 scale = vec2(length(modelMatrix[0]), length(modelMatrix[1]));

--         // horizontal.
--         modelView[1][0] = -scale.x; 
--         modelView[1][1] = 0.0; 
--         modelView[1][2] = 0.0;

--         if (vertical){
--             modelView[2][0] = 0.0; 
--             modelView[2][1] = scale.y; 
--             modelView[2][2] = 0.0;
--         }
--         vec4 P = modelView * vertex_position;
--         return projectionMatrix * P;
--     }
-- ]])

--Lua billboard - accepts different pixel shaders
--[
local billboard = function(self)
    local vx,vy,vz = cam.getLookVector()
    self.rotation[2] = math.tan( -vz )
    self.rotation[3] = math.atan2( vy, vx )
    self:updateMatrix()
    self.render(self)
end
local horizontal = function(self)
    local vx,vy,_ = cam.getLookVector()
    self.rotation[3] = math.atan2( vy, vx )
    self:updateMatrix()
    self.render(self)
end
-- ]]

---@class settings
---@field translation table { x, y, z}
---@field rotation table { x, y, z}
---@field scale number | table number or { x, y, z}
---@field vertical boolean true for full billboard or false for horizontal billboard

---@param texture userdata
---@param settings settings
---@return table sprite
local function newSprite(texture, settings)
    settings = settings or {}
    
    -- local scale --ivert z if texture is rendering upsidedown
    if type(settings.scale)=="table" then
        settings.scale[3] = 1
    --     scale = settings.scale
    --     scale[3] = -scale[3]
    -- else
    --     local s = settings.scale or 1
    --     scale = {s,s,-s}
    end

    local sprite = new_model(verts, texture, settings.translation, settings.rotation, settings.scale)
    
    -- billboard shader - defaults to horizontal billboard.
    sprite.shader = love.graphics.newShader( pixel_shader, g3d.shaderpath)--settings.shader or billboard_shader--settings.vertical and full_billboard_shader or horizontal_billboard_shader
    -- if settings.horizontal then
        -- sprite.shader:send("vertical", false)
    sprite.render = sprite.draw
    sprite.draw = settings.horizontal and horizontal or billboard
    -- end
    -- sprite.draw = settings.disable and render or (settings.vertical and billboard or horizontal)
    -- sprite.draw = render
    return sprite
end

return newSprite