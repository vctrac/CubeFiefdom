
local old_print = print
function print( ...)
    local info = debug.getinfo(2,"Sl")
    local filename  = info.source:match("(.+)%..+$",2) --removes file extension/ everything after the dot
    old_print(string.format("%s %d >",filename, info.currentline), ...)
end
--same as before, but formated
function printf( s, ...)
    local fs = string.format(s, ...)
    local info = debug.getinfo(2,"Sl")
    local filename  = info.source:match("(.+)%..+$",2)
    old_print(string.format("%s %d : %s",filename, info.currentline, fs))
end

--- Converts a table of Coordinates to string ID like "0:0:0"
---@function To_id
---@param coords table
---@return string id
function To_id( coords)
    for i=1,#coords do
        if coords[i] == 0 then coords[i] = 0 end
    end
    return table.concat(coords,':')
end

--- Converts a string ID to integer table like {0,0,0}
---@function From_id
---@param id string
---@return table coords
function From_id(id)
    local t = {}
    for num in string.gmatch(id, '([^:]+)') do
        table.insert(t,tonumber(num))
    end
    return t
end
function Id_type(id)
    return id:match("(.*) ")
end
function math.sign(n)
    return n > 0 and 1
       or  n < 0 and -1
       or  0
 end

 function math.round(x)
    return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
  end