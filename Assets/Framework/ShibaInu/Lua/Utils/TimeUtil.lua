--
-- 时间相关工具类
-- 2017/10/16
-- Author LOLO
--

local os = os
local format = string.format
local abs = math.abs


--
---@class TimeUtil
local TimeUtil = {}


--
--- 时间类型：毫秒
TimeUtil.TYPE_MS = "ms"
--- 时间类型：秒
TimeUtil.TYPE_S = "s"
--- 时间类型：分钟
TimeUtil.TYPE_M = "m"
--- 时间类型：小时
TimeUtil.TYPE_H = "h"


--
--- 当前程序已运行精确时间（秒.毫秒），不会受到 Time.timeScale 影响。由 Update / LateUpdate / FixedUpdate 事件更新
TimeUtil.time = 0
--- 当前程序已运行时间（毫秒）
TimeUtil.timeMsec = 0
--- 启动时间，UTC 时间戳（秒）
TimeUtil.startupTime = os.time(os.date("!*t"))
--- 当前 UTC 时间（秒.毫秒）
TimeUtil.nowUTC = 0

--
--- 当前程序已运行帧数（ value = UnityEngine.Time.frameCount ）
TimeUtil.frameCount = UnityEngine.Time.frameCount
--- 距离上一帧的时间（秒.毫秒）
TimeUtil.deltaTime = 0
--- 自游戏启动以来，记录的 deltaTime 总和（秒.毫秒）
TimeUtil.totalDeltaTime = 0
--- 自场景加载以来的时间（秒.毫秒）= Shader _Time.y
TimeUtil.timeSinceLevelLoad = 0



--
--- 转换时间类型
---@param typeFrom string
---@param typeTo string
---@param time number
---@return number
function TimeUtil.Convert(typeFrom, typeTo, time)
    if typeFrom == typeTo then
        return time
    end

    -- 转换成毫秒
    if typeFrom == TimeUtil.TYPE_S then
        time = time * 1000
    elseif typeFrom == TimeUtil.TYPE_M then
        time = time * 60000
    elseif typeFrom == TimeUtil.TYPE_H then
        time = time * 3600000
    end

    -- 返回指定类型
    if typeTo == TimeUtil.TYPE_S then
        return time / 1000
    elseif typeTo == TimeUtil.TYPE_M then
        return time / 60000
    elseif typeTo == TimeUtil.TYPE_H then
        return time / 3600000
    end

    return time
end


--
local RelObj = {
    { 60, Constants.LKEY_TR_MINUTE, Constants.LKEY_TR_MINUTES },
    { 60, Constants.LKEY_TR_HOUR, Constants.LKEY_TR_HOURS },
    { 24, Constants.LKEY_TR_DAY, Constants.LKEY_TR_DAYS },
    { 30.5, Constants.LKEY_TR_MONTH, Constants.LKEY_TR_MONTHS },
    { 12, Constants.LKEY_TR_YEAR, Constants.LKEY_TR_YEARS }
}

--- 获取距离现在的相对时间
---@param timestamp number @ 目标时间，UTC 时间戳（秒）
---@param isAffix boolean @ 可选，是否需要添加 "前" 或 "后" 词缀，默认：true
---@return string @ "现在"，"1分钟前"，"1个月后"，等相对时间的描述
function TimeUtil.RelativeTime(timestamp, isAffix)
    local lk
    local value = TimeUtil.nowUTC - timestamp
    local isAfter = value < 0
    if isAfter then
        value = abs(value)
    end

    for i = 1, #RelObj do
        local rel = RelObj[i]
        local nextVal = value / rel[1]
        if nextVal < 1 then
            break
        end
        if nextVal < 2 then
            lk = rel[2]
            break
        end
        lk = rel[3]
        value = nextVal
    end

    if lk == nil then
        lk = isAfter and Constants.LKEY_TR_SOON or Constants.LKEY_TR_NOW
        return format(Language[lk], value)
    end

    local timeStr = format(Language[lk], value)
    if isAffix == false then
        return timeStr
    end

    local fsBA = isAfter and Constants.LKEY_TR_AFTER or Constants.LKEY_TR_BEFORE
    return format(Language[fsBA], timeStr)
end



--
return TimeUtil
