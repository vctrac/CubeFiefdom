-- local nfs = require 'library.nativefs'
local fh = {}
fh.init = function()
    -- local files = nfs.getDirectoryItemsInfo("core/io")
    -- for i = 1, #files do
    --     if files[i].type == "file" then
    --         local fname = files[i].name:match("(.+)%..+$")
    --         fh[fname] = require("core.io." .. fname)
    --         print(fname)
    --     end
    -- end
    fh.lua = require"core.io.lua"
    fh.json = require"core.io.json"
    fh.obj = require"core.io.obj"
    fh.png = require"core.io.png"
end
fh.save = function(format, data, name, ...)
    assert(fh[format],"wrong format: "..format)
    return fh[format].save(data, name,...)
end
fh.load = function(format, name, ...)
    assert(fh[format],"wrong format: "..format)
    return fh[format].load(name, ...)
end

return fh