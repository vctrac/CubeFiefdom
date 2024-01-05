
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

function To_id( coords)
    return table.concat(coords,':')
end
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