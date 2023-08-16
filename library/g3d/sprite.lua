-- MIT license

local model = require(g3d.path .. ".model")
local camera = require(g3d.path .. ".camera")
local verts = {
    { 0, -.5, .5, 1,0 },
    { 0, .5, .5, 0,0 },
    { 0, .5, -.5, 0,1 },
    { 0, -.5, -.5, 1,1 },
    { 0, -.5, .5, 1,0 },
    { 0, .5, -.5, 0,1 }
}

local alpha_shader = love.graphics.newShader(g3d.shaderpath, [[
    vec4 effect(vec4 color, Image tex, vec2 texCoords, vec2 screenCoords) {
        vec4 pixel = Texel(tex, texCoords);
        if(pixel.a < 0.1) discard;
        return pixel*color;
    }
]])

local render = function(self,shader)
    local shader = shader or alpha_shader
    love.graphics.setShader(shader)
    shader:send("modelMatrix", self.matrix)
    shader:send("viewMatrix", camera.viewMatrix)
    shader:send("projectionMatrix", camera.projectionMatrix)
    
    love.graphics.draw(self.mesh)
    love.graphics.setShader()
end
local billboard = function(self,shader)
    local vx,vy,vz = camera.getLookVector()
    self.rotation[2] = math.tan( -vz )
    self.rotation[3] = math.atan2( vy, vx )
    self:updateMatrix()
    render(self,shader)
end
local horizontal = function(self,shader)
    local vx,vy,vz = camera.getLookVector()
    self.rotation[3] = math.atan2( vy, vx )
    self:updateMatrix()
    render(self,shader)
end

--[[
    texture  = Image,
    settings = {
        table :translation {x,y,z},
        table :rotation {rx,ry,rz},
        number or table:scale (any),
        bool  :vertical
    } - (optional)
]]
local function newSprite(texture, settings)
    settings = settings or {}
    
    -- local scale --ivert z to fix texture rendering upsidedown
    -- if type(settings.scale)=="table" then
    --     scale = settings.scale
    --     scale[3] = -scale[3]
    -- else
    --     local s = settings.scale or 1
    --     scale = {s,s,-s}
    -- end

    local self = model(verts, texture, settings.translation, settings.rotation, settings.scale)

    self.draw = settings.disable and render or (settings.vertical and billboard or horizontal)
    return self 
end

return newSprite