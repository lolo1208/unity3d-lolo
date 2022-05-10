--
-- 事件基类
-- 2017/9/27
-- Author LOLO
--

local table = table
local remove = table.remove


--
---@class Event
---@field New fun(type:string, data:any):Event
---
---@field type string @ 事件类型
---@field data any @ 事件附带的数据
---@field currentTarget EventDispatcher @ 当前事件的传递者（当前回调的注册对象）
---@field target EventDispatcher @ 事件的真正的抛出者
---@field isPropagationStopped boolean @ 事件传播（冒泡）是否已停止，[default:false]
---@field inPool boolean @ 是否正在缓存池中
local Event = class("Event")


--
--- 构造函数
--- 注意：请使用 Event.Get() 和 Event.Recycle() 来创建和回收事件对象
---@param type string
---@param data any
function Event:Ctor(type, data)
    self.type = type
    self.data = data
    self.isPropagationStopped = false
end



--=------------------------------[ static ]------------------------------=--

--- 帧更新事件。该事件只会在 Stage 上抛出
Event.UPDATE = "Event_Update"

--- 渲染前更新，在 Event.UPDATE 事件之后。该事件只会在 Stage 上抛出
Event.LATE_UPDATE = "Event_LateUpdate"

--- 固定时间更新（Edit -> Project Setting -> time -> Fixed timestep）。该事件只会在 Stage 上抛出
Event.FIXED_UPDATE = "Event_FixedUpdate"

--- 屏幕尺寸有改变。该事件只会在 Stage 上抛出
Event.RESIZE = "Event_Resize"

--- 当前程序被激活（从后台切回）。该事件只会在 Stage 上抛出
Event.ACTIVATED = "Event_Activated"

--- 当前程序切入后台运行。该事件只会在 Stage 上抛出
Event.DEACTIVATED = "Event_Deactivated"

--

--- 语言包切换时，event.data = "en-US"。该事件只会在 Stage 上抛出
Event.LANGUAGE_CHANGED = "Event_LanguageChanged"

--- 音频播放完毕，event.data = "audio path"。该事件只会在 Audio 上抛出
Event.AUDIO_COMPLETE = "Event_AudioComplete"




--
--- 从池中获取一个事件对象
---@param EventClass Event @ 事件Class
---@param type string @ 事件类型
---@param data any @ 附带数据
---@return Event
function Event.Get(EventClass, type, data)
    local event
    local pool = EventClass._pool
    if pool == nil or #pool == 0 then
        event = EventClass.New()
    else
        event = remove(pool)
    end
    event.type = type
    event.data = data
    event.inPool = false
    return event
end


--
--- 将事件对象回收到对应的池中
---@param event Event
---@return void
function Event.Recycle(event)
    if event.inPool then
        if isEditor then
            error(Constants.E1004)
        end
        return
    end

    local pool = event.__class._pool
    local poolCount
    if pool == nil then
        pool = {}
        event.__class._pool = pool
        poolCount = 0
    else
        poolCount = #pool
        if poolCount > 200 then
            if isEditor then
                logWarningCount(StringUtil.Substitute(Constants.W1001, event.__classname), 20)
            end
            return
        end
    end
    event.inPool = true
    pool[poolCount + 1] = event

    event.data = nil
    event.target = nil
    event.currentTarget = nil
    event.isPropagationStopped = false
end



--
--- 抛出 AUDIO_COMPLETE 事件，由 C# AudioManager.cs 调用
---@param path string
function Event.DispatchAudioCompleteEvent(path)
    trycall(DispatchEvent, nil, Audio, Event.Get(Event, Event.AUDIO_COMPLETE, path))
end



--
return Event

