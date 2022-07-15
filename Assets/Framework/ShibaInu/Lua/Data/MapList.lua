--
-- Map & List 数据结构
-- * 可通过 索引 或 键 获取对应的值
-- * 可多个键对应一个值
-- 2017/12/15
-- Author LOLO
--

--[[
示例：

local data = {
    [1] = { ["id"] = 101, ["name"] = "周瑜", ["lv"] = 999 },
    [2] = { ["id"] = 202, ["name"] = "鲁肃", ["lv"] = 888 },
    [3] = { ["id"] = 303, ["name"] = "郭嘉", ["lv"] = 777 },
}

local ml = MapList.New(data, "id", "name")
--local ml = MapList.New(data, { [101] = 1, ["周瑜"] = 1, [202] = 2, ["LuSu"] = 2, [303] = 3, ["郭嘉"] = 3 })

print(ml:GetValueByKey(202).name)
print(ml:GetValueByKey("郭嘉").lv)
--print(ml:GetValueByKey("LuSu").name)

AddEventListener(ml, DataEvent.DATA_CHANGED, function(event)
    print(event.type, event.index, event.oldValue, event.newValue)
end)
ml.dispatchChanged = true

ml:Add({ ["id"] = 404, ["name"] = "呵呵", ["lv"] = 666 })
print(ml:GetValueByIndex(4).name)

]]--

local type = type
local pairs = pairs
local remove = table.remove

---@class MapList : EventDispatcher
---@field New fun(values, ...):MapList
---
---@field dispatchChanged boolean @ 在数据有改变时，是否需要抛出 DataEvent.DATA_CHANGED 事件（默认不抛）
---
---@field _values table<number, any> @ 值列表
---@field _keys table<any, number> @ 与值列表对应的键列表
local MapList = class("MapList", EventDispatcher)

--- 构造函数
---@see MapList#Init
function MapList:Ctor(values, ...)
    MapList.super.Ctor(self)

    self.dispatchChanged = false
    self:Init(values, ...)
end

--- 初始化数据
---@param values table<number, any> @ -可选- 初始的值数组，传入 nil 表示使用 self._values
---@param ... table<any, number> | table<number, string> @ -可选- 如果只有一个值，并且为 table 对象时，将会设置为 _keys。 如果值为字符串数组时，将会做为 key 属性名称列表，在 values 中获取对应的 key
function MapList:Init(values, ...)
    if values == nil then
        -- 没传 values
        if self._values == nil then
            self._values = {}
            self._keys = {}
            self:DispatchDataEvent(1)
            return
        else
            values = self._values
        end
    else
        self._values = values
    end

    local keys = { ... }
    local keyLen = #keys
    -- 没传 keys
    if keyLen == 0 then
        self._keys = {}
        self:DispatchDataEvent(1)
        return
    end

    if keyLen == 1 and type(keys[1]) == "table" then
        self._keys = keys[1] -- keys 不用解析
    else
        -- 获取 keys 对应的字段
        self._keys = {}
        for i = 1, #values do
            local val = values[i]
            -- 值必须是 table 才能获取属性字段
            if type(val) == "table" then
                for n = 1, keyLen do
                    local key = val[keys[n]]
                    -- 值中没有对应的属性字段，忽略
                    if key ~= nil then
                        self._keys[key] = i
                    end
                end
            end
        end
    end

    self:DispatchDataEvent(1)
end



--=------------------------------[ get ]------------------------------=--

--- 通过键获取值
---@param key any
---@return any
function MapList:GetValueByKey(key)
    local index = self._keys[key]
    if index == nil then
        return nil
    end
    return self:GetValueByIndex(index)
end

--- 通过索引获取值
---@param index number
---@return any
function MapList:GetValueByIndex(index)
    return self._values[index]
end

--- 通过键获取索引。没有对应的值时，返回 -1
---@param key any
---@return number
function MapList:GetIndexByKey(key)
    return self._keys[key] or -1
end

--- 通过值获取索引。没有对应的值时，返回 -1
---@param value any
---@return number
function MapList:GetIndexByValue(value)
    local values = self._values
    for i = 1, #values do
        if values[i] == value then
            return i
        end
    end
    return -1
end

--- 通过索引获取键列表
---@param index number
---@return table<number, any>
function MapList:GetKeysByIndex(index)
    local keys = {};
    local list = self._keys;
    for k, v in pairs(list) do
        if v == index then
            keys[#keys + 1] = k
        end
    end
    return keys
end



--=------------------------------[ set ]------------------------------=--

--- 通过索引设置值
---@param index number
---@param value any
function MapList:SetValueByIndex(index, value)
    local oldValue = self._values[index]
    self._values[index] = value
    self:DispatchDataEvent(4, index, oldValue, value)
end

--- 通过键设置值
---@param key any
---@param value any
function MapList:SetValueByKey(key, value)
    local index = self._keys[key]
    if index == nil then
        self:Add(value, key)
    else
        self:SetValueByIndex(index, value)
    end
end



--=------------------------------[ add ]------------------------------=--

--- 添加一个值，以及对应的键列表，并返回该值的索引
---@param value any
---@param ... table<number, any>
---@return number
function MapList:Add(value, ...)
    local index = #self._values + 1
    self._values[index] = value

    local keys = { ... }
    for i = 1, #keys do
        self._keys[keys[i]] = index
    end

    self:DispatchDataEvent(5, index, nil, value)
    return index
end

--- 通过索引为该值添加一个键，并返回该值的索引。如果值不存在，将会添加失败，并返回 -1
---@param newKey any
---@param index number
function MapList:AddKeyByIndex(newKey, index)
    if self._values[index] == nil then
        return -1
    end
    self._keys[newKey] = index
    return index
end

--- 通过键为该值添加一个键，并返回该值的索引。如果没有源键，将会添加失败，并返回 -1
---@param newKey any
---@param key any
function MapList:AddKeyByKey(newKey, key)
    local index = self._keys[key]
    if index == nil then
        return -1
    end
    self:AddKeyByIndex(newKey, index)
    return index
end



--=------------------------------[ remove ]------------------------------=--

--- 移除某个键与值的映射关系。
--- 注意，该方法并不是移除数据的方法。
--- 要移除数据请参考：
---@see MapList#RemoveByKey
---@see MapList#RemoveByIndex
---@param key any
function MapList:RemoveKey(key)
    self._keys[key] = nil
end

--- 通过索引移除对应的键与值，并返回该值
---@param index number
---@return any
function MapList:RemoveByIndex(index)
    local value = remove(self._values, index)

    local list = self._keys
    for k, v in pairs(list) do
        -- 移除相关的key
        if v == index then
            list[k] = nil
        elseif v > index then
            -- 后面的索引减1
            list[k] = v - 1
        end
    end

    self:DispatchDataEvent(6, index, value)
    return value
end

--- 通过键移除对应的键与值，并返回该值
---@param key any
---@return any
function MapList:RemoveByKey(key)
    local index = self._keys[key]
    if index ~= nil then
        return self:RemoveByIndex(index)
    end
end



--=------------------------------[ propertys ]------------------------------=--

--- 设置值列表
---@param value table<number, any>
function MapList:SetValues(value)
    self._values = value
    self:DispatchDataEvent(3)
end

--- 获取值列表
---@return table<number, any>
function MapList:GetValues()
    return self._values
end

--- 设置与值列表对应的键列表
---@param value table<any, number>
function MapList:SetKeys(value)
    self._keys = value
end

--- 获取与值列表对应的键列表
---@return table<any, number>
function MapList:GetKeys()
    return self._keys
end

--- 获取数据（值）总数
---@return number
function MapList:GetCount()
    return #self._values
end



--=------------------------------[ other ]------------------------------=--

--- 抛出数据改变事件
---@param reason number
---@param index number
---@param oldValue any
---@param newValue any
function MapList:DispatchDataEvent(reason, index, oldValue, newValue)
    if self.dispatchChanged then
        local event = Event.Get(DataEvent, DataEvent.DATA_CHANGED)
        event.reason = reason
        event.index = index or -1
        event.oldValue = oldValue
        event.newValue = newValue
        self:DispatchEvent(event)
    end
end

--- 克隆
---@return MapList
function MapList:Clone()
    return MapList.New(ObjectUtil.Copy(self._values), ObjectUtil.Copy(self._keys))
end

--- 清空
function MapList:Clean()
    self._values = {}
    self._keys = {}
    self:DispatchDataEvent(2)
end

return MapList