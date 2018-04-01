--
-- Object 相关工具类
-- 2017/10/9
-- Author LOLO
--

local pairs = pairs
local type = type
local getmetatable = getmetatable
local setmetatable = setmetatable


---@class ObjectUtil
local ObjectUtil = {}


--- 浅拷贝 table
---@param from table
---@param optional to table
---@return table
function ObjectUtil.copy(from, to)
    to = to or {}
    for k, v in pairs(from) do
        to[k] = v
    end
    return to
end


--- 深度克隆 table
---@param target table
---@return table
function ObjectUtil.clone(target)
    local lookup_table = {}

    local function _copy(target)
        if type(target) ~= "table" then
            return target
        elseif lookup_table[target] then
            return lookup_table[target]
        end

        local new_table = {}
        lookup_table[target] = new_table

        for k, v in pairs(target) do
            new_table[_copy(k)] = _copy(v)
        end

        return setmetatable(new_table, getmetatable(target))
    end

    return _copy(target)
end


return ObjectUtil