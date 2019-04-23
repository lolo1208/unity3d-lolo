--
-- 触发相关事件
-- 2019/4/12
-- Author LOLO
--

---@class TriggerEvent : Event
---@field data UnityEngine.Collider
local TriggerEvent = class("TriggerEvent", Event)

function TriggerEvent:Ctor(type, data)
    TriggerEvent.super.Ctor(self, type, data)
end



--=------------------------------[ static ]------------------------------=--

--- 物体进入触发器范围
TriggerEvent.ENTER = "TriggerEvent_Enter"

--- 物体停留在触发器范围内
TriggerEvent.STAY = "TriggerEvent_Stay"

--- 物体离开触发器
TriggerEvent.EXIT = "TriggerEvent_Exit"


--
local event = TriggerEvent.New()

--- 抛出 Trigger 相关事件，由 TriggerEventDispatcher.cs 调用
---@param ed EventDispatcher
---@param type string
---@param data UnityEngine.Collider
function TriggerEvent.DispatchEvent(ed, type, data)
    event.target = nil
    event.isPropagationStopped = false

    event.type = type
    event.data = data
    trycall(ed.DispatchEvent, ed, event, false, false)
end


--=----------------------------------------------------------------------=--



return TriggerEvent
