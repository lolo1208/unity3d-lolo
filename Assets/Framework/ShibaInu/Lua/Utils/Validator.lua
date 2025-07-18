--
-- 验证工具类
-- 2018/3/6
-- Author LOLO
--

local type = type
local sub = string.sub
local match = string.match

--
local Validator = {}



--
--- 验证字符串不全是空格(包括全角空格)
---@param str string
---@return boolean
function Validator.NotExactlySpace(str)
    for i = 1, #str do
        local c = sub(str, i, i)
        if c ~= " " and c ~= "　" then
            return true
        end
    end
    return false
end


--
--- 验证字符串长度大于零，并且没有空格(包括全角空格)
---@param str string
---@return boolean
function Validator.NoSpace(str)
    local len = #str
    if len == 0 then
        return false
    end
    for i = 1, len do
        local c = sub(i, i)
        if c == " " or c == "　" then
            return false
        end
    end
    return true
end


--
--- 验证字符串是否不为空，且不仅仅由空白字符（空格、换行、制表符等）组成。
--- @param str string 要验证的字符串。
--- @return boolean 如果字符串有效，则返回 true；否则返回 false。
function Validator.IsValidString(str)
    -- 首先，确保输入是字符串类型
    if type(str) ~= "string" then
        return false
    end

    -- 使用 string.match 查找任何一个非空白字符 (%S)
    -- 如果找到了，match 会返回匹配的字符 (truthy)，否则返回 nil (falsy)
    -- 将其结果转换为一个严格的布尔值
    return match(str, "%S") ~= nil
end



--
return Validator

