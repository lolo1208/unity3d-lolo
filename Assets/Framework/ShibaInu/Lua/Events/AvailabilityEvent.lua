--
-- gameObject 可用性有改变时（OnEnable() / OnDisable()）
-- 2019/1/28
-- Author LOLO
--

---@class AvailabilityEvent : Event
---@field New fun():AvailabilityEvent
---
---@field enabled boolean @ 当前是否可用
local AvailabilityEvent = class("AvailabilityEvent", Event)

function AvailabilityEvent:Ctor(type, data)
    AvailabilityEvent.super.Ctor(self, type, data)
end



--=------------------------------[ static ]------------------------------=--

--- 可用性有改变时。所有的 GameObject 都可以抛出该事件
AvailabilityEvent.CHANGED = "AvailabilityEvent_Changed"


--
--- 抛出 Changed 事件，由 C# AvailabilityEventDispatcher.cs 调用
---@param ed EventDispatcher
---@param enabled boolean
function AvailabilityEvent.DispatchEvent(ed, enabled)
    ---@type NativeEvent
    local event = Event.Get(AvailabilityEvent, AvailabilityEvent.CHANGED)
    event.enabled = enabled
    trycall(ed.DispatchEvent, ed, event)
end


--=----------------------------------------------------------------------=--



return AvailabilityEvent

