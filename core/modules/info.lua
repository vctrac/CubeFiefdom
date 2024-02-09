
local string2bool = {["true"]=true, ["false"]=false}
-- local class = require"library.
local function info()
    local I = {
        list = {}
    }

    I.load_data = function(self, data)
        for id in pairs(self.list) do
            self.list[id] = nil
        end
        for id, tab in pairs(data.info) do
            self.list[id] = tab
        end
        -- info = data.info
    end
    I.save_data = function(self)
        return self.list
    end

    ---@param id string
    ---@param key string
    ---@param value any
    I.add = function( self, id, key, value)
        if not self.list[id] then
            self.list[id] = {}
        end

        local v = value
        local isBool = string2bool[string.lower(value)]
        if tonumber(v) then
            v = tonumber(v)
        elseif isBool ~=nil then
            v = isBool
        end
        self.list[id][key] = v
    end

    ---@param id string
    ---@param key string
    I.remove = function( self, id, key)
        if not(self.list[id] and self.list[id][key]~=nil) then
            return false
        end
        self.list[id][key]=nil
        local count = 0
        for _ in pairs(self.list[id]) do
            count = count+1
        end
        if count==0 then
            self.list[id]=nil
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
        if not self.list[id] or not self.list[id][old_key] then
            -- self.add(id, new_key, value or "...")
            i,k,v = id, new_key, value or "..."
        elseif self.list[id][new_key] then
            return
        else
            if new_key~="" then--if new_key key is empty than delete it
                -- self.add(id, new_key, value or self.list[id][old_key])
                i,k,v = id, new_key, value or self.list[id][old_key]
            end
            self.list[id][old_key] = nil
            
            --check if list for this id is empty
            local c = 0
            for _ in pairs(self.list[id]) do
                c = c +1
            end
            if c==0 then self.list[id] = nil end
        end
        if type(i)=="string" and i~='' then
            self:add(i,k,v)
        end
    end

    --Returns a <b>table</b> with one or multiple pars of <i>[ keys ]</i> and <i>[ values ]</i>,</br>
    -- or <b>empty table</b> if there is no info for this ID</br>
    -- { [key1]=value, [key2]=value, ... }
    ---@param id string
    ---@return table info
    I.get = function( self, id)
        return self.list[id] or {}
    end

    ---@param id string
    ---@param key string
    ---@return any value
    I.get_key = function( self, id, key)
        if key~=nil and self.list[id] then
            if self.list[id][key] then
                return self.list[id][key]
            end
        end
        return false
    end

    return I
end
return info