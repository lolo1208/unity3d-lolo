--
-- 字符串相关工具类
-- 2018/1/22
-- Author LOLO
--

local gsub = string.gsub
local byte = string.byte
local format = string.format

---@class StringUtil
local StringUtil = {}

--- 返回 str 对应的 URL 编码字符串
---@param str string
function StringUtil.EncodeURI(str)
    -- Ensure all newlines are in CRLF form
    str = gsub(str, "\r?\n", "\r\n")

    -- Percent-encode all non-unreserved characters
    -- as per RFC 3986, Section 2.3
    -- (except for space, which gets plus-encoded)
    str = gsub(str, "([^%w%-%.%_%~ ])",
            function(c)
                return format("%%%02X", byte(c))
            end
    )

    -- Convert spaces to plus signs
    str = gsub(str, " ", "+")

    return str
end

return StringUtil