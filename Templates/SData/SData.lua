--
-- 静态库数据
-- 2020/10/21
-- Author LOLO
--

local require = require
local pairs = pairs
local setmetatable = setmetatable
local getmetatable = getmetatable
local stringify = JSON.Stringify


--
local SData = require("Data.SData.allTableFields")


-- 查询结果为 nil 时缓存的值
local RESULT_NIL = "__the_result_is_nil__"



-- 只读保护
local readonly = function()
    error("禁止修改 SData 相关静态数据！")
end

-- 将数据加只读保护
local setreadonly = function(data)
    -- setmetatable(data, { __newindex = readonly }) 只能阻止创建新 key，不能阻止修改原 key 对应的值
    -- 返回新的空表，目的是防止修改原 key 对应的值
    return setmetatable({ }, { __readonly = true, __index = data, __newindex = readonly })
end

-- 将表与字段描述加只读保护
for k, v in pairs(SData) do
    SData[k] = setreadonly(v)
end


-- 静态表原始数据
local tables = {}
-- 查询结果缓存，匹配 表/字段/值
local cache = {}



--
--- 根据 表/字段/值 查询匹配的数据。
--- 如果只有一条匹配的数据，只返回该数据。
--- 如果有多条匹配的数据，返回一个包含所有数组的数组，以及表示数量的属性：count。
--- 没有匹配的数据时，返回：nil。
---
--- 例：
---   -- 结果为一条数据
---   local result = SData.Get(SData.equip, SData.equip.id, 10301)
---   print(result[SData.equip.name])
---
---   -- 结果为多条数据
---   local results = SData.Get(SData.equip, SData.equip.pos, 5)
---   for i = 1, results.count do
---       print(results[i][SData.equip.name])
---   end
---
---   -- 结果为 nil
---   local result = SData.Get(SData.equip, SData.equip.id, "10301")
---   print(result == nil)
---
---@param table table @ 表
---@param field number @ 字段
---@param value number|string @ 需匹配的值
function SData.Get(table, field, value)
    local tableName = table.__tablename

    -- 先尝试从缓存中拿数据
    local t = cache[tableName]
    local f, v
    if t then
        f = t[field]
        if f then
            v = f[value]
            -- 在缓存中找到对应的值了 t.f.v
            if v then
                if v ~= RESULT_NIL then
                    return v
                else
                    return nil
                end
            end
        else
            f = {}
            t[field] = f
        end
    else
        t = {}
        cache[tableName] = t
        f = {}
        t[field] = f
    end

    -- 载入表
    table = tables[tableName]
    if not table then
        table = require("Data.SData." .. tableName)
        tables[tableName] = table
    end

    -- 查询匹配的数据
    local count = 0
    local results = {}
    for i = 1, #table do
        local item = table[i]
        if item[field] == value then
            -- 给数据项加只读保护
            if not item.__readonly then
                item = setreadonly(item)
                table[i] = item
            end
            count = count + 1
            results[count] = item
        end
    end

    -- 返回匹配的结果
    local result
    if count == 1 then
        -- 只有一条匹配数据
        f[value] = results[1]
        result = f[value]
    elseif count > 1 then
        -- 有多条匹配数据
        results.count = count
        f[value] = setreadonly(results)
        result = f[value]
    else
        -- 没有匹配值
        f[value] = RESULT_NIL
        result = nil
    end
    return result
end



--
--- 使用过滤函数，查询整张表，返回过滤后的结果。
--- 注意：该函数的查询结果不会存入缓存中，切勿使用该函数频繁查询数据量非常大的静态表。
--- 返回值有三种，与 SData.Get() 函数一致。
---
--- 例：
---   -- 获取品质大于2，装备在5号位置的所有装备
---   local results = SData.Filter(SData.equip, function(item)
---       return item[SData.equip.quality] > 2 and item[SData.equip.pos] == 5
---   end)
---   for i = 1, results.count do
---       print(results[i][SData.equip.name])
---   end
---
---@param table table @ 表
---@param filter fun(item:any[]):boolean @ 过滤函数。返回 true 将会在查询结果中加入该项数据
function SData.Filter(table, filter)
    local tableName = table.__tablename

    -- 载入表
    table = tables[tableName]
    if not table then
        table = require("Data.SData." .. tableName)
        tables[tableName] = table
    end

    local count = 0
    local results = {}
    -- 查询（过滤）整张表
    for i = 1, #table do
        local item = table[i]
        if filter(item) then
            -- 给数据项加只读保护
            if not item.__readonly then
                item = setreadonly(item)
                table[i] = item
            end
            count = count + 1
            results[count] = item
        end
    end

    if count == 1 then
        -- 只有一条匹配数据
        return results[1]
    elseif count > 1 then
        -- 有多条匹配数据
        results.count = count
        return setreadonly(results)
    else
        -- 没有匹配值
        return nil
    end
end



--
--- 打印查询到的静态数据结果。
--- 例：
---   local result = SData.Get(SData.equip, SData.equip.id, 10301)
---   SData.Dump(result, SData.equip)
---
---@param result table @ 查询到的静态数据结果
---@param table table @ -可选- 所属静态表。传入该值，打印的数据会更清晰
function SData.Dump(result, table)
    if not result then
        print(result)
        return
    end
    if result.count then
        for i = 1, result.count do
            SData.Dump(result[i], table)
        end
    else
        if table then
            local data = {}
            for k, v in pairs(getmetatable(table).__index) do
                if k ~= "__tablename" then
                    data[k] = result[v]
                end
            end
            print(stringify(data))
        else
            print(stringify(getmetatable(result).__index))
        end
    end
end



-- SData 加只读保护
SData = setreadonly(SData)
return SData

