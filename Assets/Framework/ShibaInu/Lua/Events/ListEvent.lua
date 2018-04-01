--
-- 列表与子项相关事件
-- 2017/12/15
-- Author LOLO
--

---@class ListEvent : Event
---@field item ItemRenderer @ 对应的 item
local ListEvent = class("ListEvent", Event)


function ListEvent:Ctor(type, data)
    ListEvent.super.Ctor(self, type, data)
end



--=------------------------------[ static ]------------------------------=--

--- 子项鼠标指针（touch）按下
ListEvent.ITEM_POINTER_DOWN = "ListEvent_ItemPointerDown"

--- 子项鼠标指针（touch）点击
ListEvent.ITEM_POINTER_CLICK = "ListEvent_ItemPointerClick"

--- 子项被选中
ListEvent.ITEM_SELECTED = "ListEvent_ItemSelected"


--- 列表有更新
ListEvent.UPDATE = "ListEvent_ListUpdate"

--=----------------------------------------------------------------------=--



return ListEvent