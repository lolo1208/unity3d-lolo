--
-- Object 相关工具类
-- 2017/10/9
-- Author LOLO
--

local pairs = pairs
local type = type
local getmetatable = getmetatable
local setmetatable = setmetatable


--
---@class ObjectUtil
local ObjectUtil = {}


--
--- 浅拷贝 table
---@param from table
---@param to table -可选-
---@return table
function ObjectUtil.Copy(from, to)
    to = to or {}
    for k, v in pairs(from) do
        to[k] = v
    end
    return to
end


--
--- 深度克隆 table
---@param target table
---@return table
function ObjectUtil.Clone(target)
    local lookup_table = {}

    local function _copy(obj)
        if type(obj) ~= "table" then
            return obj
        elseif lookup_table[obj] then
            return lookup_table[obj]
        end

        local new_table = {}
        lookup_table[obj] = new_table
        for k, v in pairs(obj) do
            new_table[_copy(k)] = _copy(v)
        end

        return setmetatable(new_table, getmetatable(obj))
    end

    return _copy(target)
end



--
return ObjectUtil
