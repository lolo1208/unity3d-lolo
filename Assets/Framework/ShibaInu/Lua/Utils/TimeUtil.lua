--
-- 类描述
-- 2017/10/16
-- Author LOLO
--

---@class TimeUtil
local TimeUtil = {}



--=------------------------------[ static ]------------------------------=--

---@type string @ 时间类型：毫秒
TimeUtil.TYPE_MS = "ms"
---@type string @ 时间类型：秒
TimeUtil.TYPE_S = "s"
---@type string @ 时间类型：分钟
TimeUtil.TYPE_M = "m"
---@type string @ 时间类型：小时
TimeUtil.TYPE_H = "h"


---@type number @ 当前程序已运行精确时间（单位：秒.毫秒），不会受到 Time.timeScale 影响。由 Update / LateUpdate / FixedUpdate 事件更新
TimeUtil.time = 0



--- 转换时间类型
---@param typeFrom string
---@param typeTo string
---@param time number
---@return number
function TimeUtil.convert(typeFrom, typeTo, time)
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
        return time / 60000;
    elseif typeTo == TimeUtil.TYPE_H then
        return time / 3600000;
    end
end

--=----------------------------------------------------------------------=--



return TimeUtil