--
-- JSON
-- 2017/9/26
-- Author LOLO
--

local error = error
local format = string.format
local tostring = tostring
local pcall = pcall
local cjson = require("cjson")


---@class JSON
local JSON = {
    -- JSON 中的 null 值
    NULL = cjson.null
}



--
--- 将字 string 解析成 table
---@param text string
---@return table
function JSON.Parse(text)
    local status, result = pcall(cjson.decode, text)
    if status then
        return result
    end
    error(format(Constants.E3001, text))
end


--
--- 将 table 格式化成 string
---@param value table
---@return string
function JSON.Stringify(value)
    local status, result = pcall(cjson.encode, value)
    if status then
        return result
    end
    error(format(Constants.E3002, tostring(value)))
end




--
return JSON
