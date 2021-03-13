--
-- 列表与子项相关事件
-- 2017/12/15
-- Author LOLO
--

---@class ListEvent : Event
---@field New fun():ListEvent
---
---@field item ItemRenderer @ 对应的 item
local ListEvent = class("ListEvent", Event)



--=------------------------------[ static ]------------------------------=--

--- 子项鼠标指针（touch）按下
ListEvent.ITEM_POINTER_DOWN = "ListEvent_ItemPointerDown"

--- 子项鼠标指针（touch）释放
ListEvent.ITEM_POINTER_UP = "ListEvent_ItemPointerUp"

--- 子项鼠标指针（touch）离开对象
ListEvent.ITEM_POINTER_EXIT = "ListEvent_ItemPointerExit"

--- 子项鼠标指针（touch）点击
ListEvent.ITEM_POINTER_CLICK = "ListEvent_ItemPointerClick"

--- 子项被选中
ListEvent.ITEM_SELECTED = "ListEvent_ItemSelected"

--- 列表有更新
ListEvent.UPDATE = "ListEvent_ListUpdate"

--=----------------------------------------------------------------------=--



--
return ListEvent

