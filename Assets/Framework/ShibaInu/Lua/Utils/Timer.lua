--
-- 基于帧频（Update）的定时器
-- 解决丢帧和加速的情况
-- 2017/10/17
-- Author LOLO
--

local error = error
local pairs = pairs
local floor = math.floor
local remove = table.remove

---@class Timer
---@field New fun(delay:number, timerHander:Handler, repeatCount:number, timerCompleteHandler:Handler):Timer
---
---@field running boolean @ 定时器是否正在运行中
---@field currentCount number @ 定时器当前已运行次数
---@field repeatCount number @ 定时器的总运行次数，默认值0，表示无限运行
---@field lastUpdateTime number @ 定时器上次触发时间
---@field timerHander Handler @ 每次达到间隔时的回调
---@field timerCompleteHandler Handler @ 定时器达到总运行次数时的回调
---@field ignoreCount number @ 当某帧执行次数超过（>=）该数量时，将会被标记为只执行一次
---
---@field protected _key number @ 在列表中的key（ _list[delay].list[_key] = self ）
---@field protected _delay number @ 定时器间隔（秒）
local Timer = class("Timer")

--- Ctor
---@param delay number @ 定时器间隔（秒）
---@param timerHander Handler @ 每次达到间隔时的回调
---@param repeatCount number @ 定时器的总运行次数，默认值0，表示无限运行
---@param timerCompleteHandler Handler @ 定时器达到总运行次数时的回调
function Timer:Ctor(delay, timerHander, repeatCount, timerCompleteHandler)
    Timer._onlyKey = Timer._onlyKey + 1
    self._key = Timer._onlyKey

    self.running = false
    self.currentCount = 0
    self.repeatCount = repeatCount or 0
    self.timerHander = timerHander
    self.timerCompleteHandler = timerCompleteHandler
    self.ignoreCount = 999

    self._delay = 0
    self:SetDelay(delay or 1)
end

--- Update 事件更新
---@param event Event
local function UpdateTimer(event)
    local timer ---@type Timer
    local timerList ---@type table<number, Timer> @ timerList[key] = Timer
    local delayChangedList = {} ---@type table<number, number> @ 在回调中，delay 有改变的定时器列表 delayChangedList[index] = key
    local delay, key, timerRunning, ignorable

    local list = Timer._list
    local startingList = Timer._startingList
    local stoppingList = Timer._stoppingList

    -- 添加应该启动的定时器，以及移除该停止的定时器。上一帧将这些操作延迟到现在来处理的目的，是为了防止循环和回调时造成的问题
    for i = #startingList, 1, -1 do
        timer = remove(startingList, i)
        if list[timer._delay] == nil then
            list[timer._delay] = { list = {} }
        end
        list[timer._delay].removeMark = 0
        list[timer._delay].list[timer._key] = timer
    end

    for i = #stoppingList, 1, -1 do
        timer = remove(stoppingList, i)
        if list[timer._delay] ~= nil then
            list[timer._delay].list[timer._key] = nil
        end
    end

    -- 处理回调
    local time = TimeUtil.time
    local removedList = {} ---@type table<number, number> @ 需要被移除的定时器列表 removedList[index] = delay
    for delay, info in pairs(list) do
        timerList = info.list
        timerRunning = false

        for key, timer in pairs(timerList) do
            -- 这个定时器可能已经停止了（可能是被之前处理的定时器回调停止的）
            if timer.running then
                local count = floor((time - timer.lastUpdateTime) / timer._delay) -- 计算次数用以解决丢帧和加速
                -- 次数过多，忽略掉（可能是系统休眠后恢复）
                if count >= timer.ignoreCount then
                    ignorable = true
                    count = 1
                else
                    ignorable = false
                end

                for i = 1, count do
                    -- 定时器在回调中被停止了
                    if not timer.running then
                        break
                    end

                    -- 定时器在回调中更改了delay
                    if timer._delay ~= delay then
                        delayChangedList[#delayChangedList + 1] = key
                        break
                    end

                    timer.currentCount = timer.currentCount + 1
                    if timer.timerHander ~= nil then
                        trycall(timer.timerHander.Execute, timer.timerHander)
                    end

                    -- 定时器已到达允许运行的最大次数
                    if timer.repeatCount ~= 0 and timer.currentCount >= timer.repeatCount then
                        timer:Stop()
                        if timer.timerCompleteHandler ~= nil then
                            trycall(timer.timerCompleteHandler.Execute, timer.timerCompleteHandler)
                        end
                        break -- 可以忽略后面的计次了
                    end
                end

                -- 根据回调次数，更新 上次触发的时间（在回调中没有更改 delay）
                if count > 0 and timer._delay == delay then
                    timer.lastUpdateTime = ignorable and time or (timer.lastUpdateTime + timer._delay * count)
                end

                if timer.running then
                    timerRunning = true
                end
            end
        end

        for i = #delayChangedList, 1, -1 do
            timerList[remove(delayChangedList, i)] = nil
        end

        -- 当前 delay，已经没有定时器在运行状态了
        if not timerRunning then
            if info.removeMark > Timer.MAX_REMOVE_MARK then
                removedList[#removedList + 1] = delay
            else
                info.removeMark = info.removeMark + 1
            end
        else
            info.removeMark = 0
        end
    end

    for i = #removedList, 1, -1 do
        delay = remove(removedList, i)
        if list[delay].removeMark > Timer.MAX_REMOVE_MARK then
            list[delay] = nil
        end
    end

    if #startingList == 0 then
        for delay, info in pairs(list) do
            return
        end
        RemoveEventListener(Stage, Event.UPDATE, UpdateTimer)
    end
end

--- 在 Start() 或 Stop() 的时候，更改 timer 所在列表
---@param timer Timer
local function ChangeTimerState(timer)
    local addList, removeList
    if timer.running then
        addList = Timer._startingList
        removeList = Timer._stoppingList
    else
        addList = Timer._stoppingList
        removeList = Timer._startingList
    end

    -- 从 remove 列表中移除
    for i = 1, #removeList do
        if removeList[i] == timer then
            remove(removeList, i)
            break
        end
    end

    local addListNum = #addList
    for i = 1, addListNum do
        if addList[i] == timer then
            return -- add 列表中已经存在了
        end
    end

    -- 添加到 add 列表中
    addList[addListNum + 1] = timer
end

--- 设置定时器间隔（秒）
---@param value number
---@return void
function Timer:SetDelay(value)
    if value == 0 then
        self:Stop()
        error(Constants.E3004)
    end

    if value == self._delay then
        return
    end

    local running = self.running
    if self._delay ~= 0 then
        self:Reset() -- 之前被设置或启动过，重置定时器
    end

    self._delay = value -- 创建当前间隔的定时器
    if running then
        self:Start()
    end
end

--- 获取定时器间隔（秒）
---@return number
function Timer:GetDelay()
    return self._delay
end

--- 开启定时器
---@return void
function Timer:Start()
    if self.running then
        return
    end

    -- 无限运行 或 没达到设置的运行最大次数
    if self.repeatCount == 0 or self.currentCount < self.repeatCount then
        self.running = true
        ChangeTimerState(self)
        self.lastUpdateTime = TimeUtil.time
        AddEventListener(Stage, Event.UPDATE, UpdateTimer, nil, 9)
    end
end

--- 如果定时器正在运行，则停止定时器
---@return void
function Timer:Stop()
    if not self.running then
        return
    end
    self.running = false
    ChangeTimerState(self)
end

--- 如果定时器正在运行，则停止定时器，并将 currentCount 设为 0
---@return void
function Timer:Reset()
    self.currentCount = 0
    self:Stop()
end

--- 在列表中的key（ _list[delay].list[key] = self ）
function Timer:GetKey()
    return self._key
end



--=------------------------------[ static ]------------------------------=--

--- 可移除标记的最大次数
Timer.MAX_REMOVE_MARK = 5

---@type table @ 定时器列表（以delay为key， _list[delay] = { list:已启动的定时器列表, removeMark:被标记了可以移除的次数 }）
Timer._list = {}
---@type number @ 不重复的key
Timer._onlyKey = 0

---@type table<number, Timer> @ 需要被添加到运行列表的定时器列表
Timer._startingList = {}
---@type table<number, Timer> @ 需要从运行列表中移除的定时器列表
Timer._stoppingList = {}

--=----------------------------------------------------------------------=--



return Timer