
local function save_obj(data, name)

    local txt = "#cubeFiefdom"
    txt = txt .."\nmtllib "..name..".mtl"
    txt = txt .."\no "..name
    
    local v, f = {}, {}
    local vn, vt = {}, {}
    for i,m in ipairs(data.model.verts) do
        if i%3==1 then
            vn[#vn+1] = {m[6], m[7], m[8]}
        end
        v[i] = {m[1], m[2], m[3]}
        vt[i]= {m[4], 1-m[5]}

        f[i] = string.format("%d/%d/%d",i,i,#vn)
    end

    for i=1,#v do
        txt = txt .. string.format("\nv %.6f %.6f %.6f", unpack(v[i]))
    end
    for i=1,#vn do
        txt = txt .. string.format("\nvn %.4f %.4f %.4f", unpack(vn[i]))
    end
    for i=1,#vt do
        txt = txt .. string.format("\nvt %.6f %.6f", unpack(vt[i]))
    end

    txt = txt .. "\ns 0"
    txt = txt .. "\nusemtl Material.001"
    for i=1,#f,3 do
        txt = txt .."\nf " .. f[i].. " ".. f[i+1].. " ".. f[i+2]
    end
    
    local obj = io.open(name ..".obj", "w")
    assert(obj,"could not open file")
    obj:write(txt)
    obj:close()

    txt = "#cubeFiefdom\nnewmtl Material.001"
    txt = txt .. "Ns 250.000000"
    txt = txt .. "Ka 1.000000 1.000000 1.000000"
    txt = txt .. "Ks 0.500000 0.500000 0.500000"
    txt = txt .. "Ke 0.000000 0.000000 0.000000"
    txt = txt .. "Ni 1.450000"
    txt = txt .. "d 1.000000"
    txt = txt .. "illum 2"
    txt = txt .. "map_Kd "..name..".png"

    local mtl = io.open(name ..".mtl", "w")
    assert(mtl,"could not open file")
    mtl:write(txt)
    mtl:close()


end

return {save = save_obj}