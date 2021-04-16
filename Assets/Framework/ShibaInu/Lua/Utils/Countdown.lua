--
-- 倒计时工具（类中涉及到的时间单位均为：毫秒）
-- 2018/11/5
-- Author LOLO
--

local error = error
local format = string.format
local ceil = math.ceil


--
---@class Countdown
---@field New fun(handler:HandlerRef, totalTime:number, intervalTime:number):Countdown
---
---@field _totalTime number @ 倒计时总时间
---@field _intervalTime number @ 间隔时间
---@field _startTime number @ 倒计时开始时间（设置totalTime的那一刻）
---@field _handler HandlerRef @ 定时器运行时的回调函数。回调时会传递一个 boolean 类型的参数，表示倒计时是否已经结束
---@field _running boolean @ 倒计时工具是否正在运行中
---@field _timer Timer @ 用于倒计时
local Countdown = class("Countdown")


--
--- 创建一个 Handler 对象
--- 如果 Handler 只需要被执行一次，推荐使用 Handler.create() 创建
---@param handler HandlerRef @ 回调
---@param totalTime number @ 总时间
---@param intervalTime number @ 间隔时间。默认：1000
function Countdown:Ctor(handler, totalTime, intervalTime)
    self._handler = handler;
    self._intervalTime = intervalTime or 1000
    self:SetTotalTime(totalTime or 0)
end


--
--- 开始运行倒计时工具
---@param totalTime number @ 倒计时总时间。默认：nil 表示未变动
function Countdown:Start(totalTime)
    if totalTime ~= nil then
        self:SetTotalTime(totalTime)
    end

    if self._intervalTime <= 0 then
        error(format(Constants.E3010, self._intervalTime))
    end

    self._running = true
    if self._timer == nil then
        self._timer = Timer.New(self._intervalTime / 1000, NewHandler(self.TimerHandler, self))
    else
        self._timer:SetDelay(self._intervalTime / 1000)
    end
    self._timer:Start()
    self:TimerHandler()
end


--
--- 计时器回调
function Countdown:TimerHandler()
    local t = TimeUtil.timeMsec - self._startTime
    t = self._totalTime - t
    local isEnd = t <= 0
    if isEnd then
        self._running = false
        self._timer:Stop()
    end

    if self._handler ~= nil then
        CallHandler(self._handler, isEnd)
    end
end


--
--- 停止运行倒计时工具
function Countdown:Stop()
    self._running = false
    if self._timer ~= nil then
        self._timer:Stop()
    end
end



--
--- 倒计时总时间
---@param value number
function Countdown:SetTotalTime(value)
    self._totalTime = value
    self._startTime = TimeUtil.timeMsec
end

---@return number
function Countdown:GetTotalTime()
    return self._totalTime
end



--
--- 间隔时间
---@param value number
function Countdown:SetIntervalTime(value)
    if value == self._intervalTime then
        return
    end
    self._intervalTime = value

    if self._running then
        self:Start()
    end
end

---@return number
function Countdown:GetIntervalTime()
    return self._intervalTime
end



--
--- 定时器运行时的回调。
--- 回调时会传递一个 boolean 类型的参数，表示倒计时是否已经结束
---@param value HandlerRef
function Countdown:SetHandler(value)
    self._handler = value
end

---@return HandlerRef
function Countdown:GetHandler()
    return self._handler
end



--
--- 倒计时工具是否正在运行中
---@return boolean
function Countdown:IsRunning()
    return self._running
end


--
--- 倒计时开始时间（设置totalTime的那一刻）
---@return number
function Countdown:GetStartTime()
    return self._startTime
end


--
--- 剩余时间（从设置totalTime的那一刻开始计算）
---@return number
function Countdown:GetTime()
    if self._totalTime <= 0 or isNaN(self._startTime) then
        return 0
    end

    local t = TimeUtil.timeMsec - self._startTime
    t = self._totalTime - t
    if t < 0 then
        t = 0
    end
    return t
end


--
--- 剩余次数
---@return number
function Countdown:GetCount()
    if self._intervalTime > self._totalTime then
        return 0
    end
    if self._intervalTime <= 0 or isNaN(self._intervalTime) then
        return 0
    end
    if self._totalTime <= 0 or isNaN(self._startTime) then
        return 0
    end

    local t = TimeUtil.timeMsec - self._startTime
    t = self._totalTime - t
    return ceil(t / self._intervalTime)
end



--
return Countdown
