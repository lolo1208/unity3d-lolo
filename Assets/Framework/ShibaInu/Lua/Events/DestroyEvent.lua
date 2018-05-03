--
-- GameObject 被销毁时
-- 2017/11/23
-- Author LOLO
--

---@class DestroyEvent : Event
local DestroyEvent = class("DestroyEvent", Event)

function DestroyEvent:Ctor(type, data)
    DestroyEvent.super.Ctor(self, type, data)
end



--=------------------------------[ static ]------------------------------=--

--- GameObject 被销毁。所有的 GameObject 都可以抛出该事件
DestroyEvent.DESTROY = "DestroyEvent_Destroy"

local event = DestroyEvent.New(DestroyEvent.DESTROY)

--- 抛出 Destroy 事件，由 C# DestroyEventDispatcher.cs 调用
---@param ed EventDispatcher
function DestroyEvent.DispatchEvent(ed)
    event.data = nil
    event.target = nil
    event.isPropagationStopped = false
    trycall(ed.DispatchEvent, ed, event, false, false)
end


--=----------------------------------------------------------------------=--



return DestroyEvent