--
-- 页面相关事件
-- 2019/02/25
-- Author LOLO
--

---@class PageEvent : Event
---@field New fun():PageEvent
---
---@field target ViewPager
---@field currentTarget ViewPager
---@field index number @ 页面对应的索引
---@field view UnityEngine.GameObject @ 页面
---@field value boolean @ VISIBILITY_CHANGED[true:可见, false:不可见] 或 SELECTION_CHANGED[true:选中, flase:取消选中]
local PageEvent = class("PageEvent", Event)



--=------------------------------[ static ]------------------------------=--

--- 页面显示或隐藏
PageEvent.VISIBILITY_CHANGED = "PageEvent_VisibilityChanged"

--- 页面被选中或取消选中
PageEvent.SELECTION_CHANGED = "PageEvent_SelectionChanged"

--- 新增加页面时（派发该事件时 event.view 的值可能会是 nil）
PageEvent.ADDED = "PageEvent_Added"

--- 页面被移除时（不是销毁。派发该事件时 event.view 的值可能会是 nil）
PageEvent.REMOVED = "PageEvent_Removed"


--
--- 抛出 PageEvent，由 C# VierPager.cs 调用
---@param ed EventDispatcher
---@param type string
---@param index number
---@param view UnityEngine.GameObject
---@param value boolean
function PageEvent.DispatchEvent(ed, type, index, view, value)
    ---@type NativeEvent
    local event = Event.Get(PageEvent, type)
    event.view = view
    event.index = index
    event.value = value
    trycall(ed.DispatchEvent, ed, event)
end

--=----------------------------------------------------------------------=--



--
return PageEvent

