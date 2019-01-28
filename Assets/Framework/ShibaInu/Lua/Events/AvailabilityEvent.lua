--
-- gameObject 可用性有改变时（OnEnable() / OnDisable()）
-- 2019/1/28
-- Author LOLO
--


--
---@class AvailabilityEvent : Event
---@field enabled boolean @ 当前是否可用
local AvailabilityEvent = class("AvailabilityEvent", Event)

function AvailabilityEvent:Ctor(type, data)
    AvailabilityEvent.super.Ctor(self, type, data)
end



--=------------------------------[ static ]------------------------------=--

--- 可用性有改变时。所有的 GameObject 都可以抛出该事件
AvailabilityEvent.CHANGED = "AvailabilityEvent_Changed"

local event = AvailabilityEvent.New(AvailabilityEvent.CHANGED)

--- 抛出 Changed 事件，由 C# AvailabilityEventDispatcher.cs 调用
---@param ed EventDispatcher
---@param enabled boolean
function AvailabilityEvent.DispatchEvent(ed, enabled)
    event.data = nil
    event.target = nil
    event.isPropagationStopped = false
    event.enabled = enabled
    trycall(ed.DispatchEvent, ed, event, false, false)
end


--=----------------------------------------------------------------------=--



return AvailabilityEvent