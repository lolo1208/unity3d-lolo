--
-- 触发相关事件
-- 2019/4/12
-- Author LOLO
--

---@class TriggerEvent : Event
---@field New fun():TriggerEvent
---
---@field data UnityEngine.Collider
local TriggerEvent = class("TriggerEvent", Event)



--=------------------------------[ static ]------------------------------=--

--- 物体进入触发器范围
TriggerEvent.ENTER = "TriggerEvent_Enter"

--- 物体停留在触发器范围内
TriggerEvent.STAY = "TriggerEvent_Stay"

--- 物体离开触发器
TriggerEvent.EXIT = "TriggerEvent_Exit"


--
--- 抛出 Trigger 相关事件，由 TriggerEventDispatcher.cs 调用
---@param ed EventDispatcher
---@param type string
---@param data UnityEngine.Collider
function TriggerEvent.DispatchEvent(ed, type, data)
    trycall(ed.DispatchEvent, ed, Event.Get(TriggerEvent, type, data))
end

--=----------------------------------------------------------------------=--



--
return TriggerEvent

