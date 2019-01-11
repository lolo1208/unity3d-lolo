--
-- 字符串相关工具类
-- 2018/1/22
-- Author LOLO
--

local sub = string.sub
local gsub = string.gsub
local byte = string.byte
local format = string.format


--
---@class StringUtil
local StringUtil = {}



--
--- 返回 str 对应的 URL 编码字符串
---@param str string
---@return string
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


--
--- 将指定字符串内的 "{n}" 标记替换成传入的参数，并返回替换后的新字符串
---@param str string @ 要替换的字符串
---@vararg string @ 参数列表
---@return string
function StringUtil.Substitute(str, ...)
    if str == nil then
        return ""
    end

    local args = { ... }
    for i = 1, #args do
        str = gsub(str, "{" .. i .. "}", args[i])
    end
    return str
end


--
--- 删除头尾的空白字符，并返回删除后的新字符串
---@param str string
---@return string
function StringUtil.Trim(str)
    return (gsub(str, "^%s*(.-)%s*$", "%1"))
end



--
--- 判断目标字符串是否是以另外一个给定的子字符串“开头”的
---@param str string @ 目标字符串
---@param starts string @ 开头字符串
---@return boolean
function StringUtil.StartsWith(str, starts)
    return sub(str, 1, #starts) == starts
end


--
--- 判断目标字符串是否是以另外一个给定的子字符串“结尾”的
---@param str string @ 目标字符串
---@param ends string @ 结尾字符串
---@return boolean
function StringUtil.EndsWith(str, ends)
    return sub(str, -#ends) == ends
end


--
--- 判断字符串是否为 nil 或 ""
---@param str string
---@return boolean
function StringUtil.IsEmpty(str)
    return str == nil or str == ""
end



--
return StringUtil
