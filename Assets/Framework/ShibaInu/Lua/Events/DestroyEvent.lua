--
-- GameObject 被销毁时
-- 2017/11/23
-- Author LOLO
--

---@class DestroyEvent : Event
local DestroyEvent = class("DestroyEvent", Event)


function DestroyEvent:Ctor(type, data)
    self.super:Ctor(type, data)
end



--=------------------------------[ static ]------------------------------=--

---@type string @ GameObject 被销毁。所有的 GameObject 都可以抛出该事件
DestroyEvent.DESTROY = "Destroy"



local event = DestroyEvent.New()

--- 抛出 Destroy 事件，由 C# DestroyEventDispatcher.cs 调用
---@param ed EventDispatcher
function DestroyEvent.DispatchEvent(ed)
    event.type = DestroyEvent.DESTROY
    ed:DispatchEvent(event, false, false)
end


--=----------------------------------------------------------------------=--



return DestroyEvent