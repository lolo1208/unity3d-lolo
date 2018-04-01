--
-- 事件基类
-- 2017/9/27
-- Author LOLO
--

local table = table
local remove = table.remove


---@class Event
---@field New fun(type:string, data:any):Event
---
---@field type string @ 事件类型
---@field data any @ 事件附带的数据
---@field currentTarget EventDispatcher @ 当前事件的传递者（当前回调的注册对象）
---@field target EventDispatcher @ 事件的真正的抛出者
---@field isPropagationStopped boolean @ 事件传播（冒泡）是否已停止，[default:false]
local Event = class("Event")


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

--- 屏幕尺寸有改变
Event.RESIZE = "Event_Resize"

--=--


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
    return event
end


--- 将事件对象回收到对应的池中
---@param event Event
---@return void
function Event.Recycle(event)
    event.data = nil
    event.target = nil
    event.currentTarget = nil
    event.isPropagationStopped = false

    local pool = event.__class._pool
    if pool == nil then
        pool = {}
        event.__class._pool = pool
    end
    pool[#pool + 1] = event
end


--=----------------------------------------------------------------------=--


return Event