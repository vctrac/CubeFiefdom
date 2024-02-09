
local string2bool = {["true"]=true, ["false"]=false}
local info = {}

local I = {}

I.load_data = function(data)
    for id in pairs(info) do
        info[id] = nil
    end
    for id, tab in pairs(data.info) do
        info[id] = tab
    end
    -- info = data.info
end
I.save_data = function()
    return info
end

---@param id string
---@param key string
---@param value any
I.add = function( id, key, value)
    if not info[id] then
        info[id] = {}
    end

    local v = value
    local isBool = string2bool[string.lower(value)]
    if tonumber(v) then
        v = tonumber(v)
    elseif isBool ~=nil then
        v = isBool
    end
    info[id][key] = v
end

---@param id string
---@param key string
I.remove = function( id, key)
    if not(info[id] and info[id][key]~=nil) then
        return false
    end
    info[id][key]=nil
    local count = 0
    for _ in pairs(info[id]) do
        count = count+1
    end
    if count==0 then
        info[id]=nil
    end
    return true
end

---@param id string
---@param old string
---@param new string
---@param value? any
I.set_key = function(self, id, old, new, value)
    local old_key = tostring(old)
    local new_key = tostring(new)
    local i,k,v
    if not info[id] or not info[id][old_key] then
        -- self.add(id, new_key, value or "...")
        i,k,v = id, new_key, value or "..."
    elseif info[id][new_key] then
        return
    else
        if new_key~="" then--if new_key key is empty than delete it
            -- self.add(id, new_key, value or info[id][old_key])
            i,k,v = id, new_key, value or info[id][old_key]
        end
        info[id][old_key] = nil
        
        --check if there's no info for this tile
        local c = 0
        for _ in pairs(info[id]) do
            c = c +1
        end
        if c==0 then info[id] = nil end
    end
    if type(i)=="string" and i~='' then
        self.add(i,k,v)
    end
end

--Returns a <b>table</b> with one or multiple pars of <i>[ keys ]</i> and <i>[ values ]</i>,</br>
-- or <b>empty table</b> if there is no info for this ID</br>
-- { [key1]=value, [key2]=value, ... }
---@param id string
---@return table info
I.get = function( id)
    if info[id] then
        return info[id]
    end
    return {}
end

---@param id string
---@param key string
---@return any value
I.get_key = function( id, key)
    if key~=nil and info[id] then
        if info[id][key] then
            return info[id][key]
        end
    end
    return false
end

return I