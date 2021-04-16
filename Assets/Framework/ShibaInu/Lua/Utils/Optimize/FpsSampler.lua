--
-- 帧频采样统计器
-- 2018/2/26
-- Author LOLO
--

local max = math.max
local remove = table.remove

--


---@class FpsSampler
local FpsSampler = {}

FpsSampler.frameRate = UnityEngine.Application.targetFrameRate --- 当前设定帧频

local DEFAULT_KEY = "default" --- 默认 key

local _fpsList = {} --- 最近采样的帧频列表（可用于统计平均帧频）
local _time = 0 --- 记录上次开始统计的时间
local _frame = 0 --- 从上次开始记录到现在，已运行到帧数
local _fps = 0 --- 最近一次统计的帧频
local _fpsMax = 0 --- 采样过程中，达到过的最高帧频
local _running = false --- 是否正在运行中
local _runningKeys = {} --- 正在运行的 key 列表


--


--- Event.UPDATE
---@param event Event
local function UpdateHandler(event)
    _frame = _frame + 1
    if _frame < FpsSampler.frameRate then
        return
    end

    local time = TimeUtil.time
    _fps = 1 / ((time - _time) / _frame)
    _fpsMax = max(_fps, _fpsMax)
    _time = time
    _frame = 0

    local count = #_fpsList
    if count == 5 then
        remove(_fpsList, 1)
    else
        count = count + 1
    end
    _fpsList[count] = _fps
end


--


--- 开始统计
---@param key string
function FpsSampler.Start(key)
    key = key or DEFAULT_KEY

    for i = 1, #_runningKeys do
        if _runningKeys[i] == key then
            return
        end
    end
    _runningKeys[#_runningKeys + 1] = key

    if _running then
        return
    end

    _running = true
    _time = TimeUtil.time
    _frame = 0
    AddEventListener(Stage, Event.UPDATE, UpdateHandler)
end

--

--- 停止统计
---@param key string
function FpsSampler.Stop(key)
    if not _running then
        return
    end

    key = key or DEFAULT_KEY
    for i = 1, #_runningKeys do
        if _runningKeys[i] == key then
            remove(_runningKeys, i)
            break
        end
    end

    if #_runningKeys > 0 then
        return
    end

    _running = false
    RemoveEventListener(Stage, Event.UPDATE, UpdateHandler)
end


--


--- 最近一次统计的帧频
---@return number
function FpsSampler.GetFps()
    return _fps
end

--- 采样过程中，达到过的最高帧频
---@return number
function FpsSampler.GetFpsMax()
    return _fpsMax
end

--- 根据最近几次采样，获取平均帧频
---@return number
function FpsSampler.GetFpsAve()
    local count = #_fpsList
    if count == 0 then
        return 0
    end

    local ave = 0
    for i = 1, count do
        ave = ave + _fpsList[i]
    end
    return ave / count
end

--- 是否正在运行中
---@return boolean
function FpsSampler.GetRunning()
    return _running
end


--

return FpsSampler