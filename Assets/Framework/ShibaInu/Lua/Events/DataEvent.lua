--
-- 数据相关事件
-- 2017/12/15
-- Author LOLO
--

---@class DataEvent : Event
---@field New fun():DataEvent
---
---@field index number @ 值在 MapList 中的索引
---@field oldValue any @ 原值
---@field newValue any @ 新值
local DataEvent = class("DataEvent", Event)



--=------------------------------[ static ]------------------------------=--

--- 数据已改变
DataEvent.DATA_CHANGED = "DataEvent_DataChanged"

--=----------------------------------------------------------------------=--



--
return DataEvent

