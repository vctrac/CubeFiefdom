local nfs = require 'library.nativefs'

---@TODO function to load textures
local function load_atlas(filename)
    --body
end
local function save_atlas(image, filename)
    local data = image:newImageData()
    local file_data = data:encode("png")
    nfs.write(filename..".png", file_data:getString())
end
return {save=save_atlas, load=load_atlas}