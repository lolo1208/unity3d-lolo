--
-- 鼠标指针（touch）拖放相关事件
-- 可以在任何 gameObject 上抛出
-- 2017/11/23
-- Author LOLO
--

---@class DragDropEvent : Event
---@field data UnityEngine.EventSystems.AxisEventData  @ 指针事件附带的数据
local DragDropEvent = class("DragDropEvent", Event)

function DragDropEvent:Ctor(type, data)
    DragDropEvent.super.Ctor(self, type, data)
end




--=------------------------------[ static ]------------------------------=--

--- 开始拖拽
DragDropEvent.BEGIN_DRAG = "DragDropEvent_BeginDrag"

--- 拖拽中
DragDropEvent.DRAG = "DragDropEvent_Drag"

--- 结束拖拽
DragDropEvent.END_DRAG = "DragDropEvent_EndDrag"

--- 可能发生拖拽
DragDropEvent.INITIALIZE_POTENTIAL_DRAG = "DragDropEvent_InitializePotentialDrag"

--- 被放置
DragDropEvent.DROP = "DragDropEvent_Drop"


--
local event = DragDropEvent.New()

--- 抛出拖放相关事件，由 DragDropEventDispatcher.cs 调用
---@param ed EventDispatcher
---@param type string
---@param data UnityEngine.EventSystems.AxisEventData
function DragDropEvent.DispatchEvent(ed, type, data)
    event.target = nil
    event.isPropagationStopped = false

    event.type = type
    event.data = data
    trycall(ed.DispatchEvent, ed, event, false, false)
end


--=----------------------------------------------------------------------=--



return DragDropEvent