--
-- 字符串相关工具类
-- 2018/1/22
-- Author LOLO
--

local ceil = math.ceil
local floor = math.floor
local sub = string.sub
local gsub = string.gsub
local byte = string.byte
local format = string.format
local tonumber = tonumber
local tostring = tostring


--
---@class StringUtil
local StringUtil = {}



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
--- 使用参数 sep 作为分隔符字符串，将参数 str 字符串分割成字符串数组，并返回该数组
---@param str string @ 要分割的字符串
---@param sep string @ 使用的分隔符字符串
---@return string[]
function StringUtil.Split(str, sep)
    sep = sep or " "
    local fields = {}
    local pattern = format("([^%s]+)", sep)
    gsub(str, pattern, function(c)
        fields[#fields + 1] = c
    end)
    return fields
end


--
--- 当 number 取整转为字符串后，长度少于 length，将会在前面拼接 "0" 凑够长度
--- 默认返回值：string.format("%02d", nunber)
---@param number number @ 数字
---@param length number @ -可选- 长度，默认：2
function StringUtil.LeadingZeros(number, length)
    length = length or 2
    return format("%0" .. length .. "d", number)
end


--
local CURRENCY_AMOUNT_PAT = "^(%d+)(%.%d+)$"
local CURRENCY_AMOUNT_INT_PAT = "(%d%d%d)"
local CURRENCY_AMOUNT_SEP = ","
local CURRENCY_AMOUNT_SEP_PAT = "^,"

--- 千分位格式化货币值
---@param amount number @ 要格式化的值
---@param decimal number @ 是否保留2位小数。默认：false，不保留小数，并四舍五入取整
---@param separator number @ 格式化符号。默认：","
---@return string
function StringUtil.FormatCurrency(amount, decimal, separator)
    local separatorPattern
    if separator == nil then
        separator = CURRENCY_AMOUNT_SEP
        separatorPattern = CURRENCY_AMOUNT_SEP_PAT
    else
        separator = separator or ","
        separatorPattern = "^" .. separator
    end

    if decimal then
        local formattedAmount = format("%.2f", amount)
        local integerPart, decimalPart = formattedAmount:match(CURRENCY_AMOUNT_PAT)
        integerPart = integerPart:reverse():gsub(CURRENCY_AMOUNT_INT_PAT, "%1" .. separator):reverse()
        integerPart = integerPart:gsub(separatorPattern, "") -- 删除开头的逗号
        return integerPart .. decimalPart
    else
        amount = tostring(floor(amount + 0.5))
        local retVal = amount:reverse():gsub(CURRENCY_AMOUNT_INT_PAT, "%1" .. separator):reverse()
        retVal = retVal:gsub(separatorPattern, "")
        return retVal
    end
end


--
--- 简写数值
--- 大于十亿返回 n+B，大于百万返回 n+M，大于一千返回 n+K，小于一千直接返回
---@param num number @ 要简写的数值
---@param decimalPlaces number @ 保留小数位数，默认：2
---@return string
function StringUtil.AbbreviateNumber(num, decimalPlaces)
    decimalPlaces = decimalPlaces or 2

    local result = num
    local suffix = ""
    if num >= 1000000000 then
        result = num / 1000000000
        suffix = "B"
    elseif num >= 1000000 then
        result = num / 1000000
        suffix = "M"
    elseif num >= 1000 then
        result = num / 1000
        suffix = "K"
    else
        result = num
    end
    result = format("%." .. decimalPlaces .. "f", result)
    -- 去除小数部分末尾的无效0
    result = result:gsub("%.?0+$", "")

    return result .. suffix
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
--- 格式化的时间的默认函数，返回值示例：
--- "7d 01:23:45" / "01:23:45" / "00:01:00" / "01:23" / "00:01"
---@return string
function StringUtil.FormatTime_Default(d, h, m, s)
    local str
    if d > 0 then
        str = format("%sd ", d)
    else
        str = ""
    end
    if h > 0 or d > 0 then
        str = str .. format("%02d:", h % 24)
    end
    str = str .. format("%02d:%02d", m, s)
    return str
end
local FormatTime_Default = StringUtil.FormatTime_Default


--
--- 保留两位时间单位的格式化函数，返回值示例：
--- "123h 45m" / "12h 34m" / "01h 23m"
--- "12m 34s" / "01m 23s" / "00m 01s"
---@return string
function StringUtil.FormatTime_2Units(d, h, m, s)
    if h > 0 or d > 0 then
        return format("%02dh %02dm", d * 24 + h, m)
    else
        return format("%02dm %02ds", m, s)
    end
end


--
--- 返回格式化的时间
---@param time number @ 时间值
---@param formatting fun(d, h, m, s):string @ -可选- 格式化函数，默认：StringUtil.FormatTime_Default
---@param timeType string @ -可选- time 的类型，默认：毫秒
---@return string
function StringUtil.FormatTime(time, formatting, timeType)
    -- 转换为毫秒
    if timeType ~= nil and timeType ~= TimeUtil.TYPE_MS then
        time = TimeUtil.Convert(timeType, TimeUtil.TYPE_MS, time)
    end
    -- 计算各单位的值
    local h = floor(time / 3600000)
    local m = floor(time % 3600000 / 60000)
    local s = ceil(time % 3600000 % 60000 / 1000)
    local d = floor(h / 24)
    if s == 60 then
        s = 0
        m = m + 1
    end
    if m == 60 then
        m = 0
        h = h + 1
    end
    return (formatting or FormatTime_Default)(d, h % 24, m, s)
end



--
--- 返回格式化字节数
--- 例如 StringUtil.FormatBytes(1234)，返回："1.21 KB"
---@param size string @ 字节大小
---@param formatstring string @ -可选- 格式化字符串，默认："%.2f %s"
---@return string
function StringUtil.FormatBytes(size, formatstring)
    formatstring = formatstring or "%.2f %s"
    local idx = 1
    while size > 1024 do
        size = size / 1024
        idx = idx + 1
    end
    local units = { "byte", "kb", "mb", "gb" }
    return format(formatstring, size, Language["string.format.unit." .. units[idx]])
end



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
--- 返回一个新的，根据 hexString 创建的 Color 对象
--- 例如：StringUtil.HexColor("FF0099") 或 StringUtil.HexColor("FF0099FF")
---@param hexString string @ rpg 或 rgba （大小写不敏感）
---@return Color
function StringUtil.HexColor(hexString)
    local r = sub(hexString, 1, 2)
    local g = sub(hexString, 3, 4)
    local b = sub(hexString, 5, 6)
    local color = Color.New(tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255)
    if #hexString == 8 then
        local a = sub(hexString, 7, 8)
        color.a = tonumber(a, 16) / 255
    end
    return color
end



--
--- 返回格式化好的语言包值
---@param lk string @ language key，语言包 key
---@return string
function StringUtil.FormatLanguage(lk, ...)
    return format(Language[lk], ...)
end



--
return StringUtil
