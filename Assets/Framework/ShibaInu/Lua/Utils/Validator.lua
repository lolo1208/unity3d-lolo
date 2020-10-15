--
-- 验证工具类
-- 2018/3/6
-- Author LOLO
--

local sub = string.sub

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

return Validator