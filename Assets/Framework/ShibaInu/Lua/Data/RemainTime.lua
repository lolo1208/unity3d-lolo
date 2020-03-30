--
-- 剩余时间
-- 2017/10/17
-- Author LOLO
--


---@class RemainTime
---@field New fun(time:number, type:string):RemainTime
---
---@field protected _remainTime number @ 设置的剩余时间
---@field protected _startTime number @ 开始计时的时间
local RemainTime = class("RemainTime")


--
--- 构造函数
function RemainTime:Ctor(time, type)
    self:SetTime(time, type)
end


--
--- 设置剩余时间
---@param time number @ 时间值
---@param type string @ 时间类型，默认：毫秒
---@return void
function RemainTime:SetTime(time, type)
    time = time or 0
    type = type or TimeUtil.TYPE_MS

    self._startTime = TimeUtil.timeMsec
    self._remainTime = TimeUtil.Convert(type, TimeUtil.TYPE_MS, time)
end


--
--- 获取剩余时间，返回的最小值为 0
---@param type string @ 时间类型，默认：毫秒
---@return number
function RemainTime:GetTime(type)
    type = type or TimeUtil.TYPE_MS
    local time = self._remainTime - (TimeUtil.timeMsec - self._startTime)
    time = TimeUtil.Convert(TimeUtil.TYPE_MS, type, time)
    return time > 0 and time or 0
end



--
return RemainTime