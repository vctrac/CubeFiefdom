local format = string.format
local abs = math.abs
local function save_obj(verts, name, flip)

    local txt = "mtllib "..name..".mtl"
    txt = txt .."\no "..name

    --remove duplicates
    local vertex = {}
    local texture = {}
    local normal = {}

    --store vertex, faces, texture and normal data
    local v, f = {}, {}
    local vn, vt = {}, {}

    for i,m in ipairs(verts) do
        -- to avoid -0 values
        local x = m[1]==0 and 0 or m[1]
        local y = m[2]==0 and 0 or m[2]
        local z = m[3]==0 and 0 or m[3]
        local id = format("%.6f,%.6f,%.6f",x,y,z)
        if not vertex[id] then
            v[#v+1] = {x,y,z}
            vertex[id] = #v
        end
        local fv = vertex[id]

        x = m[4]==0 and 0 or m[4]
        y = m[5]==0 and 0 or m[5]
        id = format("%.6f,%.6f", x, y)
        if not texture[id] then
            vt[#vt+1] = {x, flip and 1-y or y} -- use flip if exporting to blender and such
            texture[id]= #vt
        end
        local ft = texture[id]

        x = m[6]==0 and 0 or m[6]
        y = m[7]==0 and 0 or m[7]
        z = m[8]==0 and 0 or m[8]
        id = format("%.4f,%.4f,%.4f",x,y,z)
        if not normal[id] then
            vn[#vn+1] = {x,y,z}
            normal[id] = #vn
        end
        local fn = normal[id]

        f[i] = format("%d/%d/%d",fv,ft,fn)
    end

    for i=1,#v do
        txt = txt .. format("\nv %.6f %.6f %.6f", unpack(v[i]))
    end
    for i=1,#vn do
        txt = txt .. format("\nvn %.4f %.4f %.4f", unpack(vn[i]))
    end
    for i=1,#vt do
        txt = txt .. format("\nvt %.6f %.6f", unpack(vt[i]))
    end

    txt = txt .. "\ns 0"
    txt = txt .. "\nusemtl " .. name.. "Material.001"
    for i=1,#f,3 do
        txt = txt .."\nf " .. f[i].. " ".. f[i+1].. " ".. f[i+2]
    end

    local obj = io.open(name ..".obj", "w")
    -- assert(obj,"could not open " ..name..".obj file")
    if not obj then
        return false, "could not open " ..name..".obj file"
    end
    obj:write("#########################################\n")
    obj:write("# Wavefront .obj file\n")
    obj:write("# Created by: Cube Fiefdom (v "..CONFIG.version..")\n")
    obj:write("# Date: "..os.date().."\n")
    obj:write("#########################################\n\n")

    obj:write(txt)
    obj:close()

    txt = "#cubeFiefdom\nnewmtl " .. name.. "Material.001"
    txt = txt .. "\nNs 250.000000"
    txt = txt .. "\nKa 1.000000 1.000000 1.000000"
    txt = txt .. "\nKs 0.500000 0.000000 0.000000"
    txt = txt .. "\nKe 0.000000 0.000000 0.000000"
    txt = txt .. "\nNi 0.000000"
    txt = txt .. "\nd 1.000000"
    txt = txt .. "\nillum 1"
    txt = txt .. "\nmap_Kd atlas.png"

    local mtl = io.open(name ..".mtl", "w")
    -- assert(mtl,"could not open "..name ..".mtl file")
    if not mtl then
        return false, "could not open " ..name..".mtl file"
    end
    mtl:write(txt)
    mtl:close()
    return true
end

return {save = save_obj}