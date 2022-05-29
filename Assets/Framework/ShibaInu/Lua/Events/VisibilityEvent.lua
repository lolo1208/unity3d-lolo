--
-- 界面显示和隐藏相关事件
-- 2022/05/28
-- Author LOLO
--

---@class VisibilityEvent : Event
---@field New fun():VisibilityEvent
---
local VisibilityEvent = class("VisibilityEvent", Event)



--=------------------------------[ static ]------------------------------=--

--- 显示时
VisibilityEvent.SHOWED = "VisibilityEvent_Showed"

--- 隐藏时
VisibilityEvent.HIDDEN = "VisibilityEvent_Hidden"

--=----------------------------------------------------------------------=--



--
return VisibilityEvent
