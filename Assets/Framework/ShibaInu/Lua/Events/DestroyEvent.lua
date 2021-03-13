--
-- GameObject 被销毁时
-- 2017/11/23
-- Author LOLO
--

---@class DestroyEvent : Event
---@field New fun():DestroyEvent
---
local DestroyEvent = class("DestroyEvent", Event)



--=------------------------------[ static ]------------------------------=--

--- GameObject 被销毁。所有的 GameObject 都可以抛出该事件
DestroyEvent.DESTROY = "DestroyEvent_Destroy"


--
--- 抛出 Destroy 事件，由 C# DestroyEventDispatcher.cs 调用
---@param ed EventDispatcher
function DestroyEvent.DispatchEvent(ed)
    trycall(ed.DispatchEvent, ed, Event.Get(DestroyEvent, DestroyEvent.DESTROY))
end

--=----------------------------------------------------------------------=--



--
return DestroyEvent

