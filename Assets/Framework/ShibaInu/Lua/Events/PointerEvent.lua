--
-- 鼠标指针（touch）相关事件
-- 可以在任何 gameObject 上抛出
-- 2017/11/23
-- Author LOLO
--

---@class PointerEvent : Event
---@field data UnityEngine.EventSystems.PointerEventData @ 指针事件附带的数据
local PointerEvent = class("PointerEvent", Event)

function PointerEvent:Ctor(type, data)
    PointerEvent.super.Ctor(self, type, data)
end




--=------------------------------[ static ]------------------------------=--

--- 鼠标指针（touch）进入对象
PointerEvent.ENTER = "PointerEvent_Enter"

--- 鼠标指针（touch）离开对象
PointerEvent.EXIT = "PointerEvent_Exit"

--- 鼠标指针（touch）按下
PointerEvent.DOWN = "PointerEvent_Down"

--- 鼠标指针（touch）释放
PointerEvent.UP = "PointerEvent_Up"

--- 鼠标指针（touch）点击
PointerEvent.CLICK = "PointerEvent_Click"


--
local event = PointerEvent.New()

--- 抛出鼠标指针（touch）相关事件，由 PointerEventDispatcher.cs 调用
---@param ed EventDispatcher
---@param type string
---@param data UnityEngine.EventSystems.PointerEventData
function PointerEvent.DispatchEvent(ed, type, data)
    event.target = nil
    event.isPropagationStopped = false

    event.type = type
    event.data = data
    trycall(ed.DispatchEvent, ed, event, false, false)
end


--=----------------------------------------------------------------------=--



return PointerEvent