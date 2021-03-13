--
-- Touch 相关事件，兼容 standalone 和 mobile 平台
-- 目前只在 Stage 抛出
-- 2018/11/8
-- Author LOLO
--

---@class TouchEvent : Event
---@field New fun():TouchEvent
---
---@field touchId number @ standalone 值为 -1，mobile 值为 fingerId
---@field position Vector2 @ 当前位置（Screen Position）
---@field deltaPosition Vector2 @ 距离上次事件增量位置（Screen Position）
local TouchEvent = class("TouchEvent", Event)



--=------------------------------[ static ]------------------------------=--

--- Touch 开始
TouchEvent.BEGIN = "TouchEvent_Begin"

--- Touch 移动
TouchEvent.MOVE = "TouchEvent_Move"

--- Touch 结束
TouchEvent.END = "TouchEvent_End"


--
--- 舞台（全局） Touch 相关事件，由 StageTouchEventDispatcher.cs 调用
---@param type string
---@param touchId number
---@param position Vector2
---@param deltaPosition Vector2
function TouchEvent.StageDispatchEvent(type, touchId, position, deltaPosition)
    ---@type TouchEvent
    local event = Event.Get(TouchEvent, type)
    event.touchId = touchId
    event.position = position
    event.deltaPosition = deltaPosition
    trycall(DispatchEvent, nil, Stage, event)
end

--=----------------------------------------------------------------------=--



--
return TouchEvent

