
-- local function save_palette()
--     local save = io.open( "palette.txt", 'w')

-- end
local function save_cko( data, filename)
    local save = io.open(filename ..".cko", 'w')
    -- print(filename, type(save))
    local txt = "CubeKingdom\n"
    txt = txt ..(data.palette_count>0 and 1 or 0) ..' '..(data.texture_count>0 and 1 or 0)
    if data.palette_count>0 then
        txt = txt ..'\n' .. data.palette_count
        for i,k in pairs(data.palette_ids) do
            local x,z,y = unpack(data.cubes[i].translation)
            local r,g,b = From_id(data.cubes[i].texture_index)
            local hex = rgb2hex(r,g,b)
            -- print(hex)
            txt = txt .. '\n' .. table.concat({x+100,y+100,z+100,hex}, ' ')
        end
    end
    if data.texture_count>0 then
        txt = txt ..'\n' ..data.texture_file
        txt = txt ..'\n' .. data.texture_count ..'\n'
        for i,k in pairs(data.cubes) do
            if not data.palette_ids[i] then
                local x,z,y = unpack(k.translation)
                local r,c = From_id(k.texture_index)
                txt = txt .. table.concat({x+100,y+100,z+100,r,c}, ' ')
                txt = txt .. '\n'
            end
        end
    end
    save:write(txt)
    save:close()
end

local function splitCkoLine(line)
	local values = {}

	for value in line:gmatch("[^' ']+") do -- Note: We won't match empty values.
		if     tonumber(value)  then  table.insert(values, tonumber(value)) -- Number.
		else                          table.insert(values, value)           -- String.
		end
	end

	return values
end

local function parse_cko(filename)

    local cko = {}
	for l in io.lines(filename) do
		table.insert(cko, splitCkoLine(l))
	end

    local line = 2
    local t = {}

    t.palette = cko[line][1]==1
    t.texture = cko[line][2]==1
    t.cubes = {}

    line = line+1

    if t.palette then
        t.palette_count = cko[line][1]
        
        line = line+1

        for i=1,t.palette_count do
            local hex = cko[line][4]
            cko[line][4] = table.concat({hex2rgb(hex)},':')
            table.insert(t.cubes, {unpack(cko[line])})
            line = line+1
        end
    end

    if t.texture then
        t.texture_file = cko[line][1]

        line = line+1

        t.texture_count = cko[line][1]

        line = line+1

        for i=1,t.texture_count do
            table.insert(t.cubes, {unpack(cko[line])})
            line = line+1
        end
    end
    return t
end

return {load = parse_cko, save = save_cko}