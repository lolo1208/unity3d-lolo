--
-- JSON
-- 2017/9/26
-- Author LOLO
--


local pcall = pcall
local cjson = require("cjson")


---@class JSON
local JSON = {}


--- 将字 string 解析成 table
---@param text string
function JSON.parse(text)
    local status, result = pcall(cjson.decode, text)
    if status then
        return result
    end
    --error
end


--- 将 table 格式化成 string
---@param value table
function JSON.stringify(value)
    local status, result = pcall(cjson.encode, value)
    if status then
        return result
    end
    --error
end


return JSON